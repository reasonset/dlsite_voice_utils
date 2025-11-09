#!/bin/ruby
require 'yaml'
require 'date'

META_BASE = {
  "tags" => [],
  "duration" => nil,
  "rate" => nil,
  "description" => "",
  "note" => [],
}

list = Dir.glob("../Voice/_*/_*/*") + Dir.glob("../Voice/_*/[^_]*") + Dir.glob("../Voice/[^_]*")
meta = (YAML.unsafe_load File.read "meta.yaml") rescue {}

list.reject! do |i|
  !File.directory?(i) ||
  (File.fnmatch("../Voice/_*/*", i) && FileTest.symlink?(i)) || # Skip circle alias.
  (File.fnmatch("../Voice/_*/_*/*", i) && FileTest.symlink?(i)) # Skip circle alias.
end

list.each do |titledir|
  outpath = File.join(titledir, ".dlvumeta.yaml")
  if File.exist? outpath
    next
  end

  puts "Create for #{titledir}"
  btime = begin
    File.birthtime(titledir).to_date
  rescue NotImplementedError
    File.mtime(titledir).to_date
  end

  meta = {"btime" => btime}.merge(META_BASE)
  File.open(outpath, "w") {|f| YAML.dump meta, f}
end
