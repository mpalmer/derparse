class DerParse
	class Node
		class OctetString < Node
			def self.handles?(der)
				der[0] == "\x04"
			end

			def value
				@data
			end
		end
	end
end
