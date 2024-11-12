#!/bin/env ruby
require 'json'
require 'optparse'

module BasicDB
  MEAN_MINIMUM = 3
  MEAN_ZONE = 0.5

  def parse(meta)
    @meta = meta
    @cast_db = Hash.new {|h,k| h[k] = []}
    @circle_db = Hash.new {|h,k| h[k] = []}
    @tags_db = Hash.new {|h,k| h[k] = []}
    @works_score = {}
    meta.each do |k, v|
      if v["actress"]
        v["actress"].each do |i|
          @cast_db[i].push v
        end
      end
      if v["circle"]
        @circle_db[v["circle"]].push v
      end

      if v["tags"]
        v["tags"].each do |i|
          @tags_db[i].push v
        end
      end

      if v["rate"]
        @works_score[k] = v["rate"]
      end
    end

    @cast_scorelist = Hash.new
    @circle_scorelist = Hash.new
    @tags_scorelist = Hash.new

    @cast_db.each do |k,v|
      @cast_scorelist[k] = v.map {|i| i["rate"] }.compact
    end
    @circle_db.each do |k,v|
      @circle_scorelist[k] = v.map {|i| i["rate"] }.compact
    end
    @tags_db.each do |k,v|
      @tags_scorelist[k] = v.map {|i| i["rate"] }.compact
    end

    @cast_mean = {}
    @circle_mean = {}
    @tags_mean = {}

    @cast_scorelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      @cast_mean[k] = @cast_scorelist[k].sum(0.0) / @cast_scorelist[k].length
    end
    @circle_scorelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      @circle_mean[k] = @circle_scorelist[k].sum(0.0) / @circle_scorelist[k].length
    end
    @tags_scorelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      next if v == "フリートーク"
      @tags_mean[k] = @tags_scorelist[k].sum(0.0) / @tags_scorelist[k].length
    end

    @cast_flat_mean = @cast_mean.map {|k,v| v }.sum(0.0) / @cast_mean.length
    @cast_mean_zone = ((@cast_flat_mean - MEAN_ZONE) .. (@cast_flat_mean + MEAN_ZONE))
    @circle_flat_mean = @circle_mean.map {|k,v| v }.sum(0.0) / @circle_mean.length
    @circle_mean_zone = ((@circle_flat_mean - MEAN_ZONE) .. (@circle_flat_mean + MEAN_ZONE))
    @tags_flat_mean = @tags_mean.map {|k,v| v }.sum(0.0) / @tags_mean.length

    @works_scorelist = meta.map {|k,v| v["rate"]}.compact
    @works_mean = @works_scorelist.sum(0.0) / @works_scorelist.length
    @works_mean_zone = ((@works_mean - MEAN_ZONE) .. (@works_mean + MEAN_ZONE))

    score_and_deviation
  end

  # Deviation and Score code refs:
  # https://qiita.com/k28/items/e3b526b1cd6c4ab25bcc
  # https://andycroll.com/ruby/calculate-the-standard-deviation-of-a-ruby-array/

  def score_and_deviation
    @cast_std_deviation = deviation @cast_mean
    @cast_score = score @cast_mean, @cast_flat_mean, @cast_std_deviation
    @circle_std_deviation = deviation @circle_mean
    @circle_score = score @circle_mean, @circle_flat_mean, @circle_std_deviation
    @tags_std_deviation = deviation @tags_mean
    @tags_score = score @tags_mean, @tags_flat_mean, @tags_std_deviation
    @works_std_deviation = deviation @works_score
  end

  def deviation list
    meanlist = list.map {|k,v| v}
    mean = meanlist.sum(0.0) / meanlist.length
    sum = meanlist.sum(0.0) {|i| (i - mean) ** 2 }
    variance = sum / (meanlist.length - 1)
    std_deviation = Math.sqrt variance
    std_deviation
  end


  def score list, mean, standard_deviation
    val = {}
    list.each do |k, v|
      val[k] = (10 * (v - mean) / standard_deviation) + 50
    end
    val
  end

  def print
    pp @cast_db
    pp @circle_db
    pp @tags_db
    pp @cast_scorelist
    pp @circle_scorelist
    pp @cast_mean
    pp @circle_mean
    pp @cast_std_deviation
    pp @cast_score
    pp @circle_std_deviation
    pp @circle_score
    pp @cast_mean_zone
    pp @circle_mean_zone
    pp @tags_mean
    pp @tags_score
    pp @works_mean
    pp @works_mean_zone
    pp @works_std_deviation
  end
