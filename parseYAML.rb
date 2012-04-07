require 'yaml'

#Aqui he tenido que cambiar el nombre ya que hay una clase igual en database.rb
class Enviroments
	attr_accessor :name, :image, :cookbooks, :ssh, :type, :network, :vnc
	
	def initialize(name, image, cookbooks, ssh, type, network, vnc)
		@name = name
		@image = image
		@cookbooks = cookbooks
		@ssh = ssh
		@type = type
		@network = network
		@vnc = vnc
	end
	
	def to_s
		str = "Name :" + @name.to_s + "\n"  
		str += "Image :" + @image.to_s + "\n"
		str += "Cookboks :" + @cookbooks.to_s + "\n"
		str += "SSH :" + @ssh.to_s + "\n"
		str += "Type :" + @type.to_s + "\n"
		str += "Network :" + @network.to_s + "\n"
		str += "VNC :" + @vnc.to_s + "\n"
		str
	end

end

class Conector_yaml

	def self.yaml2env(path)		
		obj_yaml = YAML::load( File.open( path ) )
		enviroments = []
		if !obj_yaml.nil?
			obj_yaml.each{|env_yaml|
				if !env_yaml.nil?
					name = env_yaml['name']
					image = env_yaml['image']
					cookbooks = env_yaml['cookbooks']
					ssh = env_yaml['ssh']
					type = env_yaml['type']
					network = env_yaml['network']
					vnc = env_yaml['vnc']
					
					env = Enviroments.new(name, image,cookbooks,ssh,type,network,vnc)
					enviroments << env 
				end					
			}
		end

		return enviroments
	end

end



def converter(path)
	if path.nil? then
		puts "FICHERO NO ENCONTRADO\n"
		Process.exit
	else
		c = Conector_yaml.yaml2env(path)
		return c
	end
end

=begin
YAML_NAME_ENV = ARGV[0]
if YAML_NAME_ENV.nil? then
        puts "FICHERO NO ENCONTRADO\n"
        Process.exit
else
        c = Conector_yaml.yaml2env(YAML_NAME_ENV)
        puts c
=end



