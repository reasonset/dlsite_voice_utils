#!/bin/ruby
require 'yaml'
require 'date'

meta = YAML.unsafe_load File.read "meta.yaml"

meta.each do |k, v|
  fn = "../_VoiceByDate/#{v["btime"]}-#{k}"
  unless File.exist? fn
    system "ln", "-sv", v["path"], fn
  end
end
