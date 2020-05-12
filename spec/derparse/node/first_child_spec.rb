require_relative "../../spec_helper"
require "derparse/node"

describe DerParse::Node do
	describe "#first_child" do
		let(:first_child) { DerParse::Node.factory(der).first_child }

		context "a small positive integer" do
			let(:der) { "\x02\x01\x2a" }

			it "does not have a child" do
				expect(first_child).to be_nil
			end

			it "returns a nil node" do
				expect(first_child).to be_a(DerParse::Node::Nil)
			end
		end

		context "several integers mushed together" do
			let(:der) { "\x02\x01\x2a\x02\x03\x01\x00\x01\x02\x01\x45" }

			it "does not have a child" do
				expect(first_child).to be_nil
			end
		end

		context "a sequence containing some integers" do
			let(:der) { "0\x10\x02\x01\x01\x02\x01\x01\x02\x01\x02\x02\x01\x03" }

			it "does have a child" do
				expect(first_child).to be_a(DerParse::Node::Integer)
			end

			it "returns the first integer" do
				expect(first_child.value).to eq(1)
			end
		end

		context "an empty sequence" do
			let(:der) { "0\x00" }

			it "does not have a child" do
				expect(first_child).to be_nil
			end
		end
	end
end
