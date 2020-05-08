class DerParse
	class Node
		class Null < Node
			def self.handles?(der)
				der[0] == "\x05"
			end

			def value
				nil
			end
		end
	end
end
