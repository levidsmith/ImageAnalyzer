#2021 Levi D. Smith - levidsmith.com

require "zlib"

class Chunk
	attr_accessor :length
	attr_accessor :type
	attr_accessor :data
	attr_accessor :crc
end

def load_png() 
	strFile = "../images/bbgcamyw_png2.png"
#	strFile = "../images/test_png_2x2_red.png"
#	strFile = "../images/test_png_2x2_cyan.png"
#	strFile = "../images/test_png_2x2_white.png"
#	strFile = "../images/test_png_2x2_black_and_white.png"
#	strFile = "../images/test_png_1x4_blue.png"
#	strFile = "../images/test_png_4x1_blue.png"
#	strFile = "../images/test_png_1x4_royg.png"
#	strFile = "../images/test_png_4x1_royg.png"
#	strFile = "my.png"
	iSize = File.size(strFile)
	f = File.open(strFile)
	contents = f.read(iSize)
	f.close()

	puts "File size #{iSize}"

#	puts "Character string"
#	puts contents

	puts "Hexadecimal"
	puts contents.each_byte.map { | b | "%02x" % b }.join(" ")
	puts ""
	
	puts "Decimal"
	puts contents.unpack("C*").join(" ")
	puts ""
	
	int_array = contents.unpack("C*")
	
	i = 0

	#Check the Signature
	iSeq = [137, 80, 78, 71, 13, 10, 26, 10]
	if (check_sequence(iSeq, int_array, i)) then
		puts "Found the signature (" + 
		iSeq.select{ | val | not [13, 10].include? val }.pack("C*") + #don't display newline or line feed
		"): " + 
		iSeq.join(" ")
		
		i += iSeq.length
			
	end

	#Read the chunks
	while (i < iSize)
		chunk = loadChunk(int_array, i)
		analyzeChunkType(chunk)
		
		i += 4 + 4 + chunk.length + 4
	end


end



def loadChunk(arr, iIndex)
	chunk = Chunk.new
	
	isPrintingOutput = false
	
	i = iIndex

	#Get the chunk length
	chunk.length = arr[i + 0] * (256 ** 3) +
	               arr[i + 1] * (256 ** 2) +
			       arr[i + 2] * (256 ** 1) +
			       arr[i + 3] * (256 ** 0)
	
	if (isPrintingOutput)
		puts "Chunk length: " + chunk.length.to_s
	end
	

	#Get the chunk type
	i += 4
	chunk.type = []
	chunk.type << arr[i + 0]
	chunk.type << arr[i + 1]
	chunk.type << arr[i + 2]
	chunk.type << arr[i + 3]

	if (isPrintingOutput)
		puts "Chunk type: " + chunk.type.to_s
	end
	
	
	#Get the chunk data
	i += 4
	j = 0
	chunk.data = []
	while (j < chunk.length)
		chunk.data << arr[i + j]
	
		j += 1
	end
	
	if (isPrintingOutput)
		puts "Chunk data: " + chunk.data.to_s
	end
	
	
	#Get the chunk crc
	i += chunk.length
	chunk.crc = ""
	chunk.crc << arr[i + 0]
	chunk.crc << arr[i + 1]
	chunk.crc << arr[i + 2]
	chunk.crc << arr[i + 3]
	
	if (isPrintingOutput)
		puts "Chunk crc: " + chunk.crc.to_s
	end
	

	return chunk
end


def analyzeChunkType(chunk)
	#Note - the array values are from the PNG standard
	
	iSeq = [73, 72, 68, 82]
	if (checkType(iSeq, chunk.type))
		puts "Chunk IHDR: " + iSeq.join(" ")
		analyzeChunkDataIHDR(chunk.data)
	end
	
	iSeq = [105, 67, 67, 80]
	if (checkType(iSeq, chunk.type))
		puts "Chunk iCCP (Embedded ICC profile): " + iSeq.join(" ")
		analyzeChunkDataiCCP(chunk.data)
	end
	
	iSeq = [116, 73, 77, 69]
	if (checkType(iSeq, chunk.type))
		puts "Chunk tIME (last image modification): " + iSeq.join(" ")
		analyzeChunkDatatIME(chunk.data)
	end
	
	iSeq = [116, 69, 88, 116]
	if (checkType(iSeq, chunk.type))
		puts "Chunk tEXt (Textual data): " + iSeq.join(" ")
		analyzeChunkDatatEXt(chunk.data)
	end

	iSeq = [112, 72, 89, 115]
	if (checkType(iSeq, chunk.type))
		puts "Chunk pHYs (Physical pixel dimensions): " + iSeq.join(" ")
		analyzeChunkDatapHYs(chunk.data)
	
	end
	
	iSeq = [73, 68, 65, 84]
	if (checkType(iSeq, chunk.type))
		puts "Chunk IDAT (Image data): " + iSeq.join(" ")
		analyzeChunkDataIDAT(chunk.data)
	end
	
	iSeq = [73, 69, 78, 68]
	if (checkType(iSeq, chunk.type))
		puts "Chunk IEND: " + iSeq.join(" ")
	
	end

end

