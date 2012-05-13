
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

end
