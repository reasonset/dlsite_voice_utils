#!/bin/env ruby
require 'json'
require 'optparse'

OPTS = {}

op = OptionParser.new
op.on("-w VAL", "--works-limit") {|v| v.to_i }
op.on("-a VAL", "--actress-top") {|v| v.to_i }
op.on("-c VAL", "--circle-top") {|v| v.to_i }
op.on("-t VAL", "--tags-limit") {|v| v.to_i }
op.on("-A VAL", "--actress-mean-top") {|v| v.to_i }
op.on("-C VAL", "--circle-mean-top") {|v| v.to_i }
op.on("-T", "--suppress-tags")
op.on("-F", "--suppress-fivestars")
op.on("-s", "--show-score-detail")
op.on("-r VAL", "--recommend-works-limit") {|v| v.to_i}

op.parse!(ARGV, into: OPTS)

META = JSON.load File.read("meta.js").sub("var meta = ", "")

STAT = {
  circles: Hash.new(0),
  actresses: Hash.new(0),
  circle_rate: Hash.new {|h,k| h[k] = []},
  actress_rate: Hash.new {|h,k| h[k] = []},
  tags: Hash.new(0),
  mean_rate: [],
  mean_duration: [],
  top_work: [],
  top_circle: Hash.new(0),
  top_actress: Hash.new(0),
}

META.each do |k, v|
  STAT[:circles][v["circle"]] += 1 unless !v["circle"] || v["circle"].empty?
  v["actress"].each do |i|
    STAT[:actresses][i] += 1
  end
  v["tags"].each do |i|
    STAT[:tags][i] += 1
  end
  if v["rate"]
    STAT[:circle_rate][v["circle"]].push v["rate"]  unless !v["circle"] || v["circle"].empty?
    v["actress"].each do |i|
      STAT[:actress_rate][i].push v["rate"]
    end
    STAT[:mean_rate].push v["rate"]

    if v["rate"] == 5
      STAT[:top_work].push v
      STAT[:top_circle][v["circle"]] += 1 unless !v["circle"] || v["circle"].empty?
      v["actress"].each do |i|
        STAT[:top_actress][i] += 1
      end
    end
  end
  STAT[:mean_duration].push v["duration"] if v["duration"]
end

circles = []
STAT[:circles].each do |k,v|
  circles.push({name: k, number: v})
end
circles.sort_by! {|i| -i[:number]}
if OPTS[:"circle-top"]
  circles = circles[0, OPTS[:"circle-top"]]
end
circles.select! {|i| i[:number] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]

actresses = []
STAT[:actresses].each do |k,v|
  actresses.push({name: k, number: v})
end
actresses.sort_by! {|i| -i[:number]}
if OPTS[:"actress-top"]
  actresses = actresses[0, OPTS[:"actress-top"]]
end
actresses.select! {|i| i[:number] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]

tags = []
STAT[:tags].each do |k,v|
  tags.push({name: k, number: v})
end
tags.sort_by! {|i| -i[:number]}
tags.select! {|i| i[:number] >= OPTS[:"tags-limit"] } if OPTS[:"tags-limit"]

circle_rate = []
STAT[:circle_rate].each do |k,v|
  circle_rate.push({name: k, number: (v.sum(0.0) / v.length), size: v.length})
end
circle_rate.sort_by! {|i| [-i[:number], -i[:size]]}
circle_rate.select! {|i| i[:number] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]

actress_rate = []
STAT[:actress_rate].each do |k,v|
  actress_rate.push({name: k, number: (v.sum(0.0) / v.length), size: v.length})
end
actress_rate.sort_by! {|i| [-i[:number], -i[:size]]}
actress_rate.select! {|i| i[:number] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]

top_circles = []
STAT[:top_circle].each do |k,v|
  top_circles.push({
    name: k,
    top: v,
    total: STAT[:circle_rate][k].length
  })
end
top_circles.sort_by! {|i| [-i[:top], -(i[:top] / i[:total].to_f)]}
if OPTS[:"circle-mean-top"]
  top_circles = top_circles[0, OPTS[:"circle-mean-top"]]
end
top_circles.select! {|i| i[:total] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]

top_actress = []
STAT[:top_actress].each do |k,v|
  top_actress.push({
    name: k,
    top: v,
    total: STAT[:actress_rate][k].length
  })
end
top_actress.sort_by! {|i| [-i[:top], -(i[:top] / i[:total].to_f)]}
if OPTS[:"actress-mean-top"]
  top_actress = top_actress[0, OPTS[:"actress-mean-top"]]
end
top_actress.select! {|i| i[:total] >= OPTS[:"works-limit"]} if OPTS[:"works-limit"]


puts "========== TOP CAST =========="
actresses.each do |i|
  printf("%s: %d [%d]\n", i[:name], i[:number], (STAT[:actress_rate][i[:name]].length || 0))
end

puts

puts "========== TOP CIRCLE =========="
circles.each do |i|
  printf("%s: %d\n", i[:name], i[:number])
end

puts

unless OPTS[:"suppress-tags"]
  puts "========== TOP TAG =========="
  tags.each do |i|
    printf("%s: %d\n", i[:name], i[:number])
  end

  puts
end

puts "========== ACTRESS MEAN RATE =========="
actress_rate.each do |i|
  printf("%s: %.2f (%d)\n", i[:name], i[:number], i[:size])
end

puts

puts "========== CIRCLE MEAN RATE =========="
circle_rate.each do |i|
  printf("%s: %.2f (%d)\n", i[:name], i[:number], i[:size])
end

puts

