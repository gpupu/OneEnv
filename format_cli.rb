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
		data_cad=path_format(env.databags.to_s)
	
		#Extra sized path
		node_length=node_cad.length
		data_length=data_cad.length		
		space=false

		if data_cad.length==0
			data_cad.push "NO"
		end				
		

		str= "%3s %-11s %-11s %-24s %-26s"
		puts str % [env.id.to_s,name_cad,env.template.to_s,node_cad[0], data_cad[0]]

		#Lo he dividido para que el path salga en varias lineas, que si no se descuadra todo muchisimo
		i=1		
		while(i<data_length || i<node_length)

			space=true
			if(i<node_length)
				s1= node_cad[i]
			end
			if(i<data_length)
				s2= data_cad[i]
			end
			str= "%27s %-24s %-26s"
			puts str % ["",s1,s2]
			i=i+1
		end		
		if space
			puts
		end

	end

	private	
	def self.path_format(str)
		sol = Array.new
		words=str.scan(/\w+/)
		dst=0
		s=""
		words.each{|w|
				if (dst + w.length<20)
					s+="/" + w
					dst+=w.length
				else
					sol.push s
					s="/" + w
					dst=w.length
				end	
		}
		if s!=""
			sol.push s
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
