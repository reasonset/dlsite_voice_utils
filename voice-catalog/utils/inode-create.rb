#!/bin/ruby
require 'yaml'

db = {}
offset = "../Voice/".length

Dir.glob("../Voice/**/*").each do |i|
  f = File::Stat.new i
  db[f.ino] = i[offset..]
end

File.open "ino.yaml", "w" do |f|
  YAML.dump db, f
end