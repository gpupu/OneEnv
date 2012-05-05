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

def to_dot(nel, name)
  puts "digraph #{name} {"
  nel.each do |n, deps|
    deps.each do |d|
      puts "    \"#{n}\" -> \"#{d}\";"
    end
  end
  puts "}"
end

nel = find_deps(ARGV[0])
to_dot(nel, "cookbook")
