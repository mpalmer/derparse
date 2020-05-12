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

			def first_child
				if @data.empty?
					DerParse::Node::Nil.new
				else
					DerParse::Node.factory(@data)
				end
			end
		end
	end
end