end

module StandardInfomation
end

module MaybeYouLike
end

module Trending
  include BasicDB

  CURRENT_THRESHOLD = 1.2
  RECENT_RATE = 0.15
  TAGS_SCORE_RATE = {
    descending: 0.1,
    ascending: 2.0,
    recent_high: 1.1,
    recent_low: 0.95,
    single_recent: 1.1,
    double_recent: 1.15,
    multiple_recent: 1.35,
    bad_last_work: 0.5
  }
  BASIC_IMPRESSION_WEIGHT = {
    perfect_combo: 0.1,
    good_chain: 0.05,
    bad_chain: -0.15,
    worst_score: -0.05
  }

  def trending_main
    @recent = @meta.map {|k,v| {cast: v["actress"], circle: v["circle"], date: v["btime"]} }
    @recent = @recent.sort_by {|i| i[:date]}.last((@recent.length * RECENT_RATE).to_i)

    @cast_tags = set_tags @cast_scorelist, :cast
    @circle_tags = set_tags @circle_scorelist, :circle

    # 極端に評価が高い/低いサークルの出演に偏ったキャスト,
    # 極端に評価が高い/低いキャストの出演に偏ったサークルについて
    # タグによる効果を低減する
    @cast_influenced = influenced @cast_db, @circle_mean, "circle"
    @circle_influenced = influenced @circle_db, @cast_mean, "actress"

    @cast_correction = trending_basic_impression @cast_scorelist, @cast_influenced
    @circle_correction = trending_basic_impression @circle_scorelist, @circle_influenced

    # pp @cast_correction
    # pp @circle_correction

    # 「平均スコア」ではなく「直近作品の平均スコア」を基準値に使う
    @cast_recent_mean = {}
    @cast_scorelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      @cast_recent_mean[k] = v.last(@opts[:mean_minimum] * 2).sum(0.0) / v.last(@opts[:mean_minimum] * 2).length
    end
    @circle_recent_mean = {}
    @circle_scorelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      @circle_recent_mean[k] = v.last(@opts[:mean_minimum] * 2).sum(0.0) / v.last(@opts[:mean_minimum] * 2).length
    end

    @cast_trending = calc_trending @cast_recent_mean, @cast_tags, @cast_correction
    @circle_trending = calc_trending @circle_recent_mean, @circle_tags, @circle_correction

    # pp @cast_recent_mean
    # pp @cast_trending
    # pp @circle_trending

    print_trending
  end

  def set_tags ratelist, key
    tags = Hash.new {|h,k| h[k] = []}

    ratelist.each do |k,v|
      next if v.length < @opts[:mean_minimum]
      last_rate = nil
      v.each do |r|
        if last_rate && last_rate >= r + 2
          tags[k].push :up
        elsif last_rate && last_rate <= r - 2
          tags[k].push :down
        end

        last_rate = r
      end

      all_mean = v.sum(0.0) / v.length
      tail_items = v.last(3)
      tail_mean = tail_items.sum(0.0) / tail_items.length
      tail_items2 = v.last(5)
      tail_mean2 = tail_items2.sum(0.0) / tail_items2.length

      if tail_mean >= all_mean + CURRENT_THRESHOLD
        tags[k].push :ascending
      elsif tail_mean <= all_mean - CURRENT_THRESHOLD
        tags[k].push :descending
      elsif tail_mean2 > all_mean
        tags[k].push :recent_high
      elsif tail_mean2 < all_mean
        tags[k].push :recent_low
      end

      recent_items = @recent.select {|i| Array === i[key] ? i[key].include?(k) : i[key] == k}
      if recent_items.length == 1
        tags[k].push :single_recent
      elsif recent_items.length == 2
        tags[k].push :double_recent
      elsif recent_items.length > 2
        tags[k].push :multiple_recent
      end

      if v.last <= 2
        tags[k].push :bad_last_work
      end
    end

    tags
  end

  # 極端な偏差値のものについては影響を低減する補正係数を与える
  def influenced works, mean, meankey
    meanlist = Hash.new {|h,k| h[k] = []}
    works.each do |k,v|
      rate = v.map {|wv|
        mkv = wv[meankey]
        Array === mkv ? mkv.map {|mkvi| mean[mkvi]} : mean[mkv]
      }.flatten.compact
      next if rate.length < @opts[:mean_minimum]
      meanlist[k] = rate.sum(0.0) / rate.length
    end

    influenced_score = score(meanlist, @works_mean, @works_std_deviation)

    influenced_rate = {}
    influenced_score.each do |k,v|
      if (45..55).include? v
        nil
      elsif  (35..65).include? v
        influenced_rate[k] = 0.75
      else
        influenced_rate[k] = 0.5
      end
    end

    influenced_rate
  end

  # 項目に対する全体的な印象から直近の平均に対しても補正を加える
  def trending_basic_impression list, influenced_rate
    weight = Hash.new(0)

    list.each do |k, v|
      next if v.length < @opts[:mean_minimum]
      v.each_cons(3) do |con|
        weight[k] += BASIC_IMPRESSION_WEIGHT[:perfect_combo] if con[0,2].sum == 10
        weight[k] += BASIC_IMPRESSION_WEIGHT[:good_chain] if con.sum >= 13
        weight[k] += BASIC_IMPRESSION_WEIGHT[:bad_chain] if con.sum <= 6
        weight[k] += BASIC_IMPRESSION_WEIGHT[:worst_score] if con.last < 2
      end
    end

    weight.each do |k,v|
      if influenced_rate[k]
        weight[k] *= influenced_rate[k]
      end
    end

    weight
  end

  def calc_trending mean, tags, correction
    val = {}
    mean.each do |main_k, main_v|
      score = main_v + (correction[main_k] || 0)
      if tags.include? :descending
        val[main_k] = score * TAGS_SCORE_RATE[:descending]
        next
      end

      tags[main_k].each do |tags_v|
        r = TAGS_SCORE_RATE[tags_v]
        score *= (r || 1)
      end

      val[main_k] = score
    end

    val
  end

  def print_trending
    puts "-*-*-*-*-*-*- HOT Cast -*-*-*-*-*-*-"
    @cast_trending.keys.sort_by {|k| @cast_trending[k]}.reverse.first(5).each do |k|
      printf "%s [%.2f]\n", k, @cast_trending[k]
    end
    puts

    puts "-*-*-*-*-*-*- HOT Circle -*-*-*-*-*-*-"
    @circle_trending.keys.sort_by {|k| @circle_trending[k]}.reverse.first(5).each do |k|
      printf "%s [%.2f]\n", k, @circle_trending[k]
    end
    puts
  end
end

class VoiceStat
  include BasicDB
  include StandardInfomation
  include MaybeYouLike
  include Trending

  def initialize(meta=nil)
    @opts = {
      mean_minimum: BasicDB::MEAN_MINIMUM,
      mean_zone: BasicDB::MEAN_ZONE
    }
    parse(meta) if meta
  end

  def run
    trending_main
  end
end

meta = JSON.load File.read("meta.js").sub("var meta = ", "")

vs = VoiceStat.new
vs.parse meta
# vs.print
vs.run
