class DerParse
	class Node
		class Integer < Node
			def self.handles?(der)
				der[0] == "\x02"
			end

			def value
				sign = (@data[0].ord & 0x80) >> 7

				@data.split(//).inject(0) { |a, c| sign *= 256; a * 256 + c.ord } - sign
			end
		end
	end
end
