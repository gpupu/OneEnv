require 'rubygems'
require 'sqlite3'
require 'active_record'
require 'yaml'

# connect to database.  This will create one if it doesn't exist
MY_DB_NAME = "oneenv.db"
MY_DB = SQLite3::Database.new(MY_DB_NAME)

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)

#Pongo esto aquí de forma provisional para no tocarle nada a bae
class EnvDescription
	attr_accessor :name, :image, :ssh, :type, :network, :vnc
	
	def initialize(name, image, ssh, type, network, vnc)
		@name = name
		@image = image
		#@cookbooks = cookbooks
		@ssh = ssh
		@type = type
		@network = network
		@vnc = vnc
	end
	
	def to_s
		str = "Name :" + @name.to_s + "\n"  
		str += "Image :" + @image.to_s + "\n"
		str += "SSH :" + @ssh.to_s + "\n"
		str += "Type :" + @type.to_s + "\n"
		str += "Network :" + @network.to_s + "\n"
		str += "VNC :" + @vnc.to_s + "\n"
		str
	end

end

class Cookbook < ActiveRecord::Base
    after_create :create_defaults
    has_and_belongs_to_many :enviroments 
    validates_uniqueness_of :name
    # Obliga a que el campo :place sea R o L
    validates :place, :inclusion => {:in=> ['R', 'L'], :message=> "%{value} no es un valor correcto" }

    def create_defaults
        conf = YAML.load_file('oneenv.cnf')
        #puts conf['default_local']
        if self.path == nil
            if self.place.eql?('R')
                self.path = conf['default_repository']
            else
                self.path = conf['default_local']
            end
        end
    end

end


class Enviroment < ActiveRecord::Base
    has_and_belongs_to_many :cookbooks
    serialize :description
end

class CreateSchema < ActiveRecord::Migration

    create_table(:cookbooks,:force=>true) do |t|
        t.column :name, :string, :null=>false, :unique=>true
        t.column :path, :string, :default=>nil
        # Parece ser que type esta reservado por ruby, cambiado por place
        t.column :place, :string, :default=>'L', :limit=>1
        t.column :enviroments, :enviroment #, :foreign_key=>true
    end

    create_table(:enviroments, :force=>true) do |t|
        # El identificador autonumerado se crea automaticamente
        t.column :name, :string, :default=>'env-' #+ (last.id-1).to_s
        t.column :description, :string, :default=>nil
        t.column :cookbooks, :cookbook #, :foreign_key=> true #, :default=>nil
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
#=end

=begin
ent1 = Env_db.create(:ssh=>'clave1')
ent2 = Env_db.create(:ssh => 'clave2')

ent1.cookbooks.create(:name=>'vim', :path=>'/ruta/hacia/vim')
ent1.cookbooks.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
=end

desc1 = Enviroment.find(1).description
desc2 = Enviroment.find(2).description
desc3 = Enviroment.find(3).description

puts desc1.to_s
puts desc2.to_s
puts desc3.to_s
