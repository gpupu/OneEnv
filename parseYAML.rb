require 'yaml'
require 'oneenv.rb'

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
					

					des = Description.new(image,ssh,type,network,vnc)
					env = Enviroment2.new(name,des,cookbooks)
			                # Guarda el entorno en el array
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
end
=end



