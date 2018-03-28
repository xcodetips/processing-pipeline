require 'tmpdir'

input_path = ARGV[0] || Dir.pwd
output_path = ARGV[1] || Dir.pwd

@desired_width = 1280

def timestamp
  Time.now.to_i
end

def extract_cover(input_path, output_path, width = @desired_width)
  `ffmpeg -ss 00:00:00 -i #{input_path} -vf "scale=#{width}:-2:flags=lanczos" -vframes 1 -q:v 1 #{output_path}`
end

def convert_to_mp4(input_path, output_path, width = @desired_width)
  `ffmpeg -an -i #{input_path} -vf "scale=#{width}:-2:flags=lanczos" -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -level 3 #{output_path}`
end

def convert_to_gif(input_path, output_path, width = @desired_width)
  Dir.mktmpdir do |tmp_dir|
    # Convert to GIF
    raw_path = "#{tmp_dir}/#{timestamp}.gif"
    `ffmpeg -i #{input_path} -r 10 #{raw_path}`

    # Optimize GIF
    `gifsicle #{raw_path} --resize-width #{width} --no-interlace --careful --no-comments --no-names --same-delay --same-loopcount --no-warnings -O3 --colors=48 --use-col=web > #{output_path}`
  end
end

inputs = []
if File.directory?(input_path)
  inputs = Dir["#{input_path}/*.mov"]
else
  inputs = [input_path]
end

inputs.each do |mov|
  basename = File.basename(mov, '.mov')

  convert_to_mp4(mov, "#{output_path}/#{basename}.mp4")
  convert_to_gif(mov, "#{output_path}/#{basename}.gif")
  extract_cover(mov, "#{output_path}/#{basename}.jpg")
end
