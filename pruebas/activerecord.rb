require 'rubygems'
require 'sqlite3'
require 'active_record'

# connect to database.  This will create one if it doesn't exist
MY_DB_NAME = "oneenv.db"
MY_DB = SQLite3::Database.new(MY_DB_NAME)

# get active record set up
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => MY_DB_NAME)

class Cookbook < ActiveRecord::Base
    #has_one :enviroment
    self.connection.create_table(:cookbooks,:force=>true) do |t|
        t.column :name, :string, :null=>false
        t.column :path, :string
    end
end

class Env_db < ActiveRecord::Base
    belongs_to :cookbook
    #set_table_name :enviroments
    self.table_name= 'enviroments'
    self.connection.create_table(:enviroments,:force=>true) do |t|
        # El identificador autonumerado se crea automaticamente
        t.column :name, :string, :default=>'env-' #+:id.to_s
        t.column :ssh, :string, :default=>nil
        t.column :cookbooks, :cookbook
    end
   
end

Cookbook.create(:name=>'emacs', :path=>'/ruta/hacia/emacs')
Cookbook.create(:name=>'vim', :path=>'/ruta/hacia/vim')
Cookbook.create(:name=>'apache', :path=>'/ruta/hacia/apache')

Env_db.create(:name=>'nombre1', :ssh=>'clave1', :cookbooks => Cookbook.find(2))
Env_db.create(:ssh=>'clave2')
Env_db.create(:name=>'nombre3', :ssh=>'clave3', :cookbooks => Cookbook.first(:conditions => {:name => 'emacs'}))

