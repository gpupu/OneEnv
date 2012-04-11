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

# Create the template object with the template string

temp = Template.new( "NAME = :::nombre:::\nCPU    = :::numero1:::\nMEMORY = :::numero2:::\nDISK = [\n\s\simage     = :::imagen:::\s]\nNIC = [ network_id = :::network:::\s]\nCONTEXT = [\n\s\sFILES = :::receta:::\n\s\sSSH_KEY= :::ssh:::\n]")

# Set the names and values of the replacement items

def constructTemplate(env)
	temp.set( 'nombre', env.nombre )
	temp.set( 'numero1', '1' )
	temp.set( 'numero2', '512' )
	temp.set( 'imagen', "5" )
	temp.set( 'network', "4" )
	temp.set( 'receta', "coso" )
	temp.set( 'ssh', "clave" )
	print temp
}
