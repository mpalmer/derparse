require "derparse"

class DerParse
	class Node
		def self.factory(der, *args)
			klass_name = DerParse::Node.constants.find do |const|
				DerParse::Node.const_get(const).handles?(der)
			end

			klass = klass_name.nil? ? DerParse::Node : const_get(klass_name)

			klass.new(der, *args)
		end

		attr_reader :tag, :tag_class, :tag_length, :length_length, :data_length, :data, :depth, :offset, :rest

		def initialize(der, depth: 0, offset: 0)
			@depth, @offset = depth, offset
			@tag = @tag_class = @constructed = @tag_length = @data_length = @length_length, @data = nil
			@complete = true

			begin
				r = parse_type(der)
				r = parse_length(r)
				@rest = parse_data(r)
			rescue IncompleteDer
				@complete = false
			end
		end

		def der_length
			if data_length.nil? || header_length.nil?
				nil
			else
				data_length + header_length
			end
		end

		def header_length
			if tag_length.nil? || length_length.nil?
				nil
			else
				tag_length + length_length
			end
		end

		def constructed?
			@constructed
		end

		def primitive?
			!constructed?
		end

		def complete?
			@complete
		end

		def value
			raise IncompatibleDatatypeError, "No known way to render tag #{@tag} into a value"
		end

		private

		class IncompleteDer < Error; end
		private_constant :IncompleteDer

		def parse_type(s)
			if s.empty? || s.nil?
				# This *technically* shouldn't be possible
				#:nocov:
				raise Bug, "parse_type(#{s.inspect})"
				#:nocov:
			end

			t0, s = ss(s)

			@tag_class = (t0 & 0xc0) >> 6
			@constructed = ((t0 & 0x20) >> 5) == 1
			@tag = t0 & 0x1f
			tl = 1

=begin
# As-yet unneeded big-tag support
			if tag == 0x1f
				tag = 0
				more = true

				while more
					c = ss(s)
					tag = tag * 128 + c & 0x7f
					more = (c & 0x80) == 0x80
					tl += 1
				end
			end
=end

			@tag_length = tl

			s
		end

		def parse_length(s)
			l0, s = ss(s)

			if (l0 & 0x80) == 0
				@data_length = l0
				@length_length = 1
			else
				ll = l0 & 0x7f
				@length_length = ll + 1
				@data_length = ll.times.inject(0) { |a, _| c, s = ss(s); a * 256 + c }
			end

			s
		end

		def parse_data(s)
			if s.length < @data_length
				@data = s
				raise IncompleteDer
			else
				@data = s[0, @data_length]
			end

			s[@data_length..]
		end

		def ss(s)
			raise IncompleteDer if s.empty?

			c, r = s.unpack("Ca*")
			# Make sure that we always return a string as the second element
			[c, r || ""]
		end
	end
end

require_relative "./node/integer"
require_relative "./node/octet_string"
require_relative "./node/null"
require_relative "./node/sequence"
