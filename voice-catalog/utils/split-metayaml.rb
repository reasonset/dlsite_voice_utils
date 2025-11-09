#!/bin/env ruby
require 'yaml'
require 'date'

meta_yaml_data = File.read "meta.yaml"
meta = YAML.unsafe_load meta_yaml_data

# Check missing title directory
meta.each do |k,v|
  unless File.directory? v["path"]
    abort "Title directory #{v["path"]} is not exist."
  end
end

meta.each do |k,v|
  outpath = File.join(v["path"], ".dlvumeta.yaml")
  if File.exist? outpath
    puts "File already exists. Skipping: #{k}"
  end

  outdata = v.dup
  outdata.delete("path")
  outdata.delete("circle")
  outdata.delete("series")
  outdata["duration"] ||= nil
  outdata["tags"] ||= []
  outdata["description"] ||= ""
  outdata["note"] ||= []

  File.open(outpath, "w") {|f| YAML.dump outdata, f}
end
