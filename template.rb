##PRECONDICION:
	## Nombre entorno: Cadena caractes
	## Numero Template: Numero
	## Cookbooks: Array con PATH de los Cookbooks
	## Node.joson: Archivo correcto para la contextualizacion
##PARAMETROS: Nombre Entorno, Numero Template, Cookbooks, Node.json

##POSTCONDICION: 
	#Creada una template en formato XML lista para instanciar

#!/usr/bin/env ruby
 
##############################################################################
# Environment Configuration
##############################################################################
ONE_LOCATION=ENV["ONE_LOCATION"]
 
if !ONE_LOCATION
    RUBY_LIB_LOCATION="/usr/lib/one/ruby"
else
    RUBY_LIB_LOCATION=ONE_LOCATION+"/lib/ruby"
end
 
$: << RUBY_LIB_LOCATION
 
##############################################################################
# Required libraries
##############################################################################
require 'OpenNebula'
 
include OpenNebula
 
# OpenNebula credentials
CREDENTIALS = "oneadmin:nebula"
# XML_RPC endpoint where OpenNebula is listening
ENDPOINT    = "http://localhost:2633/RPC2"
 
client = Client.new(CREDENTIALS, ENDPOINT)

template_pool = TemplatePool.new(client, -1)
 
rc = template_pool.info
if OpenNebula.is_error?(rc)
     puts rc.message
     exit -1
end

=begin
nom_entorno = ARGV[0]
num_template = ARGV[1]
cookbooks = ARGV[2]
json = ARGV[3]
=end

num_template = ARGV[0]

xml_s=""

template_pool.each do |tmp|
	if tmp['ID'] == num_template
		xml_s = tmp.to_xml
	end
end

if xml_s!=""
xml =XMLElement.build_xml(xml_s, "VMTEMPLATE")
puts xml.class


template = Template.new(xml,client)
###EDITAR CONTEXTO
xml_string = template.template_str



vm = VirtualMachine.new(VirtualMachine.build_xml,client)
rc = vm.allocate(xml_string)



if OpenNebula.is_error?(rc)
          puts "#{rc.message}"   
end
end
exit 0


