require 'oneenv.rb'
require 'onecook.rb'

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
		OneEnv.run(@arguments)

	end

	def onecook()
		raise ArgumentError if @arguments.length == 0
		OneCook.run(@arguments)
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
