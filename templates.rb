class Template

  # Construct the template object

  def initialize( template )
      @template = template.clone()
    @values = {}
  end

  # Set the value of a replacement variable. The name is the 
  # name in the template.  The value is the string to replace
  # the corresponding item(s) in the template.
  
  def set( name, value )
      @values[ name ] = value
  end

  def setCM( type )
	case type
	when 'small'
		@values[ 'cpu' ] = '0.5'
      		@values[ 'memory' ] = '256'
        when 'medium'
		@values[ 'cpu' ] = '1'
      		@values[ 'memory' ] = '512'
	else
	end
  end

  def setCB( cookbooks )
	s = ''
	max = cookbooks.length
	cont = 0
	cookbooks.each{|cb| 
		s += "'"+cb.path+"'" 
		cont += 1		
		if max== cont
		else
			s += ','
		end		
		}
	@values[ 'receipt' ] = s
  end
  # Run the template with the given parameters and return
  # the template with the values replaced
  
  def run()
    @template.gsub( /:::(.*?):::/ ) { @values[ $1 ].to_s }
  end

  # A synonym for run so that you can simply print the class
  # and get the template result

  def to_s()
      run()
  end
end

def constructTemplate(env)
# Create the template object with the template string
	temp = Template.new( "NAME = :::nombre:::\nCPU    = :::cpu:::\nMEMORY = :::memory:::\nDISK = [\n\s\sIMAGE     = :::image:::\s]\nNIC = [ network_id = :::network:::\s]\nCONTEXT = [\n\s\sFILES = :::receipt:::\n\s\sSSH_KEY= :::ssh:::\n]")

	desc = env[:description]
# Set the names and values of the replacement items
	temp.set( 'nombre', env.name )
	temp.setCM( desc.type )
	temp.set( 'image', desc.image )
	temp.set( 'network', desc.network )
	temp.setCB( env.cookbooks )
	temp.set( 'ssh', desc.ssh )
	print temp
end
