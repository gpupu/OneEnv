#!/usr/bin/env ruby

require 'deps_list.rb'

def find_deps(cookbook_dir)
  nel = Hash.new { |h, k| h[k] = [] }
  Dir.glob("#{cookbook_dir}/*/").each do |r|
    deps_for(r, nel)
  end
  nel
end

def find_deps2(cookbook_dir)
  nel = Hash.new { |h, k| h[k] = [] }
  
  Dir.glob("#{cookbook_dir}/recipes/*.rb").each do |r|
	#puts cookbook_dir
	cb_name = File.basename(cookbook_dir)
	#puts cb_name
	rec = File.basename(r, ".rb")
	#puts "Estoy dentro de findeps2 y viendo a #{r}"
	#puts rec
	rdeps=get_recipe_deps(rec, cookbook_dir) 
	if rdeps != []
    	nel["#{rec}"] = rdeps
	end
  end
  nel
end

#TODO No muestra bien los nombres
def show_deps_list(hlist)
	s = ""
	hlist.each do |r,d|
		s += "#{r}: "
		d.each{|deps| s += ", #{deps}"}

	end
	s
end


def deps_for(dir, nel)
  regex = /.*include_recipe +("|')([^"]+)("|')/
  dir = dir.sub(/\/$/, "")
  Dir.glob("#{dir}/recipes/*.rb").each do |recipe|
    deps = []
    r_name = File.basename(recipe).sub(/\.rb$/, "")
    item = File.basename(dir) + "::" + r_name
    open(recipe) do |f|
      f.each do |line|
        m = line.match(regex)
        if m
          if !m[2].match(/::/)
            deps << (m[2] + "::default")
          else
            deps << m[2]
          end
        end
      end
    end
    nel[item] = deps
  end
end

def clean_deps(h_cbs)
	h_cbs.delete_if do |n, deps|
		deps.empty?
	end
	h_cbs
end

def list_deps(cbs)
	if cbs.empty?
		puts "All recipes depencies are provided"
	else
		cb_deps = Array.new
		cbs.each do |n, deps|
			deps.each do |d|
				puts "#{n} -> #{d}"
				cb_ar = d.split("::")
				if !cb_deps.include?(cb_ar[0])
					cb_deps.push(cb_ar[0])
				end
			end
		end
		puts "\nThese cookbooks may be needed: "
		puts "\t" +  cb_deps.join(", ")
	end

end

$deps

def expand_node(node_path)
	$deps = deps_list.new
	node_ar = get_json_runl(node_path)

end


def expand_sons(rl_array)
	rl_array.each do |r|
		if r.start_with?('recipe')
			#es una recipe
			if !$deps.exists_cb?(r)
				rec = r[7..-2]
				$deps.add_cb(rec)
				#TODO leer sus dependencias de la base de datos
				# con el array resultado volvemos a llamar a expand_sons
				expand_sons(cb_deps)
			else
				#si ya existe no lo añade y corta para evitar ciclos
			end
		end
		if r.start_with?('role')
			#es un rol
			if !deps.exists_role?(r)
				role = r[5..-2]
				$deps.add_role(role)
				#TODO leer sus dependencias de la base de datos
				# con el array resultado volvemos a llamar a expand_sons
				expand_sons(r_deps)
			else
				#si ya existe no lo añade y corta para evitar ciclos
			end
		end
	end
end

#devuelve array dependencias de un json
def get_json_runl(path)
	jfile = File.read(path)
	runl = JSON.parse(jfile, :create_additions=>false)
	runl = runl['run_list']

	return runl
end

#devuelve array dependencias de un rb
def get_ruby_runl(path)
	regex = /.*run_list +(("|')([^"]+)("|'),)*(("|')([^"]+)("|'))/

	open(path) do |f|
    	f.each do |line|
        	m = line.match(regex)
			rl = line.split("\"")
        	if m
				puts 'entra dentro'
            	rl = line.split("\"")
            	rl.delete_if {|x|
                	x.include?("run_list") or
                	x.include?(",")
            	}
				puts rl
				return rl
        	end
    	end
	end
end

def get_recipe_deps(recipe_name, cb_path)
	regex = /.*include_recipe +("|')([^"]+)("|')/
	#dir = cb_path.sub(/\/$/, "")
	cb_path = File.expand_path(cb_path)
	if File.exists? "#{cb_path}/recipes/#{recipe_name}.rb"
		r_deps = []
		item = File.basename(cb_path) + "::" + recipe_name
		open("#{cb_path}/recipes/#{recipe_name}.rb") do |f|
			f.each do |line|
       			m = line.match(regex)
        		if m
          			if !m[2].match(/::/)
            			r_deps << (m[2] + "::default")
						puts r_deps
          			else
            			r_deps << m[2]
						puts r_deps
          			end
        		end
      		end
    	end
    	return r_deps
  	else
		puts "This recipe not exists #{cb_path}/recipes/#{recipe_name}.rb"

	end
end

