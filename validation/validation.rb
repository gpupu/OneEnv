require 'rubygems'
require 'kwalify'

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
end
