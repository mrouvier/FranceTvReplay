#!/usr/bin/env ruby

require "rubygems"
require "hpricot"
require "open-uri"

def launch(temp_url)

  begin
    0.upto(10) do |counter|

      url = temp_url+"replay-videos/ajax/?page="+counter.to_s
      root = open(url)
      if root.meta["content-length"].to_i != 0
        doc = Hpricot( root )
        doc.search("//div/h3/a").each do |node|
          if node.class == Hpricot::Elem
            puts "https://www.france.tv/"+node["href"]
          end
        end
      end
    end
  rescue Exception => e

  end



end


def errarg
    puts "Usage : ./parse_home_page.rb"
    puts "Mickael Rouvier <mickael.rouvier@gmail.com>"
end


if ARGV.size == 1
    launch(ARGV[0])
else
    errarg
end

