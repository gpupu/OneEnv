require 'rubygems'
#require 'sqlite3'
require 'active_record'
require 'yaml'

# connect to database.  This will create one if it doesn't exist
#MY_DB_NAME = "oneenv.db"
#MY_DB = SQLite3::Database.new(MY_DB_NAME)

CONFIG_FILE = 'oneenv.cnf'
CONFIG = YAML.load_file(CONFIG_FILE)

# TODO Cuidado con esto!! ¿mantiene valor si se cambia el archivo de configuración?
CB_DIR = File.expand_path(CONFIG['default_cb_dir'])
ROLE_DIR = File.expand_path(CONFIG['default_role_dir'])

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")



class Cookbook < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
    serialize :recipes, Array


	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s += recipes.to_s + "\t"
		s
	end

	public
	def self.cb_create cb_name, cb_path
		if cb_path == nil
			cb_path = CB_DIR
		end

		if !exists?(:name => cb_name)
			cb_path = File.expand_path(cb_path)
			if File.exists?(cb_path)
				dir_recipes = cb_path + '/' + cb_name
				puts 'dir_recipes' + dir_recipes
				create(:name => cb_name, :path => cb_path, :recipes => get_recipes(dir_recipes))
					#TODO:Copiar al directorio por defecto recursivamente
					#desde la dir que entra				
			else
				puts cb_path + ' is not a correct path'
			end
		else
			puts cb_name + ' is yet on the database'
		end
	end

	private
	def self.get_recipes cb_path
		r_path = cb_path + '/recipes'
		#puts r_path
		recs = Dir.entries(r_path)
		#puts recs
		if recs.size > 2
			recipe_names= Array.new
			recs.each{|r|
				if File.extname(r) == ".rb"
					recipe_names << File.basename(r,".rb")
				end
			}
			return recipe_names
		else
			return []
		end
	end

	public 
	def update
		recipes = get_recipes path
	end

end

class Role < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s
	end

	public
	def self.role_create r_name, r_path
		if r_path == nil 
			r_path = ROLE_DIR
		end

		if !exists?(:name=>r_name)
			r_path = File.expand_path(r_path)
			if File.exists?(r_path)
				create(:name=> r_name, :path=> r_path)
				#TODO Copiar rol en el directorio por defecto
			else
				puts r_path + ' is not a correct path'
			end
		else
			puts r_name + 'is yet on the database'
		end
	end

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

    public

    def to_s
	s  = id.to_s + "\t"
        s += name + "\t"
        s += template.to_s + "\t"
        s += node + "\t"
        s += databags.to_s + "\t"
	s += cookbooks.size.to_s + "\t"
        s += roles.size.to_s
    end


    
	public
	def self.view_enviroment id
		env=first(:conditions => {:id => id})
		if !env.nil?
		s  = "ID: " + env.id.to_s + "\n"
		s += "NAME: " + env.name + "\n"
		s += "Template: " + env.template.to_s + "\n"
		s += "CookBooks: " + "\n"
		env.cookbooks.each{|cb| s += "-" + cb.name + " " + cb.path + "\n" }
		else
			s +='Can\'t find the enviroment ' + id.to_s
		end
		s
	end

=begin
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
=end



=begin
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
        t.column :path, :string, :default=>CB_DIR
        t.text :recipes
        t.column :enviroments, :enviroment
    end
end

if !table_exists?(:roles)
	create_table(:roles) do |t|
		t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>ROLE_DIR
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
env1=Enviroment.create(:template=>2, :node=>'/ruta/hacia/nodo1')
env2=Enviroment.create(:template=>3, :node=>'/ruta/hacia/nodo2')
env3=Enviroment.create(:template=>4, :node=>'/ruta/hacia/nodo3')
env4=Enviroment.create(:template=>5, :node=>'/ruta/hacia/nodo4')

cb1=Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
cb2=Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
cb3=Cookbook.create(:name=>'nginx')

r1= Role.create(:name=>"dev", :path=>'/ruta/hacia/roldev')
r2= Role.create(:name=>"admin", :path=>'/ruta/hacia/roladmin')
r3= Role.create(:name=>'otro_rol')

env1.cookbooks << cb1
env1.roles << r2
env1.roles << r1

env2.cookbooks << cb1
env2.cookbooks << cb3
env2.roles << r2
=end

