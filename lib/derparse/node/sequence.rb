class DerParse
	class Node
		class Sequence < Node
			def self.handles?(der)
				der[0] == "\x30"
			end

			def value
				[].tap do |v|
					r = @data

					until r == ""
						n = DerParse::Node.factory(r)
						v << n.value
						r = n.rest
					end
				end
			end
		end
	end
end
