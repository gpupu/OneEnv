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
		puts format + "%" + str
	end

	def Format_cli.print_cb_line(cb)
		str= "%3d %20s %10d"
		puts str % [cb.id.to_s,cb.name,cb.recipes.length]
	end
end
