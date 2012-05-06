#!/usr/bin/env ruby

def find_deps(cookbook_dir)
  nel = Hash.new { |h, k| h[k] = [] }
  Dir.glob("#{cookbook_dir}/*/").each do |r|
    deps_for(r, nel)
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

