require 'rubygems'
#require 'sqlite3'
require 'active_record'
require 'yaml'
require 'oneenv.rb'

# connect to database.  This will create one if it doesn't exist
#MY_DB_NAME = "oneenv.db"
#MY_DB = SQLite3::Database.new(MY_DB_NAME)

CONFIG_FILE = 'oneenv.cnf'

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")

#MY_DB_NAME)

class Cookbook < ActiveRecord::Base
    validates_uniqueness_of :name
    before_validation :create_defaults
    has_and_belongs_to_many :enviroments
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
    has_and_belongs_to_many :cookbooks
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
        s += description.network
        s
    end

	public
	def self.clone_env id
		copy = self.find(id).clone
		Enviroment.create(:description => copy.description)
		# introduce los cookbooks de la copia en el nuevo registro
		Enviroment.last.cookbooks << copy.cookbooks
	end

	public
	def self.add_cookbook id, cb_name
		cb = Cookbook.first(:conditions => {:name => cb_name})
		if Cookbook.exists?(cb.id)
			#puts 'existe el cb: ' + cb_id.to_s
			find(id).cookbooks << cb
		else
			puts 'Can\'t find the cookbook ' + cb_name
		end
	end

	public
	def self.delete_cookbook id, cb_name
		cb = Cookbook.first(:conditions => {:name => cb_name})
		if find(id).cookbooks.exists?(cb.id)
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
	##HAY QUE METER TB LA RELACIONDE COOKBOOKS
			self.create(:name=>f.name, :description => f)
		end
	end

end

class CreateSchema < ActiveRecord::Migration

    create_table(:cookbooks,:force=>true) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>nil
        # Parece ser que type esta reservado por ruby, cambiado por place
        t.column :place, :string, :default=>'L', :limit=>1
        t.column :enviroments, :enviroment 
    end

    create_table(:enviroments, :force=>true) do |t|
        # El identificador autonumerado se crea automaticamente
        t.column :name, :string, :default=> nil,:unique=>true
        t.column :description, :string, :default=>nil
        t.column :cookbooks, :cookbook 
    end

    create_table(:cookbooks_enviroments, :id=>false, :force=>true) do |t|
        t.references :cookbook
        t.references :enviroment
    end
end

e1 = EnvDescription.new('env1',8,'clave1','small','public',true)
e2 = EnvDescription.new('env2',7,'clave2','small','public',true)
e3 = EnvDescription.new('env3',12,'clave3','small','public',true)
#=begin
Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'apache', :path=>'/ruta/hacia/apache')
Cookbook.create(:name=>'nginx', :place=>'R')
#=end
#=begin
Enviroment.create(:name=>'nombre1', :description => e1) #, :cookbooks => Cookbook.find(2))
Enviroment.create(:description => e2)
Enviroment.create(:name=>'nombre3', :description=> e3) #, :cookbooks => Cookbook.first(:conditions => {:name => 'emacs'}))
Enviroment.create(:name=>'nombre3', :description=> e3) #, :cookbooks => Cookbook.first(:conditions => {:name => 'emacs'}))
Enviroment.create(:description => e2)
#=end

=begin
Enviroment.find(2).cookbooks << Cookbook.find(4)
Enviroment.find(2).cookbooks << Cookbook.find(3)
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
