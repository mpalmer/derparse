class DerParse
	class Error < StandardError; end
	class IncompatibleDatatypeError < StandardError; end

	class Bug < Exception; end

	def initialize(s)
		if s.respond_to?(:to_str)
			@s = s.to_str
		else
			raise ArgumentError,
			      "Must provide string to parse"
		end
	end

	def traverse(&blk)
		if blk
			node(@s, 0, 0, &blk)
			self
		else
			to_enum(:traverse)
		end
	end

	def to_a
		[].tap do |v|
			r = @s

			until r.empty?
				n = DerParse::Node.factory(r)
				v << n.value
				r = n.rest
			end
		end
	end

	private

	def node(der, depth, offset, &blk)
		node = DerParse::Node.factory(der, depth: depth, offset: offset)
		yield node

		if node.constructed?
			node(node.data, depth + 1, offset + node.header_length, &blk)
		end

		unless node.rest.empty?
			node(node.rest, depth, offset + node.der_length, &blk)
		end
	end
end

require_relative "./derparse/node"
