#!/bin/ruby
require 'json'
require 'yaml'
require 'nkf'
require 'set'

artist = {
  title: Hash.new {|h, k| h[k] = []},
  circle: Hash.new {|h, k| h[k] = []},
  series: Hash.new {|h, k| h[k] = []},
}

artists = Dir.glob("../_VoiceByCast/*")
artists_sound_map = {}
circle_sound_map = {}

artists.each do |one|
  next unless File.directory? one
  next if File.symlink? one
  if File.basename(one) =~ /\[(.*?)\]_(.*)/
    artists_sound_map[$2] = $1
    name = $2
  else 
    name = File.basename one
  end
  titles = Dir.children one
  titles.each do |title|
    if title =~ /^__/
      # Series
      series = title[2..]
      artist[:series][series].push name
    elsif title =~ /^_/
      # Circle
      circle = title[1..]
      artist[:circle][circle].push name
    else
      artist[:title][title].push name
    end
  end
end

meta = Psych.unsafe_load File.read "meta.yaml"

meta.each do |k, v|
  ##### Complete Duration
#  unless v["duration"]
#    voice_dirs = Hash.new {|h, k| h[k] = 0}
#    Dir.glob("#{v["path"]}/**/*.wav").each do |i|
#      voice_dirs[File.dirname i] += 1
#    end
#    unless voice_dirs.empty?
#      voice_dir = voice_dirs.max_by {|k, v| v}
#      duration = nil
#      IO.popen(["voice-duration.zsh", *Dir.glob("#{voice_dir[0]}/*.wav")]) do |io|
#        duration = io.read.to_i
#      end
#      v["duration"] = duration
#    end
#  end

  ##### Complete circle and series
  if v["path"] =~ %r:_([^/]+)/_([^/]+)/[^/]+$:
    circle = $1
    series = $2
    if circle =~ /\[(.*?)\]_(.*)/
      circle_sound_map[$2] = $1
      circle = $2
    end
    v["circle"] = circle
    v["series"] = series
  elsif v["path"] =~ %r:_([^/]+)/[^/]+$:
    circle = $1
    if circle =~ /\[(.*?)\]_(.*)/
      circle_sound_map[$2] = $1
      circle = $2
    end
    v["circle"] = circle
  end

  ##### Complete Description
  if !v["description"] or v["description"].empty?
    txtfiles = Dir.glob("#{v["path"]}/**/*.txt")
    unless txtfiles.empty?
      v["description"] = NKF.nkf("-w", File.read(txtfiles.first))
    end
  end

  ##### Complete Actress
  v["actress"] ||= []
  if artist[:title][k]
    v["actress"].concat artist[:title][k]
  end
  if artist[:circle][v["circle"]]
    v["actress"].concat artist[:circle][v["circle"]]
  end
  if artist[:series][v["series"]]
    v["actress"].concat artist[:series][v["series"]]
  end

  if !v["actress"] || v["actress"].empty?
    STDERR.puts "#{k} has no Artist"
  end

  # Thumbnail
  unless File.exist?("#{v["path"]}/thumb.jpg")
    # Make image path.
    imgfiles = Dir.glob("#{v["path"]}/**/*.{jpg,jpeg,JPG,png,PNG,webp,avif}")
    unless imgfiles.empty?
      imgfiles.sort_by! {|i| File::Stat.new(i).size }
      v["imgpath"] = imgfiles[0][v["path"].length .. -1]
    end
  end

  # Audio file list
  flist = Set.new
  freetalk = false
  Dir.glob("#{v["path"]}/**/*.{mp3,wav,WAV,MP3,m4a,aac,ogg,flac}").each do |filename|
    fn = File.basename(filename ,".*")
    next if ["SEなし", "SE無し", "seなし", "se無し", "noSE", "NOSE", "nonSE", "noneSE", "OFFSE", "SECut", "SEcut", "NoSFX", "ＳＥなし", "ＳＥ無し", "液体音", "効果音", "声なし"].any? {|i| fn.include? i } # Include
    next if [/^反転/, /_反転$/, /_voice$/, /_voice+指$/].any? {|i| i === fn }
    flist << fn

    # Detect Free talk
    if fn.include?("フリートーク") || fn.include?("PRトーク")
      freetalk = true
    end
  end
  v["filelist"] = flist.to_a.sort
  v["tags"] |= ["フリートーク"] if freetalk

  # expand path
  v["path"] = File.absolute_path v["path"]
end

File.open("meta.js", "w") do |f|
  json = JSON.dump meta
  f.puts("var meta = ", json)
end

File.open("soundindex.js", "w") do |f|
  json = JSON.dump({
    "actress" => artists_sound_map,
    "circle" => circle_sound_map
  })
  f.puts("var soundindex = ", json)
end
