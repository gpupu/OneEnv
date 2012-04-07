require "rubygems"
require "kwalify"

#Entiendo que solo hay un esquema de validacion
SCHEMA='./validation/schema_env.yaml' 

#doc es el documento yaml que queremos comprobar si es valido
def validationYAML(doc)
	schema = Kwalify::Yaml.load_file(SCHEMA)
	validator = Kwalify::Validator.new(schema)
	document = Kwalify::Yaml.load_file(doc)
	errors = validator.validate(document)
	if errors && !errors.empty?
  		for e in errors
    			puts "[#{e.path}] #{e.message}"
  		end
	else
		return true
	end
end

=begin
PATH_SCHEMA = ARGV[0]
PATH_DOCUMENT = ARGV[1]

## load schema data
schema = Kwalify::Yaml.load_file(PATH_SCHEMA)
## or
#schema = YAML.load_file('schema.yaml')

## create validator
validator = Kwalify::Validator.new(schema)

## load document
document = Kwalify::Yaml.load_file(PATH_DOCUMENT)
## or
#document = YAML.load_file('document.yaml')

## validate
errors = validator.validate(document)

## show errors
if errors && !errors.empty?
  for e in errors
    puts "[#{e.path}] #{e.message}"
  end
else
  puts "TODO BIEN"
=end

