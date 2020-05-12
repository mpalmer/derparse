class DerParse
	class Node
		# This class does not represent an ASN.1 object, but instead is a special
		# node that is returned when no other node would be suitable.  It is, shall
		# we say, "`nil`-compatible".
		class Nil < Node
			def initialize(*_)
			end

			def self.handles?(_)
				false
			end

			def value
				nil
			end

			def nil?
				true
			end

			def next_node
				self
			end

			def first_child
				self
			end
		end
	end
end
