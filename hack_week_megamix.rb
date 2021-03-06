require 'fileutils'
require 'json'
require 'rmagick'
require 'shellwords'

tmp_dir = '/tmp/hack_week_megamix'
FileUtils::mkdir_p tmp_dir

videos_dir = File.expand_path("~/Downloads/videos")

raw_paths = Dir["#{videos_dir}/*.mp4"].shuffle

file_paths = [
  File.expand_path("~/Downloads/hw-intro.mp4")
]

raw_paths.each do |path|
  image = Magick::Image.new(1280, 720) do
    self.background_color = "#79589F"
  end

  team_name = File.basename(path, ".mp4")
  text = Magick::Draw.new
  text.annotate(image, 0, 0, 0, 0, team_name) do
    self.fill = "#EEF1F6"
    self.font_family = "Inconsolata"
    self.gravity = Magick::CenterGravity
    self.pointsize = 32
  end

  tmp_path = "#{tmp_dir}/#{team_name}"
  image_path = "#{tmp_path}.png"
  image_video_path = "#{tmp_path}.mp4"
  image.write(image_path)

  # generate a 2 second video from the image, with a fake audio source padded to the 2 second duration
  `ffmpeg -y -framerate 30 -loop 1 -i #{image_path.shellescape} -f lavfi -i anullsrc=cl=stereo:r=32k -af apad -b:a 128k -b:v 584k -c:a aac -c:v libx264 -t 2 -movflags +faststart -pix_fmt yuv420p -shortest -t 2 -vsync cfr #{image_video_path.shellescape}`

  file_paths << image_video_path
  file_paths << path
end

offset = 12 # intro video length
index_data = "00:00:00 hw-intro\n"

raw_paths.each do |path|
  json = `ffprobe -i #{path.shellescape} -hide_banner -print_format json -show_format -v quiet`
  duration = JSON.parse(json)['format']['duration'].to_f.round
  team_name = File.basename(path, ".mp4")

  hours = offset / 3600
  minutes = (offset % 3600) / 60
  seconds = offset % 60
  timestamp = [hours, minutes, seconds].map {|time| time.to_s.rjust(2,'0')}.join(':')
  index_data << "#{timestamp} #{team_name}\n"
  offset += duration + 2 # 2 is title slide length
end

index_path = "./index.txt"
File.open(index_path, 'w') do |file|
  file.write index_data
end


# convert to intermediary format, so that everything is in the same format before concat
# FIXME: theoretically, I think the image->video process could just output in compatible format, but after many tries I couldn't get the raw files to concat and intermediary works
FileUtils::mkdir_p "/tmp/hack_week_megamix/int"
intermediate_paths = []
file_paths.each_with_index do |path, index|
  intermediate_path = "/tmp/hack_week_megamix/int/#{index}.ts"
  intermediate_paths << intermediate_path
  `ffmpeg -y -i #{path.shellescape} -c copy -bsf:v h264_mp4toannexb -f mpegts #{intermediate_path}`
end

files_path = "#{tmp_dir}/files.txt"
File.open(files_path, 'w') do |file|
  file.write intermediate_paths.map {|path| "file '#{path}'"}.join("\n")
end

`ffmpeg -y -f concat -safe 0 -i #{files_path} -c:a aac -c:v libx264 megamix.mp4`
