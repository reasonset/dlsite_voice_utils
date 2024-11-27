#!/bin/ruby
require 'yaml'
require 'date'

diff = YAML.load File.read("diff.yaml")

db = {
  title: {},
  series: {},
  circle: {}
}

# "File rename" is only used by NASUtils sync renamer.
diff.reject! do |k, v|
  !File.directory? v
end

# Compile for actress
diff.each do |k, v|
  if k =~ %r!^_[^/]*/_[^/]*$!
    # Series
    db[:series]["__" + File.basename(k).sub(/^_/, "")] = v
  elsif k =~ %r!^_[^/]*$!
    # Circle
    db[:circle][File.basename(k)] = v
  else
    db[:title][File.basename(k)] = v
  end
end

# Update actress
Dir.glob("../_VoiceByCast/*/*").each do |i|
  #p File.basename(i)[0, 2]
  if File.basename(i)[0, 2] == "__"
    # Series
    if db[:series][File.basename i]
      system "rm", "-v", i
      system "ln", "-sv", "../../Voice/#{db[:series][File.basename i]}", [File.dirname(i), "__#{File.basename(db[:series][File.basename i])}"].join("/")
    end
  elsif File.basename(i)[0, 1] == "_"
    # Circle
    if db[:series][File.basename i]
      system "rm", "-v", i
      system "ln", "-sv", "../../Voice/#{db[:circle][File.basename i]}", [File.dirname(i), "_#{File.basename(db[:circle][File.basename i])}"].join("/")
    end
  else
    # Title
    if db[:title][File.basename i]
      system "rm", "-v", i
      system "ln", "-sv", "../../Voice/#{db[:title][File.basename i]}", [File.dirname(i), File.basename(db[:title][File.basename i])].join("/")
    end
  end
end

# Update Meta
meta = Psych.unsafe_load File.read("meta.yaml")
diff.each do |k, v|
  if meta[File.basename k]
    meta[File.basename k]["path"] = "../Voice/#{v}"
  end
end
File.open("meta.yaml", "w") do |f|
  YAML.dump meta, f
end

