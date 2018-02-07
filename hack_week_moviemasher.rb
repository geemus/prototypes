require 'json'
require 'rmagick'

job = { destination: {}, inputs: [], outputs: [] }

job[:destination] = { type: "file", path: "/tmp/moviemasher/render", method: "move" }

# output is unplayable if the first input is an image instead of video
job[:inputs] << { type: 'video', source: "/tmp/moviemasher/hw-intro.mp4" , offset: 1.5, length: 9.5 }

# colors/fonts/etc via brand.heroku.com
inputs = Dir["/tmp/moviemasher/inputs/*.mp4"]
inputs.each do |input|
  image = Magick::Image.new(1280, 720) do
    self.background_color = "#79589F"
  end

  team_name = File.basename(input, ".mp4")
  text = Magick::Draw.new
  text.annotate(image, 0, 0, 0, 0, team_name) do
    self.fill = "#EEF1F6"
    self.font_family = "Benton Sans" # inconsolata
    self.gravity = Magick::CenterGravity
    self.pointsize = 128
  end

  image_path = "/tmp/moviemasher/inputs/#{team_name}.png"
  image.write(image_path)

  job[:inputs] << { type: 'image', source: image_path, length: 2 }
  job[:inputs] << { type: 'video', source: input }
end

job[:outputs] << { type: 'video', name: 'hack-week-fy19q1' }

File.open('/tmp/moviemasher/queue/job.json', 'w') do |file|
  file.write(JSON.dump(job))
end

exec(<<-CMD
docker run -it --rm -v /tmp/moviemasher:/tmp/moviemasher -v /tmp/moviemasher/inputs:/tmp/moviemasher/inputs -v /tmp/moviemasher/log:/tmp/moviemasher/log -v /tmp/moviemasher/queue:/tmp/moviemasher/queue -v /tmp/moviemasher/render:/tmp/moviemasher/render moviemasher/moviemasher.rb
CMD
)
