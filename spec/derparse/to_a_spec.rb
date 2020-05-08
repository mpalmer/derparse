require_relative '../spec_helper'
require 'derparse'

describe DerParse do
	describe "#to_a" do
		let(:parser) { DerParse.new(der) }

		context "with an empty DER" do
			let(:der) { "" }

			it "returns an empty array" do
				expect(parser.to_a).to eq([])
			end
		end

		context "with a single primitive value" do
			let(:der) { "\x02\x01\x42" }

			it "returns a single-element array" do
				expect(parser.to_a).to eq([66])
			end
		end

		context "with the concatenation of several primitive values" do
			let(:der) { "\x02\x01\x42\x02\x01\x00\x02\x03\x00\xff\xff" }

			it "returns an array containing all the values" do
				expect(parser.to_a).to eq([66, 0, 65535])
			end
		end

		context "with a sequence of primitives and a NULL concatenated together" do
			let(:der) { "\x30\x09\x02\x01\x45\x04\x04\x6e\x69\x63\x65\x05\x01\x00" }

			it "returns a nested array" do
				expect(parser.to_a).to eq([[69, "nice"], nil])
			end
		end

		context "with incomprehensible DER" do
			let(:der) { "\x42" }

			it "raises a suitable exception" do
				expect { parser.to_a }.to raise_error(DerParse::IncompatibleDatatypeError)
			end
		end
	end
end
