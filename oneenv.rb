

class Enviroment
	attr_accessor :name, :description, :cookbooks
	
	def initialize(name, description, cookbooks)
		@name = name
		@description = description
		@cookbooks = cookbooks
	end
	
	def to_s
		str = "Name :" + @name.to_s + "\n"  
		str += description.to_s  + "\n"
		str += "Cookboks :" + @cookbooks.to_s + "\n"
		str
	end

end



class Description
	attr_accessor :image, :ssh, :type, :network, :vnc
	
	def initialize(image, ssh, type, network, vnc)
		@image = image
		@ssh = ssh
		@type = type
		@network = network
		@vnc = vnc
	end
	
	def to_s
		str = "Image :" + @image.to_s + "\n"
		str += "SSH :" + @ssh.to_s + "\n"
		str += "Type :" + @type.to_s + "\n"
		str += "Network :" + @network.to_s + "\n"
		str += "VNC :" + @vnc.to_s + "\n"
		str
	end

end


env = Enviroment2.new('web',des,'dadas')
puts env


