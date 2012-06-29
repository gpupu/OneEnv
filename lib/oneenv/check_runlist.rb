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

require 'json'
require 'oneenv/database.rb'
require 'oneenv/deps_list'
require 'oneenv/check_deps'


def get_recipes(runl_array)
array_recipes=[]
	if !runl_array.nil?
		runl_array.each do |r|
			r = r[7..-2]
		
			if !r.include?("::")
				r += "::default"
			end

			array_recipes << r
		end
	else
		puts 'Bad runlist'
	end
	return array_recipes
end




def get_cookbooks(array_recipes)
array_cookbooks=[]
	if !array_recipes.nil?
		array_recipes.each do |c|
			array_cookbooks << c.split("::")[0]
		end
	else
		puts 'Bad recipes'
	end
return array_cookbooks
end


def contain_roles(path)
	rl_array=get_json_runl(path)
	return rl_array.any? { |s| s.start_with?('role') }
end


def check_runlist(path)
	runList=get_json_runl(path)
	array_recipes=get_recipes(runList)
	array_cookbooks=get_cookbooks(array_recipes)

	cb_list = Deps_List.new
	i=0
	name_cb=array_cookbooks[i]
	cb=Cookbook.getCookbookByName(name_cb)
	esta=true
	while i<array_cookbooks.size && esta do
		name_cb=array_cookbooks[i]
		cb=Cookbook.getCookbookByName(name_cb)
		esta=(!cb.nil?)
		if (esta)
			cb_list.add_cb array_cookbooks[i]
		end
		i+=1
	end

	return cb_list


end



