class Format_cli
 # Sets bold font
	def Format_cli.scr_bold
		print "\33[1m"
	end

	# Sets underline
	def Format_cli.scr_underline
		print "\33[4m"
	end

	# Restore normal font
	def Format_cli.scr_restore
		print "\33[0m"
	end

	# Clears screen
	def Format_cli.scr_cls
		print "\33[2J\33[H"
	end

	# Moves the cursor
	def Format_cli.scr_move(x,y)
		print "\33[#{x};#{y}H"
	end

	# Print header
	def Format_cli.print_header(format,str, underline=true)
		scr_bold
		scr_underline if underline
		my_print(format,str)
		scr_restore
		puts
	end

	def Format_cli.my_print(format,str)
		puts format  %  str
	end

	def Format_cli.print_cb_line(cb)
		str= "%5d %15s %-20s %7d"
		puts str % [cb.id.to_s, "",cb.name,cb.recipes.length]
	end

	def Format_cli.print_env_line(env)
		#Space Limiters
		name_cad=env.name[0..9]
		

		node_cad=path_format(env.node)		
		
		if env.databags!=nil
			data_cad=path_format(env.databags.to_s)
		else
			data_cad="NO"
		end
		

		str= "%3s %-11s %-11s %-24s %-26s"
		puts str % [env.id.to_s,name_cad,env.template.to_s,node_cad, data_cad]

	end


	def Format_cli.print_role_line(role)
		#Space Limiters
		name_cad=role.name[0..9]
		path_cad=path_format(role.path)		
		
		if !role.deps_roles.empty?
			d_roles="YES"
		else
			d_roles="NO"
		end

		if role.deps_recs!=nil
			d_recs="YES"
		else
			d_recs="NO"
		end
		
		str="%3s %-11s %-32s %-10s %-8s"
		puts str % [role.id.to_s,name_cad,path_cad,d_roles, d_recs]

	end

	private	
	def self.path_format(path)
		array_aux=File.split(path)
		sol="/"+array_aux[1]

		length=sol.length		

		while (length<24 && array_aux[0]!="/")
			array_aux=File.split(array_aux[0])
			length=length+array_aux[1].length+1
			if length<24
				sol="/"+array_aux[1]+sol
			end
		end
		return sol
	end

	def Format_cli.view_env(env)
		str= "%-18s %-1s %-24s"
		puts str % ["ID",":",env.id.to_s]
		puts str % ["NAME",":",env.name]
		puts str % ["BASE TEMPLATE",":",env.template.to_s]
		puts str % ["NODE DIR",":",env.node]
		if env.databags != nil
			puts str % ["DATABAG DIR",":",env.databags] 	
		end		
	end	
	
	def Format_cli.view_cb(cb)
		str= "%-18s %-1s %-24s"
		rc=""
		cb.recipes.each{|r| rc += "\n" +"%21s" % "" + r}
		dp=""
		cb.recipes_deps.each do|r,w|
		       dp += "\n"+ "%21s" % "" + r
		       w.map { |i| dp +="'" + i.to_s + "'" }.join(",")
		end
		puts str % ["NAME",":",cb.name]
		puts str % ["PATH",":",cb.path]
		puts str % ["RECIPES",": ",rc ]
		puts str % ["DEPENDENCIES",": ",dp]
	end

	def Format_cli.view_role(role)
		str= "%-24s %-1s %-24s"
		puts str % ["ID",":",role.id.to_s]
		puts str % ["NAME",":",role.name]
		puts str % ["PATH",":",role.path.to_s]
		if role.deps_roles!=nil
			dp=""
			role.deps_roles.each do|r|
		       		dp += "\n"+ "%27s" % "" + r
			end			
			puts str % ["DEPENDENCIES (ROLES)",":",dp]
		end
		if role.deps_recs!=nil
			dp=""
			role.deps_recs.each do|r|
		       		dp += "\n"+ "%27s" % "" + r
			end			
			puts str % ["DEPENDENCIES (RECIPES)",":",dp] 	
		end	
	end

end
