require 'chunky_png'
require 'set'

def get_palette
	palette_image = ChunkyPNG::Image.from_file('palette.png')
	colors = Set.new
	colors << 0x00000000	# start with transparent at index 0
	palette_image.pixels.each do |pixel|
		colors << pixel
	end
	colors
end

def print_hex_palette(palette)
	palette.each do |color|
		color_hex = ChunkyPNG::Color.to_hex(color, false)
		puts "#{color_hex}"
	end
end

def print_vhdl_palette(palette)
	palette.each do |color|
		r, g, b = ChunkyPNG::Color.to_truecolor_bytes(color)
		puts "(%3d, %3d, %3d)," % [r, g, b]
	end
end

palette = get_palette
print_vhdl_palette(palette)