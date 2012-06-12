#!/usr/bin/env ruby

# --------------------------------------------------------------------------#
# Copyright 2012   David Baena, Fernando Martínez-Conde, José Gabriel Puado	#
# 																			#
# Licensed under the Apache License, Version 2.0 (the "License"); you may 	#
# not use this file except in compliance with the License. You may obtain 	#
# a copy of the License at 													#
# 																			#
# http://www.apache.org/licenses/LICENSE-2.0 								#
# 																			#
# Unless required by applicable law or agreed to in writing, software 		#
# distributed under the License is distributed on an "AS IS" BASIS, 		#
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 	#
# See the License for the specific language governing permissions and 		#
# limitations under the License. 											#
#---------------------------------------------------------------------------#

require 'oneenv/deps_list.rb'
require 'json'
require 'cli/oneenv_helper/format_cli.rb'


#nombre receta => [COOBOOK::recipe,..]
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
	#if rdeps != []
    nel["#{rec}"] = rdeps
	#end
  end
  nel
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
		s = "All recipes depencies are provided"
	else
		s = ""
		str_h1= "%9s %35s %30s"
		str =["RECIPES","DEPENDENCIES",""]
		Format_cli.print_header(str_h1,str,true)
		cb_deps = Array.new
		cbs.each do |n, deps|
			deps.each do |d|
				#s += "\n#{n} -> #{d}"
				s+= "\n"+ "%1s %-20s %-9s %-20s" % ["",n,"->",d]
				cb_ar = d.split("::")
				if !cb_deps.include?(cb_ar[0])
					cb_deps.push(cb_ar[0])
				end
			end
		end
		#s += "\n\nThese cookbooks may be needed: "
		#s += "\t" +  cb_deps.join(", ")
	end
	return s
end

###########################################################################

$deps

def expand_node(node_path)
	$deps = Deps_List.new
	node_ar = get_json_runl(node_path)
	comp = expand_sons(node_ar)
	comp
end





def expand_sons(rl_array)
	comp = true
	rl_array.each do |r|
		if r.start_with?('recipe')
			#puts "#{r} es una recipe"
			r = r[7..-2]	#toma solo el interior
			comp = expand_recipe(r) && comp
		end
		if r.start_with?('role')
			#puts "#{r} es un rol"
			r = r[5..-2]	#toma solo el interior
			comp = expand_role(r) && comp
		end
	end

	comp
end

def expand_roles(roles_ar)
	comp = true
	roles_ar.each do |r|
		comp = expand_role(r) && comp
	end
	comp
end

def expand_role(r)
	comp = true
	if !$deps.exists_role?(r)
		$deps.add_role(r)

		if Role.exists?(:name => r.to_s)
			role = Role.first(:conditions=>{:name=>r})
			# expandimos cookbooks
			comp = expand_cookbooks(role.deps_recs)
			# expandimos roles
			comp = expand_roles(role.deps_roles) && comp
			return comp
		else
			puts "Dependencies incompleted: #{r}"
			return false
		end
	else
		#si ya existe no lo añade y corta para evitar ciclos
	end
	#puts comp
	comp
end

def expand_cookbooks(cb_ar)
	comp = true
	cb_ar.each do |r|
		comp = expand_recipe(r) && comp
	end
	comp
end

def expand_recipe(rec_comp)
	comp = true
	if !$deps.exists_cb?(rec_comp)
		if !rec_comp.include?("::")
			rec_comp += "::default"
		end
		$deps.add_cb(rec_comp)
		# Comprobamos que existe en la base de datos la dependencia (el hijo)
		cb_name = rec_comp.split("::")[0]
		if Cookbook.exists?(:name => cb_name)
			cb = Cookbook.first(:conditions=>{:name=>cb_name})
			# cogemos el nombre de la receta de la que depende
			rec = rec_comp.split("::")[1]
			#puts rec
			# cogemos el array de las dependencias de esa receta en concreto
			cb_deps = cb.recipes_deps[rec]
			#puts cb_deps
			comp = expand_cookbooks(cb_deps)
			return comp
		else
			puts "Dependencies incompleted: #{cb_name}"
			return false
		end
	else
		#si ya existe no lo añade y corta para evitar ciclos
	end
	#puts comp
	comp
end

###########################################################################


def get_json_runl(path)
runl=[]
	if File.exists?(path)
		jfile = File.read(path)
		begin
		runl = JSON.parse(jfile, :create_additions=>false)
		runl = runl['run_list']
		rescue JSON::ParserError
			puts 'Bad runlist'
			exit
		end

	else
		puts path
		puts 'Node path is not correct' 
	end
	return runl
end




#devuelve array dependencias de un rb
def get_ruby_runl(path)
	regexp = /.*run_list? *\(?(( )*("|')([^"]+)("|')( )*,( )*)*(("|')([^"]+)("|')( )*)\)?/
	open(path) do |f|
    	f.each do |line|
        	m = line.match(regexp)# || line.match(regexp)
			rl = line.split("\"")
        	if m
				puts 'entra dentro'
            	rl = line.split("\"")
            	rl.delete_if {|x|
                	x.include?("run_list") or
                	x.include?(",") or 
					x.include?(")")
            	}
				puts rl
				return rl
        	end
    	end
	end
	nil
end

################################################################

def get_recipe_deps(recipe_name, cb_path)
	regex = /.*include_recipe +("|')([^"#]+)("|')/
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
						#puts r_deps
          			else
            			r_deps << m[2]
						#puts r_deps
          			end
        		end
      		end
    	end
    	return r_deps
  	else
		puts "This recipe not exists #{cb_path}/recipes/#{recipe_name}.rb"

	end
end

