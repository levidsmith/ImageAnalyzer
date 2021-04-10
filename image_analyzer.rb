#2021 Levi D. Smith - levidsmith.com

class Chunk
	attr_accessor :length
	attr_accessor :type
	attr_accessor :data
	attr_accessor :crc
end



def generate_png()

	#bytes = [0x41, 0x42, 0x97, 0x98]
	#bytes[0] += 1
	bytes_hex = '4142434461626364'
	bytes_dec = [65, 66, 67, 68, 97, 98, 99]
	#[bytes].pack("H*").unpack("C*")
	

	#f = File.open("test.png", "w")
	#f.puts(bytes.scan(/../).map(&:hex))
	#File.write("test.png", [bytes].pack("H*").unpack("C*"))
	#f.close()
#	File.write("test.txt", [bytes_hex].pack("H*"))
#	File.write("test.txt", bytes_dec.pack("c*"))
	
	bytes_png_signature = [137, 80, 78, 71, 13, 10, 26, 10]
	File.write("test.txt", bytes_png_signature.pack("c*"))

end

def load_png()

end

def load_bmp() 
	f = File.open("../images/bbgcamyw_bmp.bmp")
	contents = f.read()
	puts "Character string"
	puts contents
	puts "Hexadecimal"
	puts contents.unpack("H*")
	f.close()

end

def load_png() 
	strFile = "../images/bbgcamyw_png.png"
	iSize = File.size(strFile)
	f = File.open(strFile)
	contents = f.read(iSize)
	puts "File size #{iSize}"
	puts "Character string"
	puts contents
	puts "Hexadecimal"
#	puts contents.unpack("H*")
#	puts contents.each_byte.map { |b| b.to\_s + " " }.join
	puts contents.each_byte.map { | b | "%02x" % b }.join(" ")
	puts "Decimal"
	puts contents.unpack("C*").join(" ")
	
	int_array = contents.unpack("C*")
	strTag = ""
	
	i = 0
	iChunkLength = 0
	
	while (i < iSize)
		iSeq = [137, 80, 78, 71, 13, 10, 26, 10]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found the signature"
			
			#Skip next two bytes (26, 10)
			i += 2
		end
		

		iSeq = [73, 72, 68, 82]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found IHDR"

			puts "  width: " + int_array[i + 4].to_s + int_array[i + 5].to_s + int_array[i + 6].to_s + int_array[i + 7].to_s
			puts "  height: " + int_array[i + 8].to_s + int_array[i + 9].to_s + int_array[i + 10].to_s + int_array[i + 11].to_s
			puts "  bit depth: " + int_array[i + 12].to_s
			puts "  color type: " + int_array[i + 13].to_s
			puts "  compression: " + int_array[i + 14].to_s
			puts "  filter: " + int_array[i + 15].to_s
			puts "  interlace: " + int_array[i + 16].to_s


		end

		iSeq = [73, 69, 78, 68]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found IEND"
		end

		iSeq = [116, 73, 77, 69]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found tIME (last image modification)"
			
			puts "  year: " + int_array[i + 4].to_s + " " + int_array[i + 5].to_s + " = " + (int_array[i + 4] * 256 + int_array[i + 5]).to_s
			puts "  month: " + int_array[i + 6].to_s
			puts "  day: " + int_array[i + 7].to_s
			puts "  hour: " + int_array[i + 8].to_s
			puts "  min: " + int_array[i + 9].to_s
			puts "  sec: " + int_array[i + 10].to_s
			
		end
		
		iSeq = [116, 69, 88, 116]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found tEXt (Textual data)"
			strKeyWord = ""
			strText = ""
			j = i + 4
			while (int_array[j] != 0)
				strKeyWord << int_array[j]
				j += 1
			
			end
			puts "  Keyword: " + strKeyWord.to_s

			j += 1
			while (int_array[j] != 0)
				strText << int_array[j]
				j += 1
			
			end
			puts "  Text: " + strText.to_s

		
		end


		iSeq = [73, 68, 65, 84]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found IDAT (Image data)"
		end

		iSeq = [105, 67, 67, 80]
		if (check_sequence(iSeq, int_array, i)) then
			puts "Found iCCP (Embedded ICC profile)"
			
			strProfileName = ""
			iCompressionMethod = 0
			strCompressedProfile = ""
			j = i + 4
			while (int_array[j] != 0)
				strProfileName << int_array[j]
				j += 1
			end
			puts "  Profile Name: " + strProfileName.to_s
			
			j += 1
			iCompressionMethod = int_array[j]
			
			j += 1
			
		end


	
		i += 1
	end


	f.close()

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



#generate_png()
#load_bmp()
load_png()