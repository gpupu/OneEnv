require 'rubygems'
#require 'sqlite3'
require 'active_record'
require 'yaml'
#require 'oneenv.rb'

# connect to database.  This will create one if it doesn't exist
#MY_DB_NAME = "oneenv.db"
#MY_DB = SQLite3::Database.new(MY_DB_NAME)

CONFIG_FILE = 'oneenv.cnf'

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")

#MY_DB_NAME)

class Description
	attr_accessor :image, :ssh, :type, :network, :vnc
	
	def initialize(image, ssh, type, network, vnc)
		@image = image
		@ssh = ssh
		@type = type
		@network = network
		@vnc = vnc
	end
	
	def to_s
		str = "Image :" + @image.to_s + "\n"
		str += "SSH :" + @ssh.to_s + "\n"
		str += "Type :" + @type.to_s + "\n"
		str += "Network :" + @network.to_s + "\n"
		str += "VNC :" + @vnc.to_s + "\n"
		str
	end

end

class Cookbook < ActiveRecord::Base

    validates_uniqueness_of :name
    before_validation :create_defaults
    has_and_belongs_to_many :enviroments, :uniq => true
    # Obliga a que el campo :place sea R o L
    validates :place, :inclusion => {:in=> ['R', 'L'], :message=> "%{value} no es un valor correcto" }

	private
	def create_defaults
		conf = YAML.load_file(CONFIG_FILE)
		if self.path == nil 
		    if self.place.eql?('R')
		        self.path = conf['default_repository']
		    else
		        self.path = conf['default_local']
		    end
		end
	end

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s += place + "\t"
		s
	end

	public
	def self.cb_create cb_name, cb_path, cb_repo
		cb_type = 'L'
		if cb_repo 
			cb_type = 'R' 
		end
		if !exists?(:name => cb_name)
			create(:name => cb_name, :path => cb_path, :place => cb_type)
		else
			puts cb_name + ' is yet on the database'
		end
	end

end


class Enviroment < ActiveRecord::Base

    validates_uniqueness_of :name
    after_create :create_defaults
    has_and_belongs_to_many :cookbooks, :uniq => true
    serialize :description
    
    private
    def create_defaults
        if name == nil
            s = 'env-' + self.id.to_s
            self.name = s
            self.save
        end
    end

    public
    def to_s
	s  = id.to_s + "\t"
        s += name + "\t"
        s += description.image.to_s + "\t"
        s += description.type + "\t"
        s += description.ssh + "\t"
        s += description.network + "\t"
	s += cookbooks.size.to_s
        s
    end
	public
	def self.view_enviroment id
		env=first(:conditions => {:id => id})
		if !env.nil?
		s  = "ID: " + env.id.to_s + "\n"
		s += "NAME: " + env.name + "\n"
		s += "Descripcion: " + env.description.image.to_s + "\n"
		s += "Tipo" + env.description.type + "\n"
		s += "Clave" + env.description.ssh + "\n"
		s += "Network" + env.description.network + "\n\n"
		s += "CookBooks: " + "\n"
		env.cookbooks.each{|cb| s += "-" + cb.name + " " + cb.path + "\n" }
		else
			s +='Can\'t find the enviroment ' + id.to_s
		end
		s
	end


	public
	def self.clone_env id
		env = first(:conditions => {:id => id})
		if !env.nil?
			copy = self.find(id).clone
			Enviroment.create(:description => copy.description)
			# introduce los cookbooks de la copia en el nuevo registro
			Enviroment.last.cookbooks << copy.cookbooks
		else
			puts 'Can\'t find the enviroment ' + id.to_s
		end
	end

	public
	def self.add_cookbook id, cb_name
		cb = Cookbook.first(:conditions => {:name => cb_name})
		if !cb.nil?
			cb_list = find(id).cookbooks
			if !cb_list.include?(cb)
				find(id).cookbooks << cb
			else
				puts cb_name + ' is yet included'
			end
		else
			puts 'Can\'t find the cookbook ' + cb_name
		end
	end

	public
	def self.delete_cookbook id, cb_name
		cb = Cookbook.first(:conditions => {:name => cb_name})
		if find(id).cookbooks.exists?(cb.object_id)
			#puts 'existe el cb: ' + cb_id.to_s
			find(id).cookbooks.delete(cb)
		else
			puts cb_name + ' is not a cookbook from the selected enviroment'
		end
	end
	
	public	
	def self.delete_allCB cb_name
		cb = Cookbook.first(:conditions => {:name => cb_name})	
		if !cb.nil?
			self.find(:all).each{|k|
				cb_list = k.cookbooks
				if cb_list.include?(cb)
					k.cookbooks.delete(cb)
				end
			}
		else
			puts cb_name + ' is not an existing cookbook'
		end

	end



	public
	def self.add(f)
        # Comprueba si hay un entorno con el mismo nombre y si asi es muestra un mensaje.
		select = self.find{|k| k.name==f.name}
        # si es distinto de nil es que ha encontrado un entorno que se llama igual
		if select!=nil 
			puts "Un entorno con el nombre #{f.name} ya existia"
		else 
			self.create(:name=>f.name, :description => f.description)
			f.cookbooks.each{|cb|
				self.add_cookbook Enviroment.last.id, cb
			}
		end
	end

	public 
	def self.addSSH(id,ssh)
		if self.exists?(id)
			entorno= self.find(id)
			desc = entorno.description
			desc.ssh = ssh
			self.update(entorno.id, {:description => desc})
		else 
			puts 'There is not an environment with that id'
		end
	end


