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

    until File.exist? ".dlvumeta.yaml"
      Dir.chdir("..")
      if Dir.pwd == "/"
        abort "Cannot find library directory."
      end
    end
    @libdir = Dir.pwd
    
    puts "Title directory found: #{@libdir}"
    
    orig_data = YAML.unsafe_load File.read ".dlvumeta.yaml"
    
    Tempfile.open(["dlvoice_", ".yaml"]) do |fp|
      before = YAML.dump orig_data
      File.open(fp.path, "w") {|f| f.write before }
      system((ENV["EDITOR"] || "vim"), fp.path)
      after = File.read fp.path
      if before != after
        puts "Writing database..."
        begin
          entity = YAML.unsafe_load(after)
          entity["reviewed_at"] = Date.today
          File.open(".dlvumeta.yaml", "w") {|f| YAML.dump(entity, f) }
        rescue
          puts "!! Broken YAML format."
        end
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
