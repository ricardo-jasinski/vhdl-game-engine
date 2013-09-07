require 'chunky_png'

if ARGV.size != 1 
	puts "Usage: #{File.basename($0)} sprite_filename.png"
	exit
end

sprite_filename = ARGV[0]
output_filename = sprite_filename.sub('.png', '_paletted.png')

palette = [
	0x00000000,	0x2f2a21ff, 0x4d462cff,	0xa39960ff, 
	0xa8ecb6ff, 0x060d45ff, 0x0d2185ff,	0x103cffff, 
	0x128dfeff, 0x12bbffff, 0x10edfeff,	0x122112ff, 
	0x114419ff, 0x0ba606ff, 0x60f811ff,	0x29112fff, 
	0x553668ff, 0x363636ff, 0x626262ff, 0x959595ff, 
	0xc1c1c1ff, 0x240f09ff, 0x4a110cff, 0xa51a14ff, 
	0xe42015ff, 0xec5c18ff, 0xff9e13ff, 0xabde62ff, 
	0x326a25ff, 0x61a01eff, 0xb6d123ff, 0x580780ff, 
	0xd52bffff, 0x1d1d1dff, 0x000000ff,	0x6991afff, 
	0xb7e4ecff, 0x772e24ff, 0x9d5a20ff, 0xffdf17ff, 
	0xffff23ff, 0xe26553ff, 0xeaa35fff, 0x1eb09eff, 
	0x5f6114ff, 0xa19915ff, 0xeee557ff, 0xce5da9ff, 
	0xf2a9e0ff, 0x182134ff, 0x235373ff, 0x3f89b2ff, 
	0x70e7f1ff, 0xffffffff, 0x7577dcff, 0xa95e56ff, 
	0xe2a69bff, 0xf4e5a0ff, 0x14585cff, 0x009267ff, 
	0x08d66dff, 0x61e8a4ff, 0xa71679ff, 0xff0080ff
]

def distance(color1, color2)
	r1, g1, b1, a1 = ChunkyPNG::Color.to_truecolor_alpha_bytes(color1)
	r2, g2, b2, a2 = ChunkyPNG::Color.to_truecolor_alpha_bytes(color2)

	rgb_distance = Math.sqrt( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 )

	(a1 == a2) ? rgb_distance : Float::INFINITY
end

def to_hex(color)
	ChunkyPNG::Color.to_hex(color)
end		

def find_closest_color(color, palette)
	selected_index = find_closest_color_index(color, palette)
	selected_color = palette[selected_index]
	puts "  selected color #{selected_index} (#{to_hex(selected_color)}) for #{to_hex(color)}"
	selected_color
end

def saturate_alpha(image)
	image.pixels.each_with_index do |pixel, index|
		r, g, b, a = ChunkyPNG::Color.to_truecolor_alpha_bytes(pixel)
		saturated_alpha = a > 127 ? 255 : 0
		image.pixels[index] = ChunkyPNG::Color.rgba(r, g, b, saturated_alpha)
	end
	image
end

def find_closest_color_index(color, palette)
	puts "  looking for match for color #{color} (#{to_hex(color)})"
	return 0x00000000 if ChunkyPNG::Color.a(color) < 128
	distances = palette.collect do |palette_color| 
		dist = distance(color, palette_color) 
		#puts "    distance from #{to_hex(color)} to #{to_hex(palette_color)} is #{dist.round(1)}"
		dist
	end
	puts "  minimum distance is #{distances.min.round(1)} at position #{distances.index(distances.min)}"
	selected_index = distances.index(distances.min)
end

original_sprite = ChunkyPNG::Image.from_file(sprite_filename)
original_sprite = saturate_alpha(original_sprite)
sprite_width = original_sprite.width
sprite_height = original_sprite.height

vhdl_code_snippet = ""
paletted_sprite = ChunkyPNG::Image.new(sprite_width, sprite_height, ChunkyPNG::Color::TRANSPARENT)
sprite_height.times do |y|
	vhdl_code_snippet << "("
	sprite_width.times do |x|
		puts "Pixel (#{x},#{y})"
		original_color = original_sprite[x,y]
		palette_index = find_closest_color_index(original_color, palette)
		vhdl_code_snippet << "%2d" % palette_index
		vhdl_code_snippet << ", " if x < sprite_width - 1
		paletted_sprite[x,y] = find_closest_color(original_color, palette)
	end
	vhdl_code_snippet << ")"
	vhdl_code_snippet << ",\n" if y < sprite_width - 1
end
paletted_sprite.save(output_filename)
puts vhdl_code_snippet
