require_relative "../../spec_helper"
require "derparse/node"

describe DerParse::Node do
	describe "#value" do
		let(:value) { DerParse::Node.factory(der).value }

		context "a small positive integer" do
			let(:der) { "\x02\x01\x2a" }

			it "provides the correct value" do
				expect(value).to eq(42)
			end
		end

		context "a large positive integer" do
			let(:der) { "\x02\x0a\x01\x02\x03\x04\x05\x06\x07\x08\x09\x10" }

			it "provides the correct value" do
				expect(value).to eq(4_759_477_275_222_530_853_136)
			end
		end

		context "a negative integer" do
			let(:der) { "\x02\x03\xfe\xff\xff" }

			it "provides the correct value" do
				expect(value).to eq(-65_537)
			end
		end

		context "an octet string" do
			let(:der) { "\x04\x08der4lyfe" }

			it "returns the string" do
				expect(value).to eq("der4lyfe")
			end
		end

		context "an empty sequence" do
			let(:der) { "0\x00" }

			it "returns an empty array" do
				expect(value).to eq([])
			end
		end

		context "a sequence containing some integers" do
			let(:der) { "0\x10\x02\x01\x01\x02\x01\x01\x02\x01\x02\x02\x01\x03" }

			it "returns an array of integers" do
				expect(value).to eq([1, 1, 2, 3])
			end
		end

		context "a NULL" do
			let(:der) { "\x05\x00" }

			it "returns nil" do
				expect(value).to be(nil)
			end
		end
	end
end
