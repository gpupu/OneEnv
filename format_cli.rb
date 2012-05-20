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
		str= "%3d %20s %10d"
		puts str % [cb.id.to_s,cb.name,cb.recipes.length]
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
end
