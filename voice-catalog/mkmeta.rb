#!/bin/ruby
require 'yaml'
require 'date'

list = Dir.glob("../Voice/_*/_*/*") + Dir.glob("../Voice/_*/[^_]*") + Dir.glob("../Voice/[^_]*")

DB = {}

list.each do |i|
  next unless File.directory? i
  title = File.basename(i)
  if DB[title]
    abort "title #{title} is already exist."
  end

  DB[title] = i
end

meta = (Psych.unsafe_load File.read "meta.yaml") rescue {}

DB.each do |k, v|
  parts = v.sub(%r!^\.\./Voice/!, "").split("/")
  circle = nil
  series = nil
  if parts.length == 3
    circle = parts[0][1..]
    series = parts[1][1..]
  elsif parts.length == 2
    circle = parts[0][1..]
  end

  if meta[k]
    meta[k].merge!({
      "path" => v,
      "circle" => circle,
      "series" => series,
    })
  else
    btime = begin
      File.birthtime(v).to_date
    rescue NotImplementedError
      File.mtime(v).to_date
    end
    meta[k] = {
      "path" => v,
      "btime" => btime,
      "circle" => circle,
      "series" => series,
      "tags" => [],
      "duration" => nil,
      "rate" => nil,
      "description" => "",
    }
  end 
end

File.open("meta.yaml", "w") do |f|
  YAML.dump meta, f
end