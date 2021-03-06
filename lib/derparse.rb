class DerParse
	class Error < StandardError; end
	class IncompatibleDatatypeError < StandardError; end

	class Bug < Exception; end

	def initialize(s)
		if s.respond_to?(:to_str)
			@s = s.to_str.dup.force_encoding("BINARY")
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

	def resync(tag, strict: true)
		i = @s.index(tag)

		until i.nil?
			n = DerParse::Node.factory(@s[i..], offset: i)

			if n.complete?
				if !strict || n.next_node.nil?
					return n
				else
					nn = n.next_node
					while nn.complete? && !nn.next_node.nil?
						nn = nn.next_node
					end
					if nn.complete?
						return n
					end
				end
			end

			i = (ni = @s[i+1..].index(tag)) ? ni + i + 1: nil
		end

		DerParse::Node::Nil.new
	end

	def first_node
		node(@s, 0, 0) { |n| return n }
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