unless OPTS[:"suppress-fivestars"]
  puts "========== 5 Stars Works =========="
  STAT[:top_work].each do |i|
    printf("\"%s\" (%s) by %s\n", File.basename(i["path"]), i["actress"].join(", "), (i["circle"] || "???"))
  end
end

puts

puts "========== 5 Stars Actress =========="
top_actress.each do |i|
  printf("%s %d/%d (%d%%)\n", i[:name], i[:top], i[:total], (i[:top] / i[:total].to_f * 100))
end

puts

puts "========== 5 Stars Circle =========="
top_circles.each do |i|
  printf("%s %d/%d (%d%%)\n", i[:name], i[:top], i[:total], (i[:top] / i[:total].to_f * 100))
end

puts

puts "========== OTHER STATS =========="
printf("Number of works: %d\n", META.length)
printf("Mean rate: %.3f (/%d)\n", (STAT[:mean_rate].sum(0.0) / STAT[:mean_rate].length), STAT[:mean_rate].length)
printf("Mean duration: %.3fmin\n", (STAT[:mean_duration].sum(0.0) / STAT[:mean_duration].length))
printf("Unrated works: %d (%d%% rated)\n", (META.length - STAT[:mean_rate].length), (STAT[:mean_rate].length / META.length.to_f * 100))


###################################################################

puts

puts "..........Experimental.........."

calc_favorite_actress = []
dist_rate = Hash.new(0)
dist_rate_vs = STAT[:actress_rate].values.flatten
dist_rate_vs.each {|i| dist_rate[i] += 1}
sc_base = {
  1 => 0.75,
  2 => 0.9,
  3 => 1.0,
  4 => 1.08,
  5 => 1.45,
}
sc_deviation = {
  1 => -0.14,
  2 => -0.11,
  3 => -0.05,
  4 => 0.04,
  5 => 0.21,
}
sc = {}
dist_rate.each do |k,v|
  r =  v / dist_rate_vs.length.to_f
  sc[k] = sc_base[k] + sc_deviation[k] * (1 - r)
end

STAT[:actress_rate].each do |k, v|
  next if v.length < (OPTS[:"recommend-works-limit"] || 4)
  # Base score
  score = v.length + v.length * ((v.sum(0.0) / v.length) / (STAT[:mean_rate].sum(0.0) / STAT[:mean_rate].length))

  wt = Hash.new(1)

  v.each do |i|
    case i
    when 5
      score *= (sc[5] + wt[5] * 0.23)
      wt[5] += 1
    when 4
      score *= (sc[4] + wt[4] * 0.12)
      wt[4] += 1
    when 3
      wtr = (sc[3] - wt[3] * 0.01)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[3] += 1
    when 2
      base_rate = case
      when v.include?(5)
        sc[2] + 0.12
      when v.include?(4)
        sc[2] + 0.08
      else
        sc[2]
      end
      wtr = (base_rate - wt[2] * 0.02)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[2] += 1
    when 1
      base_rate = case
      when v.include?(5)
        sc[1] + 0.3
      when v.include?(4)
        sc[1] + 0.21
      else
        sc[1]
      end
      wtr = (base_rate - wt[1] * 0.03)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[1] += 1
    end
  end

  score *= (v.sum(0.0) / v.length / 5)

  calc_favorite_actress.push({name: k, score: score, length: v.length, mean: (STAT[:actress_rate][k].sum(0.0) / STAT[:actress_rate][k].length)})
end
calc_favorite_actress.sort_by! {|i| -i[:score]}

puts "========== Maybe you like =========="
calc_favorite_actress[0, 10].each do |i|
  puts i[:name]
end

calc_favorite_circle = []
dist_rate = Hash.new(0)
dist_rate_vs = STAT[:circle_rate].values.flatten
dist_rate_vs.each {|i| dist_rate[i] += 1}
sc_base = {
  1 => 0.2,
  2 => 0.6,
  3 => 1.0,
  4 => 1.1,
  5 => 1.25,
}
sc_deviation = {
  1 => -0.12,
  2 => -0.31,
  3 => -0.12,
  4 => 0.2,
  5 => 0.44,
}
sc = {}
dist_rate.each do |k,v|
  r =  v / dist_rate_vs.length.to_f
  sc[k] = sc_base[k] + sc_deviation[k] * r
end

STAT[:circle_rate].each do |k, v|
  next if v.length < (OPTS[:"recommend-works-limit"] || 4)
  # Base score
  score = v.length

  wt = Hash.new(1)

  v.each do |i|
    case i
    when 5
      if v.include?(1) || v.include?(2)
        score *= (sc[5] - 0.4 + wt[5] * 0.5)
      else
        score *= (sc[5] + wt[5] * 0.5)
      end
      wt[5] += 1
    when 4
      if v.include?(1) || v.include?(2)
        score *= (sc[4] - 0.2 + wt[4] * 0.12)
      else
        score *= (sc[4] + wt[4] * 0.12)
      end
      wt[4] += 1
    when 3
      wtr = (sc[3] - wt[3] * 0.01)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[3] += 1
    when 2
      wtr = (sc[2] - wt[2] * 0.02)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[2] += 1
    when 1
      wtr = (sc[1] - wt[1] * 0.03)
      wtr = 0 if (wtr < 0)
      score *= wtr
      wt[1] += 1
    end
  end

  if v.include?(1)
    score *= 0.1
  elsif v.include?(2)
    score *= 0.8
  end

  calc_favorite_circle.push({name: k, score: score, length: v.length})
end
calc_favorite_circle.sort_by! {|i| -i[:score]}

puts "----------"
calc_favorite_circle[0, 10].each do |i|
  puts i[:name]
end

if OPTS[:"show-score-detail"]
  puts
  pp calc_favorite_actress
  pp calc_favorite_circle
end