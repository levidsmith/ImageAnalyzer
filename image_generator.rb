#2021 Levi D. Smith - levidsmith.com

require "zlib"

class Chunk
	attr_accessor :length
	attr_accessor :type
	attr_accessor :data
	attr_accessor :crc
end

def create_png()

	f = File.new("my.png", "wb") #important to put the "b", otherwise it will generate Windows newlines

	iSeq = [137, 80, 78, 71, 13, 10, 26, 10]
	f.print(iSeq.pack("C*"))
	
	
	chunk = createChunkIHDR()
	f.print(chunk.length.pack("C*"))
	f.print(chunk.type.pack("C*"))
	f.print(chunk.data.pack("C*"))
	f.print(chunk.crc.pack("C*"))

	chunk = createChunkIDAT()
	f.print(chunk.length.pack("C*"))
	f.print(chunk.type.pack("C*"))
	f.print(chunk.data.pack("C*"))
	f.print(chunk.crc.pack("C*"))

	chunk = createChunkIEND()
	f.print(chunk.length.pack("C*"))
	f.print(chunk.type.pack("C*"))
	f.print(chunk.data.pack("C*"))
	f.print(chunk.crc.pack("C*"))


	f.close()

end

def createChunkIHDR()
	chunk = Chunk.new
	
	chunk.type = [73, 72, 68, 82] #IHDR
	
	data = []
	data << 0
	data << 0
	data << 0
	data << 8 #width
	data << 0
	data << 0
	data << 0
	data << 8 #height
	data << 8 #bit depth
	data << 2 #color type
	data << 0 #compression
	data << 0 #filter
	data << 0 #interlace

	chunk.data = data
	
	length = []
	length << 0
	length << 0
	length << 0
	length << 13
	chunk.length = length
	
	crc = []
	crc << 0
	crc << 0
	crc << 0
	crc << 0
	chunk.crc = crc
	
	
	return chunk
end

def createChunkIDAT()
	chunk = Chunk.new
	
	chunk.type = [73, 68, 65, 84] #IDAT
	
	data = [0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0,
			0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0,	
			0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0,			
			0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0, 255, 255, 0,			

			0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0,   0, 0, 255, 0, 0, 255,0, 0, 255, 0, 0, 255,
			0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0,   0, 0, 255, 0, 0, 255,0, 0, 255, 0, 0, 255,
			0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0,   0, 0, 255, 0, 0, 255,0, 0, 255, 0, 0, 255,
			0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0,   0, 0, 255, 0, 0, 255,0, 0, 255, 0, 0, 255
			]
			
			# 0    red    red    red    red   yellow yellow yellow yellow
			# 0    red    red    red    red   yellow yellow yellow yellow
			# 0    red    red    red    red   yellow yellow yellow yellow
			# 0    red    red    red    red   yellow yellow yellow yellow
			# 0  green  green  green  green     blue   blue   blue   blue
			# 0  green  green  green  green     blue   blue   blue   blue
			# 0  green  green  green  green     blue   blue   blue   blue
			# 0  green  green  green  green     blue   blue   blue   blue

	puts "uncompressed data: " + data.join(" ")
	
	puts "data.pack(\"C*\"): " + data.pack("C*")
	compressed_data = Zlib::Deflate::deflate(data.pack("C*"), 8)
	puts "compressed data (string): " + compressed_data.to_s
	puts "compressed data (decimal): " + compressed_data.unpack("C*").join(" ")
	
	chunk.data = []
	compressed_data.each_byte { |b|
		chunk.data << b
	}
	
	length = []
	length << 0
	length << 0
	length << 0
	length << chunk.data.length
	chunk.length = length
	
	crc = []
	crc << 0
	crc << 0
	crc << 0
	crc << 0
	chunk.crc = crc
	
	
	return chunk

end


def createChunkIEND()
	chunk = Chunk.new
	
	chunk.type = [73, 69, 78, 68] #IEND
	
	data = []
	chunk.data = data
	
	length = []
	length << 0
	length << 0
	length << 0
	length << 0
	chunk.length = length
	
	crc = []
	crc << 0
	crc << 0
	crc << 0
	crc << 0
	chunk.crc = crc
	
	
	return chunk
end

create_png()