end

class CreateSchema < ActiveRecord::Migration

if !table_exists?(:cookbooks)
    create_table(:cookbooks) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>nil
        # Parece ser que type esta reservado por ruby, cambiado por place
        t.column :place, :string, :default=>'L', :limit=>1
        t.column :enviroments, :enviroment
    end
end

if !table_exists?(:enviroments)
    create_table(:enviroments) do |t|
        # El identificador autonumerado se crea automaticamente
        t.column :name, :string, :default=> nil,:unique=>true
        t.column :description, :string, :default=>nil
        t.column :cookbooks, :cookbook
    end
end

if !table_exists?(:cookbooks_enviroments)
    create_table(:cookbooks_enviroments, :id=>false) do |t|
        t.references :cookbook
        t.references :enviroment
    end
end

end





=begin
Cookbook.create(:name=>'APACHE', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'MYSQL', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'nginx', :place=>'R')
=end

=begin

d1 = Description.new(8, 'clave1', 'small', 'public',true)
d2 = Description.new(7, 'clave2', 'small', 'public',true)
d3 = Description.new(12, 'clave3', 'small', 'public',true)

Enviroment.create(:description=>d1)
Enviroment.create(:description=>d2)
Enviroment.create(:description=>d3)


cb1=['emacs','vim']
cb2=['nginx','APACHE']

e1= Enviroment2.new("env1",d1,cb1)
e2= Enviroment2.new("env2",d2,cb2)
#e3= Enviroment2.new("env3",d3,cb1)
#e4= Enviroment2.new("env4",d1,cb1)

cb3 = Cookbooks.find(3)
cb4 = Cookbooks.find(4)

Enviroment.add(e1)
Enviroment.add(e2)
#Enviroment.add(e3)
#Enviroment.add(e4)
=end
=begin
Enviroment.find(1).cookbooks << Cookbook.find(4)
Enviroment.find(1).cookbooks << Cookbook.find(3)

Enviroment.find(2).cookbooks << Cookbook.find(5)
Enviroment.find(2).cookbooks << Cookbook.find(1)



=end

=begin
ent1 = Env_db.create(:ssh=>'clave1')
ent2 = Env_db.create(:ssh => 'clave2')

ent1.cookbooks.create(:name=>'vim', :path=>'/ruta/hacia/vim')
ent1.cookbooks.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
=end
=begin
desc1 = Enviroment.find(1).description
desc2 = Enviroment.find(2).description
desc3 = Enviroment.find(3).description

puts desc1.to_s
puts desc2.to_s
puts desc3.to_s
=end
