#!/bin/ruby
require 'yaml'
require 'date'
require 'tempfile'

class EditDLVoice
  def initialize
    Dir.chdir ARGV.shift
    @libdir = nil
    @curdir = Dir.pwd
    
    puts "You ran on #{@curdir}"

    until File.exist? "#{Dir.pwd}/_VoiceLibrary"
      Dir.chdir("..")
      if Dir.pwd == "/"
        abort "Cannot find library directory."
      end
    end
    @libdir = Dir.pwd
    
    puts "Library directory found: #{@libdir}"

    if index = (crp = @curdir.split("/")).index {|i| i == ".library"}
      libid = crp[index + 1]
      titles = Dir["Voice/_*/_*/*", "Voice/_*/[^_]*", "Voice/[^_]*"].select {|i| File.symlink? i }
      title = titles.find {|i| File.readlink(i).split("/").include? libid }
      @title = title.split("/").last
    else
      crp = @curdir[@libdir.length .. -1]
      unless crp.split("/")[0] == "Voice"
        abort "You need to run under voice title directory."
      end

      if crp.length > 2 && crp[1][0] == "_" && crp[2][0] == "_"
        @title = crp[3]
      elsif crp[1][0] == "_"
        @title = crp[2]
      else
        @title = crp[1]
      end
    end

    puts "Reading database..."
    @library = YAML.unsafe_load(File.read "_VoiceLibrary/meta.yaml")

    unless @library[@title]
      abort "Title #{@title} not found in database"
    end

    Tempfile.open(["dlvoice_", ".yaml"]) do |fp|
      before = YAML.dump @library[@title]
      File.open(fp.path, "w") {|f| f.write before }
      system((ENV["EDITOR"] || "vim"), fp.path)
      after = File.read fp.path
      if before != after
        puts "Writing database..."
        entity = YAML.unsafe_load(after)
        @library[@title] = entity
        File.open("_VoiceLibrary/meta.yaml", "w") {|f| YAML.dump(@library, f) }
      else
        puts "Metadata has no change."
      end
    end
  ensure
    puts "Done."
    sleep 2.5
  end
end

EditDLVoice.new
