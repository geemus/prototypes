# frozen_string_literal: true

require 'nokogiri'

data = if !`which xclip`.empty?
         `xclip -out -selection clipboard`
       elsif !`which pbpaste`.empty?
         `pbpaste`
       end
doc = Nokogiri::HTML(data)

doc.css('li').each do |li|
  puts "- #{li.content}"
end
