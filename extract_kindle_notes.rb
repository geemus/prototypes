# frozen_string_literal: true

require 'nokogiri'

data = if !`which xclip`.empty?
         `xclip -out -selection clipboard`
       elsif !`which pbpaste`.empty?
         `pbpaste`
       end
doc = Nokogiri::HTML(data)

title = doc.css('h3.kp-notebook-metadata').first.inner_text
author = doc.css('p.kp-notebook-metadata').last.inner_text

puts "# #{title} by #{author}\n"

doc.css('span#highlight').each do |hl|
  quote = hl.inner_text

  if quote.split.length > 1 && quote.split.all? { |x| /[[:upper:]]/.match(x[0]) }
    puts "## #{quote}"
  else
    puts "- #{quote}"
  end
end
