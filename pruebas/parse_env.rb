require 'rubygems'
require 'active_record'
require 'base64'



MY_DB_NAME = "oneenv.db"

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)


#Enviroment
class Enviroment < ActiveRecord::Base
	has_many :cookbook

	##BASE DE DATOS
	self.connection.create_table(:enviroments,:force=>true) do |t|
		# El identificador autonumerado se crea automaticamente
		t.column :name, :string, :default=>'env-' #+:id.to_s
		t.column :description, :string,:null=>false
	end

	
end

#Description
class Description
	attr_accessor :image, :ssh, :type, :network, :vnc

	def initialize(image,ssh,type,network,vnc)
		@image=image
		@ssh=ssh
		@type=type
		@network=network
		@vnc=vnc
	end

	def self.to_64(obj)
		serialized_object = Marshal::dump(obj)
		to_64 = Base64.encode64(serialized_object)
		to_64
	end
		
	def self.to_o(base64)
		to_str = Base64.decode64(base64)
		object = Marshal::load(to_str)
		object
	end
end


#Cookbook
class Cookbook < ActiveRecord::Base
	has_many :enviroment

	self.connection.create_table(:cookbooks,:force=>true) do |t|
		t.column :name, :string, :null=>false
		t.column :path, :string
	end
	
	def to_s
		str += :name +" "+:path		
		str
	end
end



descript = Description.new(2,"/path/to/ssh/.idpub","small", 3,"yes")
descript64 = Description.to_64 descript
Enviroment.create(:name=>'cosa', :description=>descript64)

puts Enviroment.find(1).name
puts Enviroment.find(1).description





