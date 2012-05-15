
class Deps_List

attr_accessor :cookbooks_list, :role_list

def initialize
	@cookbooks_list = Array.new
	@role_list = Array.new
end

def add_cb cb
	cookbooks_list.push cb
end

def add_role r
	role_list.push r
end

def exists_role? r
	return role_list.include? r

end

def exists_cb? cb
	return cookbooks_list.include? cb

end

def get_sh_role_list
	s  = '('
	role_list.each do |r|
		s += " \"#{r}\""
	end
	s += ')'
	s
end

def get_sh_cb_list
	cb_ar = get_cb_list
	s  = '('
	cb_ar.each do |cb|
		s += " \"#{cb}\""
	end
	s += ')'
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

end
