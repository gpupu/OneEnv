#!/usr/bin/env ruby

require 'rubygems'
#require 'sqlite3'
require 'active_record'


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



	public
	def to_s
		s  = id.to_s + "\t"
		s += name + "\t\t\t"
		#s += path + "\t"
		s += recipes.length.to_s + "\t"
		s
	end

	public
        def self.cb_create cb_name , cb_path

                if cb_path == nil
			isextern = false
			source=CB_DIR + '/' + cb_name
			dest=CB_DIR
		else
			isextern=true
			source=cb_path + '/' + cb_name
			dest=CB_DIR
                end

		

                if !exists?(:name => cb_name)

                        if File.exists?(source)
                               
				iscopy=true
                                if isextern
                                        cp_com = "cp -r #{source} #{dest}" 
                                        puts cp_com
                                        iscopy = system(cp_com)
                                end
				
                                if iscopy
					source = CB_DIR + '/' + cb_name
                                        create(:name => cb_name, :path => source, :recipes => get_recipes(source))
                                else
                                        puts "copying cookbook #{cb_name} failed"
                                end
                        else
                                puts source + ' is not a correct path'
                        end
                else
                        puts cb_name + ' is yet on the database'
                end
        end

	public
	def self.get_recipes path
		r_path = path   + '/recipes'
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
	def self.getCookbook cb_id
		if Cookbook.exists?(:id => cb_id)
			cb=Cookbook.first(:conditions=>{:id=>cb_id})
			return cb					
		else
			puts 'Can\'t find the cookbook: ' + cb_id
			return nil
		end
	end

	public 
	def self.update cb
		cb.recipes = Cookbook.get_recipes(cb.path)
		cb.save
	end
		
	public
	def self.view cb
		if !cb.nil?
			s  = "NAME:\t" + cb.name + "\n"
			s += "PATH:\t" + cb.path + "\n"
			s += "RECIPES:\t" 
			  cb.recipes.each{|r| s += "\n " + r }
			s += "\n"
			s += "\nDEPENDENCIES:\t"
				cb_name = cb.name
				deps = find_deps(CB_DIR + '/' + cb_name )
				clean_deps(deps)
			s += list_deps(deps)
		else
			s +='Can\'t find the cookbook ' + cb_name
		end
		s
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
				iscopy = true
				# Copiar rol en el directorio por defecto
				if r_path != ROLE_DIR
					cp_com = "cp #{r_path} #{ROLE_DIR}"
					puts cp_com
					iscopy = system(cp_com)
					#FileUtils.cp(r_path, ROLE_DIR)
				end
				if iscopy
					create(:name=> r_name, :path=> r_path)
				else
					puts "copying role #{r_name} failed"
				end

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
		self.cookbooks.each{|cb|
			envcopy.cookbooks << cb
		}
		self.roles.each{|r|
			envcopy.roles << r
		}
	end

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
		#t.column :solo_path, :string, :default=>SOLO_DIR
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
