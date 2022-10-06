# frozen_string_literal: true

require 'nokogiri'

data = if !`which xclip`.empty?
         `xclip -out -selection clipboard`
       elsif !`which pbpaste`.empty?
         `pbpaste`
       end
doc = Nokogiri::HTML(data)

doc.css('li').each do |li|
  quote = li.inner_text

  if quote.split.count { |x| /[[:upper:]]/.match(x[0]) } > quote.split.count { |x| /[[:lower:]]/.match(x[0]) }
    puts "## #{quote}"
  else
    puts "- #{quote}"
  end
end
