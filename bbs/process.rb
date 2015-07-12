# date, srw, srt, cpw, cpt, pdw, pdt, opw, opt, lpw, lpt
data = []
raw = File.read(File.join(File.dirname(__FILE__), "data.csv"))
raw.split("\n").each do |line|
  datum = {}
  datum[:date],
    datum[:srw],
    datum[:srt],
    datum[:cpw],
    datum[:cpt],
    datum[:pdw],
    datum[:pdt],
    datum[:opw],
    datum[:opt],
    datum[:lpw],
    datum[:lpt] = line.split(",")
  data << datum
end
puts data.inspect

[:sr, :cp, :pd, :op, :lp].each do |exercise|
  puts exercise
  data.each do |datum|
    weight, time = datum["#{exercise}w".to_sym], datum["#{exercise}t".to_sym]
    puts "#{datum[:date]} (#{weight}/#{time})= #{weight.to_f / time.to_f}"
  end
  puts
end
