require 'database.rb'
require 'validation/validation'
require 'parseYAML'

class Shell
    def initialize()
        @arguments = []
    end

    def run()
        nextOrder = prompt
        while (nextOrder)
            catch (:callCommand) do
                throw :callCommand if nextOrder.length == 0
                command = nextOrder.shift()
                @arguments = nextOrder

                begin
                    currentCommand = method(command)
                rescue NameError
                    puts "Command not found"

                    throw :callCommand
                end

                begin
                    currentCommand.call()
                rescue ArgumentError
                    puts "Argument error"
                rescue SystemExit
                    puts "... bye!"
                    Process.exit!(true)
                rescue Exception => unknownError
                    puts "Unknown Error: #{unknownError.message}"
                end
            end
            nextOrder = prompt
        end
    end

    def prompt()
        print "\n>"
        gets.chomp().split(' ')
    end

    def quit()
        raise SystemExit
    end

	def oneenv()
        raise ArgumentError if @arguments.length == 0

		case @arguments[0]

		##USO: oneenv create [YAML] 
		when 'create'
			raise ArgumentError if @arguments.length != 2
			cad2=@arguments[1]
			#Aqui se comprueba si el fichero es valido. He puesto como que haya que meter obligatoriamente el fichero por parametro. El metodo 				validationYAML esta en validation.rb		
			if validationYAML(cad2)
				#converter es el metodo de parseYAML.rb
				aux=converter(cad2)
				aux.each do |f|
					#Para cada elemento de la lista de entornos hacemos un add
					Enviroment.add(f)
				end
			else 
				'No se ha podido crear'
			end

		##USO:oneenv list
		when 'list'
			raise ArgumentError if @arguments.length != 1
			puts "ID\tNAME\tIMAGE\tTYPE\tSSH\tNETWORK\tCOOKBOOKS"
           		Enviroment.find(:all).each do |e|
				puts e.to_s
			end
		##USO:oneenv show [ID_Env]
		when 'show'
			raise ArgumentError if @arguments.length != 2
			puts "ID\tNAME\tIMAGE\tTYPE\tSSH\tNETWORK\tCOOKBOOKS"

			####!!!MIRAR SI EXISTE!!!
           		e =Enviroment.find(@arguments[1])
			puts e.to_s
		##USO:oneenv delete [ID_Env]
		when 'delete'
			raise ArgumentError if @arguments.length != 2
			if Enviroment.exists?(@arguments[1])
				Enviroment.delete(@arguments[1])
			else
				puts 'This enviroment don\'t exists'
			end

		##USO:oneenv clone [ID_Env]
		when 'clone'
			raise ArgumentError if @arguments.length != 2
			if Enviroment.exists?(@arguments[1])
				Enviroment.clone_env(@arguments[1])
			else
				puts 'This enviroment don\'t exists'
			end


		when 'add-ssh'

		when 'update-ssh'


		##USO:oneenv up [ID_entorno]
		when 'up'


		##USO:oneenv add-cookbook [ID_entorno] [cb_name]
		when 'add-cookbook'
			raise ArgumentError if @arguments.length != 3
			if Enviroment.exists?(@arguments[1])
				Enviroment.add_cookbook(@arguments[1],@arguments[2])
			else
				puts 'This enviroment don\'t exists'
			end


		when 'update-cookbook'

		##USO:oneenv delete-cookbook [ID_entorno] [cb_name]
		when 'delete-cookbook'
			raise ArgumentError if @arguments.length != 3
			if Enviroment.exists?(@arguments[1])
				Enviroment.delete_cookbook(@arguments[1],@arguments[2])
			else
				puts 'This enviroment don\'t exists'
			end

		else
			raise ArgumentError

		end

	end

	def onecook()
		raise ArgumentError if @arguments.length == 0

		case
		when @arguments[0] == 'list'
			raise ArgumentError if @arguments.length != 1
			#puts 'dentro de la lista'
		    puts "ID\tNAME\tPATH\tPLACE"
            Cookbook.find(:all).each do |cb|
                puts cb.to_s
            end

		when @arguments[0] == 'create' && @arguments[1] != '--from-repo'
			#puts 'esto es una prueba sin repo'
			raise ArgumentError if @arguments.length != 2 && @arguments.length != 3
			Cookbook.cb_create(@arguments[1],@arguments[2],false)

		when @arguments[0] == 'create' && @arguments[1] == '--from-repo'
			#puts 'esto es una prueba CON repo'
			raise ArgumentError if @arguments.length != 3 && @arguments.length != 4
			Cookbook.cb_create(@arguments[2],@arguments[3],true)

		when @arguments[0] == 'update' && @arguments[1] != '--from-repo'			
			raise ArgumentError if @arguments.length != 2 && @arguments.length != 3

			if Cookbook.exists?(:name => @arguments[1])
				cb = Cookbook.first(:conditions => {:name => @arguments[1]})
				Cookbook.update(cb.id, {:path=> @arguments[2], :place => 'L'})
			else
				puts 'This cookbook don\'t exists'
			end

		when @arguments[0] == 'update' && @arguments[1] == '--from-repo'
			raise ArgumentError if @arguments.length != 3 && @arguments.length != 4

			if Cookbook.exists?(:name => @arguments[2])
				cb = Cookbook.first(:conditions => {:name => @arguments[2]})
				Cookbook.update(cb.id, {:path=> @arguments[3], :place => 'R'})
			else
				puts 'This cookbook don\'t exists'
			end

		when @arguments[0] == 'delete'
			raise ArgumentError if @arguments.length != 2
			if Cookbook.exists?(:name => @arguments[1])
				Cookbook.delete_all(:name => @arguments[1])
			else
				puts 'This cookbook don\'t exists'
			end

		else
			raise ArgumentError

		end
	end

    def help()
        puts 'ayuda'
            #command1 executes the command1
            #command2 [ARGUMENT] executes the command2
            #help  Shows this help.
            #quit/exit  Exit the shell.
    end

end



Shell.new.run
