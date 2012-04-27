#!/usr/bin/env ruby

 
##############################################################################
# Required libraries
##############################################################################



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

require 'OpenNebula'
include OpenNebula

# OpenNebula credentials
CREDENTIALS = "oneadmin:nebula"
# XML_RPC endpoint where OpenNebula is listening
ENDPOINT    = "http://localhost:2633/RPC2"


class ConectorONE

:client

		 
	def initialize 

		@client = Client.new(CREDENTIALS, ENDPOINT)
	
		
	end


	def crearTemplate(num_template,path_repo,path_json)

		xml_s=""

		template_pool= TemplatePool.new(@client, -1)
		rc= template_pool.info

		if OpenNebula.is_error?(rc)
			  puts "#{rc.message}"   
		end

		template_pool.each do |tmp|	
			if tmp['ID'] == num_template.to_s
				xml_s = tmp.to_xml

			end
		end
		

	if xml_s!=""



		xml =XMLElement.build_xml(xml_s, "VMTEMPLATE")
		doc = Nokogiri::XML::Document.new
	
		files = path_repo + " " + path_json
		target= "vdc"

		###EDITAR CONTEXTO
		if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").empty?
			if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").empty?
				puts xml.xpath("//VMTEMPLATE//CONTEXT//FILES")
			else
				puts "NO HAY FILES"		
				node_files=Nokogiri::XML::Node.new("FILES", doc)
				data_files=data=Nokogiri::XML::CDATA.new(doc,files)
		
				node_files << data_files
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << node_files
				puts xml
			end
		else
			puts "NO HAY CONTEXT"
		
			node_context=Nokogiri::XML::Node.new("CONTEXT", doc)
			node_files=Nokogiri::XML::Node.new("FILES", doc)
			node_target=Nokogiri::XML::Node.new("TARGET", doc)

			data_target=data=Nokogiri::XML::CDATA.new(doc,target)		
			data_files=data=Nokogiri::XML::CDATA.new(doc,files)
		
			node_target << data_target
			node_files << data_files

			node_context << node_target
			node_context << node_files
			xml.xpath("//VMTEMPLATE//TEMPLATE").first << node_context
			puts xml
		
		end

	
	

		template = Template.new(xml,@client)
		xml_string = template.template_str



		vm = VirtualMachine.new(VirtualMachine.build_xml,@client)
		rc = vm.allocate(xml_string)



		if OpenNebula.is_error?(rc)
			  puts "#{rc.message}"   
		end


		end


	end

end
=begin
c= ConectorONE.new
c.crearTemplate(10,"/var/lib/one/init.sh /home/david/solodemo/cookbooks","")
=end

