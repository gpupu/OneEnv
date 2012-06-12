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

class Deps_List

attr_accessor :cookbooks_list, :role_list

	def initialize
		@cookbooks_list = Array.new
		@role_list = Array.new
	end

	def add_cb cb
		cookbooks_list.push cb if !cookbooks_list.include? cb
	end

	def add_role r
		role_list.push r if !role_list.include? r
	end

	def exists_role? r
		return role_list.include? r

	end

	def exists_cb? cb
		return cookbooks_list.include? cb

	end

	def get_sh_role_list
		s  = ''
		role_list.each do |r|
			rfile = Role.get_filename r
			s += "#{rfile};"
		end
		s = s[0..-2]
		s
	end

	def get_sh_cb_list
		cb_ar = get_cb_list
		s = ''
		cb_ar.each do |cb|
			s += "#{cb};"
		end
		s = s[0..-2]
		s
	end

	def get_cb_list
		cb_ar = []
		cookbooks_list.each do |cb|
			cb_name = cb.split("::")[0] 
			cb_ar << cb_name if !cb_ar.include?(cb_name)
		end
		cb_ar
	end

	def get_role_list
		return role_list
	end

end
