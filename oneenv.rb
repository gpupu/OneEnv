
class EnvDescription
	attr_accessor :name, :image, :ssh, :type, :network, :vnc
	
	def initialize(name, image, ssh, type, network, vnc)
		@name = name
		@image = image
		#@cookbooks = cookbooks
		@ssh = ssh
		@type = type
		@network = network
		@vnc = vnc
	end
	
	def to_s
		str = "Name :" + @name.to_s + "\n"  
		str += "Image :" + @image.to_s + "\n"
		str += "SSH :" + @ssh.to_s + "\n"
		str += "Type :" + @type.to_s + "\n"
		str += "Network :" + @network.to_s + "\n"
		str += "VNC :" + @vnc.to_s + "\n"
		str
	end

end
