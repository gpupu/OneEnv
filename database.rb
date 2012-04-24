require 'rubygems'
#require 'sqlite3'
require 'active_record'
require 'yaml'

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
    has_and_belongs_to_many :enviroments, :uniq => true
    serialize :recipes, Array

=begin
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
			create(:name => cb_name, :path => cb_path, :place => cb_type, :recipes => get_recipes(cb_path))
		else
			puts cb_name + ' is yet on the database'
		end
	end

	private
	def self.get_recipes cb_path
		# Cuidado!!! esto no funcionará cuando place=R
		r_path = cb_path + '/recipes'
		#puts r_path
		recs = Dir.entries(r_path)
		#puts recs
		if recs.size > 2
			recs = recs[1..-2]
			recipe_names= Array.new
			recs.each{|r|
				recipe_names << r.split('.')[0]
			}
			return recipe_names
		else
			return []
		end
	end

	public
	def add_recipe name_recipe
		recipes.push name_recipe
		self.save
	end
=end

end

class Role < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
end

class Enviroment < ActiveRecord::Base

    validates_uniqueness_of :name
    after_create :create_defaults
    has_and_belongs_to_many :cookbooks, :uniq => true
	has_and_belongs_to_many :roles, :uniq => true
    
    private
    def create_defaults
        if name == nil
            s = 'env-' + self.id.to_s
            self.name = s
            self.save
        end
    end

=begin
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

	public 
	def add_role(role_name,path_role)
		roles[role_name] = path_role
		self.save
	end
=end

end

class CreateSchema < ActiveRecord::Migration

if !table_exists?(:cookbooks)
    create_table(:cookbooks) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :null=>false
        t.text :recipes
        t.column :enviroments, :enviroment
    end
end

if !table_exists?(:roles)
	create_table(:roles) do |t|
		t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :null=>false
        t.column :enviroments, :enviroment
	end
end

if !table_exists?(:enviroments)
    create_table(:enviroments) do |t|
        t.column :name, :string, :default=> nil,:unique=>true
		t.column :template, :integer, :null=> false
		t.column :node, :string, :null=> false
		t.column :databags, :string, :default=> nil
		t.column :roles, :role
		t.column :cookbooks, :cookbook
    end
end

if !table_exists?(:cookbooks_enviroments)
    create_table(:cookbooks_enviroments, :id=>false) do |t|
        t.references :cookbook
        t.references :enviroment
    end
end

if !table_exists?(:enviroments_roles)
    create_table(:enviroments_roles, :id=>false) do |t|
        t.references :enviroment
		t.references :role
    end
end


end





=begin
Cookbook.create(:name=>'APACHE', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'MYSQL', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'nginx', :place=>'R')

d1 = Description.new(8, 'clave1', 'small', 'public',true)
d2 = Description.new(7, 'clave2', 'small', 'public',true)
d3 = Description.new(12, 'clave3', 'small', 'public',true)

Enviroment.create(:description=>d1)
Enviroment.create(:description=>d2)
Enviroment.create(:description=>d3)
=end

=begin
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
