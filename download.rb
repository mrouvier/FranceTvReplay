#!/usr/bin/env ruby

require "rubygems"
require "hpricot"
require "open-uri"
require "json"

def get_id(doc)
  doc.search("script") do |x|
    if x.innerHTML.include?("var FTVPlayerVideos") == true
      json_parse = JSON.parse( x.innerHTML.gsub("var FTVPlayerVideos =", "")[0..-3] )
      return json_parse[0]["videoId"]
    end
  end
  return nil
end

def get_json(id)
  json_url = "https://sivideo.webservices.francetelevisions.fr/tools/getInfosOeuvre/v2/?idDiffusion="+id+"&callback=_jsonp_loader_callback_request_0"
  json = JSON.parse(open(json_url).read[33..-2])
  return json
end

def get_subtitle(json)
  subtitle = json["subtitles"][0]["url"]
  return subtitle
end

def get_m3u8(json)
  m3u8 = nil
  if json["videos"].size == 1
    m3u8 = json["videos"][0]["url_secure"]
  else
    m3u8 = json["videos"][1]["url_secure"]
  end
  m3u8.gsub!("https", "http")
  return m3u8
end



def launch(liste, output)

  f = File.open(liste)
  f.each do |url|

    url.chomp!
    begin
      doc = Hpricot( open( url ) )
      id = get_id(doc)

      show = url.split("/")[4]+"_"+url.split("/").last.split(".")[0]

      puts "#{url}"
      puts "#{show}"
      puts "#{id}"

      puts "[x] get_id"
      json = get_json(id)
      puts "[x] get_subtitle"
      subtitle = get_subtitle(json)
      puts "[x] get_m3u8"
      m3u8 = get_m3u8(json)
      puts "[x] get_mkv"
      mkv = open(m3u8).read.split("\n").last


      if File.exist?("#{output}/#{show}.mp4") == false
        %x[ffmpeg -i \"#{mkv}\" -c copy #{output}/#{show}.mp4 </dev/null]
      end

      if File.exist?("#{output}/#{show}.txt") == false
        f = File.new("#{output}/#{show}.txt", "w")
        open( subtitle ).read.split("\n").each do |line|
          if line.include?("<span") == true
            node = Hpricot.parse( line ).search("//span").first.inner_html
            f << node +"\n"
          end
        end
        f.close
      end

    rescue
    end

  end
  f.close

end


def errarg
  puts "Usage : ./download.rb"
  puts "Mickael Rouvier <mickael.rouvier@gmail.com>"
end


if ARGV.size == 2
  launch(ARGV[0], ARGV[1])
else
  errarg
end

