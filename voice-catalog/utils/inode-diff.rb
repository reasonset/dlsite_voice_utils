#!/bin/ruby
require 'yaml'

db = YAML.load File.read "ino.yaml"
diff = {}
offset = "../Voice/".length

Dir.glob("../Voice/**/*").each do |i|
  f = File::Stat.new i
  ino = f.ino
  fp = i[offset..]
  if db[ino] != fp
    diff[db[ino]] = fp
  end
end

File.open("diff.yaml", "w") do |f|
  YAML.dump diff, f
end