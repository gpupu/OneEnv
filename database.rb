require 'rubygems'
#require 'sqlite3'
require 'active_record'
require 'check_deps.rb'


# connect to database.  This will create one if it doesn't exist
#MY_DB_NAME = "oneenv.db"
#MY_DB = SQLite3::Database.new(MY_DB_NAME)

CONFIG_FILE = 'oneenv.cnf'
CONFIG = YAML.load_file(CONFIG_FILE)

# TODO Cuidado con esto!! ¿mantiene valor si se cambia el archivo de configuración?
CB_DIR = File.expand_path(CONFIG['default_cb_dir'])
ROLE_DIR = File.expand_path(CONFIG['default_role_dir'])
#SOLO_DIR = CONFIG['default_solo_path']

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "oneenv.db")



class Cookbook < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
    serialize :recipes, Array
	serialize :recipes_deps, Hash


	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s += recipes.to_s + "\t"
		s += show_deps_list(recipes_deps) + "\t"
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
				iscopy = true
				if cb_path != CB_DIR
					cp_com = "cp -r #{dir_recipes} #{CB_DIR}" 
					puts cp_com
					iscopy = system(cp_com)
					#FileUtils.cp_r(dir_recipes,CB_DIR)
				end
				if iscopy
					create(:name => cb_name, :path => cb_path, :recipes => get_recipes(dir_recipes), :recipes_deps=>find_deps2(dir_recipes))
				else
					puts "copying cookbook #{cb_name} failed"
				end
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
	def self.isCookbook? cb_dir
		if File.directory?(cb_dir)
			cont= Dir.entries cb_dir
			# es cookbook si incluye un archivo metadata.rb
			cont.include?('metadata.rb')
		end
	end

	public 
	def update
		recipes = get_recipes path
	end

	public
	def self.view cb_name
		cb=first(:conditions => {:name => cb_name})
		if !cb.nil?
			s  = "NAME:\t" + cb.name + "\n"
			s += "PATH:\t" + cb.path + "\n"
			s += "RECIPES: " + "\t"
				cb.recipes.each{|r| s += ", " + r }
			s += "DEPS: " + "\t"
				cb.deps.each{|r| s += ", " + r }

			s += "\n"
		else
			s +='Can\'t find the cookbook ' + cb_name
		end
		s
	end


end

class Role < ActiveRecord::Base
    validates_uniqueness_of :name
    has_and_belongs_to_many :enviroments, :uniq => true
	serialize :deps_roles, Array
	serialize :deps_recs, Array

	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t"
		s += path + "\t"
		s += deps_roles.to_s + "\t"
		s += deps_recs.to_s + "\t"
	end

	public
	def self.role_create r_name, r_path
		if r_path == nil 
			r_path = ROLE_DIR
		end

		if !exists?(:name=>r_name)
			r_path = File.expand_path(r_path)
			if File.exists?(r_path)
				iscopy = true
				# Copiar rol en el directorio por defecto
				if r_path != ROLE_DIR
					cp_com = "cp #{r_path} #{ROLE_DIR}"
					puts cp_com
					iscopy = system(cp_com)
					#FileUtils.cp(r_path, ROLE_DIR)
				end
				if iscopy
					if File.extname(r_path) == ".rb"
						rdeps = get_ruby_runl(r_path)
					end
					if File.extname(r_path) == ".json"
						rdeps = get_json_runl(r_path)
					end
					puts rdeps
					
					#dividimos en recetas y roles
					roles_list = []
					recs_list = []
					rdeps.each do |d|
						if d.start_with?('role')
							d = d[5..-2]	#toma solo el interior
							roles_list.push d
						end
						if d.start_with?('recipe')
							d = d[7..-2]	#toma solo el interior
							recs_list.push d
						end
					end

					create(:name=> r_name.to_s, :path=> r_path, :deps_roles=>roles_list, :deps_recs=>recs_list )
				else
					puts "copying role #{r_name} failed"
				end

			else
				puts r_path + ' is not a correct path'
			end
		else
			puts r_name + ' is yet on the database'
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
    end

	public
	def self.view_enviroment id
		env=first(:conditions => {:id => id})
		if !env.nil?
			s  = "ID:\t" + env.id.to_s + "\n"
			s += "NAME:\t" + env.name + "\n"
			s += "BASE TEMPLATE:\t" + env.template.to_s + "\n"
			if env.databags != nil
				s += "DATABAG DIR:\t" + env.databags + "\n" 
			end
			s += "COOKBOOKS: " + "\t"
			env.cookbooks.each{|cb| s += ", " + cb.name }
			s += "\n"
			s += "ROLES:" + "\t"
			env.roles.each{|r| s += ", " + r.name}
			s += "\n"
		else
			s +='Can\'t find the enviroment ' + id.to_s
		end
		s
	end

	public
	def clone
		envcopy = Enviroment.create(:template=> self.template, :node=> self.node, :databags=> self.databags)
	end

end

class CreateSchema < ActiveRecord::Migration

if !table_exists?(:cookbooks)
    create_table(:cookbooks) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>CB_DIR
        t.text :recipes
		t.text :recipes_deps
        #t.column :enviroments, :enviroment
    end
end

if !table_exists?(:roles)
	create_table(:roles) do |t|
		t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>ROLE_DIR
		t.text :deps_roles
		t.text :deps_recs
        #t.column :enviroments, :enviroment
	end
end

if !table_exists?(:enviroments)
    create_table(:enviroments) do |t|
        t.column :name, :string, :default=> nil,:unique=>true
		t.column :template, :integer, :null=> false
		t.column :node, :string, :null=> false
		#t.column :solo_path, :string, :default=>SOLO_DIR
		t.column :databags, :string, :default=> nil
		#t.column :roles, :role
		#t.column :cookbooks, :cookbook
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
