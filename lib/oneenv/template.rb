# --------------------------------------------------------------------------#
# Copyright 2012   David Baena, Fernando Martínez-Conde, José Gabriel Puado	#
# 																			#
# Licensed under the Apache License, Version 2.0 (the "License"); you may 	#
# not use this file except in compliance with the License. You may obtain 	#
# a copy of the License at 													#
# 																			#
# http://www.apache.org/licenses/LICENSE-2.0 								#
# 																			#
# Unless required by applicable law or agreed to in writing, software 		#
# distributed under the License is distributed on an "AS IS" BASIS, 		#
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 	#
# See the License for the specific language governing permissions and 		#
# limitations under the License. 											#
#---------------------------------------------------------------------------#

 
##############################################################################
# Required libraries
##############################################################################
 
if !ONE_LOCATION
    LIB_LOCATION="/usr/lib/one"
else
    LIB_LOCATION=ONE_LOCATION+"/lib"
end
SCRIPT_DIR=LIB_LOCATION+"/sh/start_env"


require 'OpenNebula'
include OpenNebula


##############################################################################
# Environment Configuration
##############################################################################

ENDPOINT    = "http://localhost:2633/RPC2"


class ConectorONE

:client		 
	def initialize 
		@client = Client.new(nil,ENDPOINT)		
	end


	def crearTemplate(num_template,path_repo,path_json,path_databags,path_chef,list_resources)

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


		if xml_s==""
			puts "Template: " + num_template.to_s + " don\'t exists"
			exit -1
		end

			xml =XMLElement.build_xml(xml_s, "VMTEMPLATE")
			doc = Nokogiri::XML::Document.new
		
			script_init= File.expand_path(SCRIPT_DIR) + '/init.sh'
			script_chef= File.expand_path(SCRIPT_DIR) + '/chef.sh'
			puts script_init

			

			files = path_repo + " " + path_json + " " + script_init + " " + script_chef

			target= "vdb"

			###EDITAR CONTEXTO
			if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").empty?
				if !xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT//FILES").empty?
					##EXITE EL NODO FILES
					
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

			# Introduce el nombre del node
			name = File.basename(path_json)	# no nos importa quedarnos también con la extension
			node_name = createContextVariable doc, "CHEF_NODE", name
			xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << node_name

		puts "ELEMENTOS EN EL TEMPLATE:"
		puts "COOKBOOKS"
		puts  list_resources.cookbooks_list

		puts "ROLES"
		puts  list_resources.role_list

			# Introducimos nombres de las cookbooks y de los roles
			if !list_resources.cookbooks_list.empty?
				cb_names = createContextVariable doc, "CHEFCB", list_resources.get_sh_cb_list 
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << cb_names
			end

			if !list_resources.role_list.empty?
			
				r_names = createContextVariable doc, "CHEFR", list_resources.get_sh_role_list 
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << r_names
			end
	

			# Introduce el path de la ruta chef	
			dir_chef = createContextVariable doc, "CHEF_DIR", path_chef
			xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << dir_chef

			if path_databags != nil
				# Introduce el nombre del directorio databags
				dir_db = createContextVariable doc, "CHEF_DATABAGS", File.basename(path_databags)
				xml.xpath("//VMTEMPLATE//TEMPLATE//CONTEXT").first << dir_db
			end
			

			template = Template.new(xml,@client)
			xml_string = template.template_str


			vm = VirtualMachine.new(VirtualMachine.build_xml,@client)
			rc = vm.allocate(xml_string)
		

			if OpenNebula.is_error?(rc)
				  puts "#{rc.message}"   
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

	private
	def createContextVariable doc, name, value
		node_name = Nokogiri::XML::Node.new(name, doc)
		data_name=data=Nokogiri::XML::CDATA.new(doc,value)		
		node_name << data_name
		return node_name
	end


end
