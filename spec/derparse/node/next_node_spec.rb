require_relative "../../spec_helper"
require "derparse/node"

describe DerParse::Node do
	describe "#next_node" do
		let(:next_node) { DerParse::Node.factory(der).next_node }

		context "a small positive integer" do
			let(:der) { "\x02\x01\x2a" }

			it "does not have a next node" do
				expect(next_node).to be_nil
			end

			it "returns a nil node" do
				expect(next_node).to be_a(DerParse::Node::Nil)
			end
		end

		context "a sequence containing some integers" do
			let(:der) { "0\x10\x02\x01\x01\x02\x01\x01\x02\x01\x02\x02\x01\x03" }

			it "does not have a next node" do
				expect(next_node).to be_nil
			end
		end

		context "several integers mushed together" do
			let(:der) { "\x02\x01\x2a\x02\x03\x01\x00\x01\x02\x01\x45" }

			it "does have a next node" do
				expect(next_node).to be_a(DerParse::Node::Integer)
			end

			it "returns the second node" do
				expect(next_node.value).to eq(65537)
			end
		end
	end
end
