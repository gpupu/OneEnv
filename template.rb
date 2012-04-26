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


=begin
#Comprueba si existe la template indicada
begin
	template_pool.each do |tmp|
		if tmp['ID'] == num_template
			puts tmp.template_xml

		end
	end
end
=end


xml_s = "<VMTEMPLATE>
  <ID>4</ID>
  <UID>0</UID>
  <GID>0</GID>
  <UNAME>oneadmin</UNAME>
  <GNAME>oneadmin</GNAME>
  <NAME>my_vm</NAME>
  <PUBLIC>1</PUBLIC>
  <REGTIME>1321289327</REGTIME>
  <TEMPLATE>
    <CONTEXT>
      <FILES><![CDATA[/var/lib/one/init.sh]]></FILES>
      <TARGET><![CDATA[hdc]]></TARGET>
    </CONTEXT>
    <CPU><![CDATA[1]]></CPU>
    <DISK>
      <IMAGE_ID><![CDATA[27]]></IMAGE_ID>
    </DISK>
    <DISK>
      <SIZE><![CDATA[1024]]></SIZE>
      <TYPE><![CDATA[swap]]></TYPE>
    </DISK>
    <GRAPHICS>
      <LISTEN><![CDATA[0.0.0.0]]></LISTEN>
      <TYPE><![CDATA[vnc]]></TYPE>
    </GRAPHICS>
    <MEMORY><![CDATA[1024]]></MEMORY>
    <NIC>
      <NETWORK_ID><![CDATA[10]]></NETWORK_ID>
    </NIC>
    <TEMPLATE_ID><![CDATA[8]]></TEMPLATE_ID>
  </TEMPLATE>
</VMTEMPLATE>"



xml =XMLElement.build_xml(xml_s, "VMTEMPLATE")
puts xml.class

template = Template.new(xml,client)
xml_string = template.template_str
puts xml_string

###EDITAR CONTEXTO

vm = VirtualMachine.new(VirtualMachine.build_xml,client)
rc = vm.allocate(xml_string)
rc = vm.deploy(46)

if OpenNebula.is_error?(rc)
          puts "#{rc.message}"   
end

exit 0