def analyzeChunkDataIHDR(data)
	i = 0
	
	puts "  width: " + [data[0], data[1], data[2], data[3]].join(" ")
	puts "  height: " + [data[4], data[5], data[6], data[7]].join(" ")
	
	iBitDepth = data[8]
	puts "  bit depth: " + iBitDepth.to_s
	
	iColorType = data[9]
	print "  color type: " + data[i + 9].to_s
	if (iColorType == 0)
		puts " (Grayscale)"
	elsif (iColorType == 2)
		puts " (Truecolor)"
	elsif (iColorType == 3)
		puts " (Indexed-color)"
	elsif (iColorType == 4)
		puts " (Grayscale with alpha)"
	elsif (iColorType == 6)
		puts " (Truecolor with alpha)"
	else
		puts ""

	end
	
	
	iCompressionMethod = data[10]
	puts "  compression: " + iCompressionMethod.to_s
		
	puts "  filter: " + data[i + 11].to_s
	
	iInterlace = data[12]
	print "  interlace: " + data[i + 12].to_s
	if (iInterlace == 0)
		puts " (No interlace)"
	elsif (iInterlace == 1)
		puts " (Adam7 interlace)"
	else
		puts ""
	end
end


def analyzeChunkDataiCCP(data)
	i = 0
	strProfileName = ""
	iCompressionMethod = 0
	strCompressedProfile = ""

	while (data[i] != 0)
		strProfileName << data[i]
		i += 1
	end
	puts "  Profile Name: " + strProfileName.to_s
	
	#skip the null separator
	i += 1
	
	iCompressionMethod = data[i]
	puts "  Compression Method: " + iCompressionMethod.to_s
	i += 1
			
	compressed_profile = []
	while (i < data.length)
		compressed_profile << data[i]
		i += 1
	end
	#puts "  Compression Profile: " + compressed_profile.to_s

end

def analyzeChunkDatatIME(data)
	i = 0
	puts "  year: " + data[i + 0].to_s + " " + data[i + 1].to_s + " = " + (data[i + 0] * 256 + data[i + 1]).to_s
	puts "  month: " + data[i + 2].to_s
	puts "  day: " + data[i + 3].to_s
	puts "  hour: " + data[i + 4].to_s
	puts "  min: " + data[i + 5].to_s
	puts "  sec: " + data[i + 6].to_s

end

def analyzeChunkDatatEXt(data)
	i = 0
	strKeyWord = ""
	strText = ""
	
	while (data[i] != 0)
		strKeyWord << data[i]
		i += 1
			
	end
	puts "  Keyword: " + strKeyWord.to_s

	#skip the null separator
	i += 1
	
	while (i < data.length)
		strText << data[i]
		i += 1
			
	end
	puts "  Text: " + strText.to_s

end

def analyzeChunkDatapHYs(data)
	isPrintingOutput = false

	iPixelsPerUnitX = data[0] * (256 ** 3) +
	                  data[1] * (256 ** 2) +
	                  data[2] * (256 ** 1) +
	                  data[3] * (256 ** 0)

	iPixelsPerUnitY = data[4] * (256 ** 3) +
	                  data[5] * (256 ** 2) +
	                  data[6] * (256 ** 1) +
	                  data[7] * (256 ** 0)
			
	
	iUnitSpecifier = data[8]

	if (isPrintingOutput) 
		puts "  Pixels / unit X: " + iPixelsPerUnitX.to_s
		puts "  Pixels / unit Y: " + iPixelsPerUnitX.to_s
		puts "  Unit specifier: " + iUnitSpecifier.to_s
	end
	
	


end


def analyzeChunkDataIDAT(data)
	isPrintingOutput = true
	
	
	iZlibCompressionMethod = data[0]
	iAdditionalFlags = data[1]
	compressed_data = []
	i = 2
	while (i < data.length - 4)
		compressed_data << data[i]
		i += 1
	end
	
	check_value = []
	while (i < data.length)
		check_value << data[i]
		i += 1
	end
	
	if (isPrintingOutput)
		puts "  zlib compression method: " + iZlibCompressionMethod.to_s
		puts "  additional flags: " + iAdditionalFlags.to_s
		puts "  compressed data: " + compressed_data.join(" ")

		puts "  check value: " + check_value.join(" ")
	
	end

	puts ""
	puts "  data: " + data.to_s
	puts "  compressed data: " + data.pack("C*")
	uncompressed_data = Zlib::Inflate.inflate(data.pack("C*"))
	puts "  uncompressed data (decimal): " + uncompressed_data.unpack("C*").join(" ")
	puts "  uncompressed data:           " + uncompressed_data

end


def checkType(type, value)
	isMatch = true
	
	i = 0
	type.each { | b |
		if (b != value[i])
			isMatch = false
		end
		i += 1
	}
	
	
	return isMatch

end



def check_sequence(seq, arr, iIndex)
	isMatch = true
	
	if (iIndex + seq.length < arr.length) then
	
		i = 0
		while (i < seq.length)
			if (arr[iIndex + i] != seq[i]) then
				isMatch = false
			end
			
			i += 1
		end
	
	else 
		isMatch = false
	end
	
	return isMatch

end


load_png()