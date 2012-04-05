require 'database.rb'

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

    def command1()
        puts "Executing command1"
    end

    def command2()
        raise ArgumentError if @arguments.length == 0
        puts "Executing command2"
    end

    def oneenv()
        raise ArgumentError if @arguments.length == 0

		case @arguments[0]
		when 'create'

		when 'list'
			raise ArgumentError if @arguments.length != 1
		    puts "NAME\tIMAGE\tTYPE\tSSH\tNETWORK"
            Enviroment.find(:all).each do |e|
                puts e.to_s
                #puts
            end
		
		when 'delete'
			raise ArgumentError if @arguments.length != 2
			if Enviroment.exists?(@arguments[1])
				Enviroment.delete(@arguments[1])
			else
				puts 'This enviroment don\'t exists'
			end

		when 'clone'
			raise ArgumentError if @arguments.length != 2
			if Enviroment.exists?(@arguments[1])
				Enviroment.clone_env(@arguments[1])
			else
				puts 'This enviroment don\'t exists'
			end

		when 'add-ssh'
		when 'update-ssh'
		when 'up'
		when 'add-cookbook'
		when 'update-cookbook'
		when 'delete-cookbook'
			raise ArgumentError if @arguments.length != 3
			if Enviroment.exists?(@arguments[1])
				Enviroment.delete_cookbook(@arguments[1],@arguments[2])
			else
				puts 'This enviroment don\'t exists'
			end

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
