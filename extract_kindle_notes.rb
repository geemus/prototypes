require 'nokogiri'

data = File.read(ARGV.first)
doc = Nokogiri::HTML(data)

title = doc.css('h3.kp-notebook-metadata').first.inner_text
author = doc.css('p.kp-notebook-metadata').last.inner_text

puts "# #{title} by #{author}\n"

doc.css('.kp-notebook-row-separator').each do |row|
  metadata = row.css('.kp-notebook-metadata').first.content
  location = metadata.split("Location:").last[1..-1].gsub(',','')

  highlight = row.css('#highlight').first
  next unless highlight
  quote = highlight.inner_text

  puts "- #{quote} [#{location}]"
end
