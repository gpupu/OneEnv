require 'database.rb'
require 'format_cli'

class OneRoleHelper
		def self.addDir(c_path)		
			path = File.expand_path(c_path)
			if File.exists?(path)
				roles = Dir.entries(path)
				puts roles
				roles.each do |r|
					Role.role_create(r,path) if File.extname(r) == ".rb" || File.extname(r) == ".json"

				end
			else
				puts path + ' don\'t exists'
			end
		end

		def self.add(r_path)		
			path = File.expand_path(r_path)
			if File.exists?(path)
				role = File.basename(path)
				path = File.dirname(path)
				Role.role_create(role,path) if File.extname(role) == ".rb" || File.extname(role) == ".json"
			else
				puts path + ' don\'t exists'
			end
		end


		def self.update_role(idRole,nameRole)
			if(!nameRole.nil?)
				role=Role.getRoleByName(nameRole)
			elsif(!idRole.nil?)	
				role=Role.getRoleById(idRole)	
			end

			if role!=nil
				role.update_role
			end
		end

		def self.list()
			str_h1="%3s %-11s %-32s %-10s %-8s"
			str=["ID","NAME","PATH","ROL_DEPS","REC_DEPS"]
			Format_cli.print_header(str_h1,str,true)
            		Role.find(:all).each{|r|
                		Format_cli.print_role_line(r)
            		}
		end

		def self.show(idRole,nameRole)
			if(!nameRole.nil?)
				role=Role.getRoleByName(nameRole)
			elsif(!idRole.nil?)	
				role=Role.getRoleById(idRole)	
			end

			if role!=nil
				str_h1="%-70s"
				str=["ROLE #{role.id} INFORMATION"]
				Format_cli.print_header(str_h1,str,true)
				Format_cli.view_role(role)
			end			
		end


		def self.delete(idRole,nameRole)
			if(!nameRole.nil?)
				role=Role.getRoleByName(nameCB)
			elsif(!idRole.nil?)	
				role=Role.getRoleById(idRole)	
			end
			if role!=nil
				role.delete
			end
		end


end
