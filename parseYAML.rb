require 'yaml'
require 'oneenv.rb'

class Conector_yaml

	def self.yaml2env(path)		
		obj_yaml = YAML::load( File.open( path ) )
		descriptions = []
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
					
                    #TODO Hay que ver como guardamos los cookbooks, estos no van en la descripcion 
			##SE TIENE QUE USAR UN OBJETO ENTORNO QUE RECOJA TODA LA INFORMACION DEL YAML, Y LUEGO PASARSELO A LA CLASE ENTORNODB

					env = Enviroment2.new(name,Integer(image),cookbooks,ssh,type,network,vnc)
                    # Guarda la descripcion en el array
					descriptions << env 
				end					
			}
		end

		return descriptions
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



