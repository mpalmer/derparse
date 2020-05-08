require_relative '../spec_helper'
require 'derparse'

describe DerParse do
	describe ".new" do
		it "requires an argument" do
			expect { DerParse.new }.to raise_error(ArgumentError)
		end

		it "accepts a string to parse" do
			expect { DerParse.new("ohai!") }.to_not raise_error
		end

		it "accepts any other type that can be converted to a string" do
			k = Class.new
			k.class_eval { def to_str; to_s; end }

			expect { DerParse.new(k.new) }.to_not raise_error
		end

		it "rejects any type of argument that cannot be converted to a string" do
			x = 42

			expect { DerParse.new(x) }.to raise_error(ArgumentError)
		end
	end
end
