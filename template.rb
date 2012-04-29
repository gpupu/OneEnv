#!/usr/bin/env ruby

 
##############################################################################
# Required libraries
##############################################################################
ONE_LOCATION=ENV["ONE_LOCATION"]
SCRIPT_DIR = './arranque_vm/'
 
if !ONE_LOCATION
    RUBY_LIB_LOCATION="/usr/lib/one/ruby"
else
    RUBY_LIB_LOCATION=ONE_LOCATION+"/lib/ruby"
end
 
$: << RUBY_LIB_LOCATION

require 'OpenNebula'
include OpenNebula


##############################################################################
# Environment Configuration
##############################################################################

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
		
		script_init= File.expand_path(SCRIPT_DIR) + '/init.sh'
		script_chef= File.expand_path(SCRIPT_DIR) + '/chef.sh'

		files = path_repo + " " + path_json + " " + script_init + " " + script_chef
		target= "vdb"

		###EDITAR CONTEXTO
		if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").empty?
			if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").empty?
				##EXITE EL NODO FILES
				puts "HAY FILES"
				data_files_old=xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").first
				files = data_files_old.content + " " + files
				data_files=Nokogiri::XML::CDATA.new(doc,files)
				
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").first.child.remove
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").first <<  data_files

				node_target=createNodeTarget doc, target
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << node_target
				

			else
				#NO EXISTE NODO FILES
				node_files = createNodeFiles doc, files
				node_target=createNodeTarget doc, target
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << node_files
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << node_target

			end
		else		
			##NO EXISTE NODO CONTEXT
			node_files= createNodeFiles doc, files
			node_target=createNodeTarget doc, target
			node_context=createNodeContext doc, node_files, node_target
			xml.xpath("//VMTEMPLATE//TEMPLATE").first << node_context	

		end
#=begin
	
	

		template = Template.new(xml,@client)
		xml_string = template.template_str



		vm = VirtualMachine.new(VirtualMachine.build_xml,@client)
		rc = vm.allocate(xml_string)



		if OpenNebula.is_error?(rc)
			  puts "#{rc.message}"   
		end



#=end

	end



end

private
def createNodeFiles doc,files
	puts "NO HAY FILES"		
	node_files=Nokogiri::XML::Node.new("FILES", doc)
	data_files=data=Nokogiri::XML::CDATA.new(doc,files)
	node_files << data_files
	return node_files
end

private
def createNodeContext doc, node_files, node_target
	puts "NO HAY CONTEXT"
	node_context=Nokogiri::XML::Node.new("CONTEXT", doc)
	node_context << node_target
	node_context << node_files
	return node_context
end

private
def createNodeTarget doc, target
	node_target=Nokogiri::XML::Node.new("TARGET", doc)
	data_target=data=Nokogiri::XML::CDATA.new(doc,target)		
	node_target << data_target
	return node_target
end


end

=begin
c= ConectorONE.new
c.crearTemplate(10,"/var/lib/one/init.sh /home/david/solodemo/cookbooks","")
=end


