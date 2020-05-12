require_relative '../spec_helper'
require 'derparse'

describe DerParse do
	describe "#first_node" do
		let(:parser) { DerParse.new(der) }
		let(:first) { parser.first_node }

		context "with a single primitive" do
			let(:der) { "\x02\x01\x00" }

			it "returns the primitive" do
				expect(first).to be_a(DerParse::Node::Integer)
				expect(first.value).to eq(0)
			end
		end

		context "with multiple complete primitives" do
			let(:der) { "\x02\x01\x2a\x02\x01\x45" }

			it "returns the first primitive" do
				expect(first).to be_a(DerParse::Node::Integer)
				expect(first.value).to eq(42)
			end
		end

		context "with a sequence of two primitives" do
			let(:der) { "0\x06\x02\x01\x99\x02\x01\xff" }

			it "returns the sequence" do
				expect(first).to be_a(DerParse::Node::Sequence)
			end
		end
	end
end
