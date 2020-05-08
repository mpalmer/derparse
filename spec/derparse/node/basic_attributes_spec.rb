require_relative "../../spec_helper"
require "derparse/node"

describe DerParse::Node do
	let(:node) { DerParse::Node.new("\x02\x01\x2a") }

	describe "#tag" do
		it "returns the tag number" do
			expect(node.tag).to eq(2)
		end
	end

	describe "#tag_class" do
		it "returns the tag class number" do
			expect(node.tag_class).to eq(0)
		end
	end

	describe "#constructed?" do
		it "indicates whether the node is constructed" do
			expect(node.constructed?).to eq(false)
		end
	end

	describe "#primitive?" do
		it "indicates whether the node is primitive" do
			expect(node.primitive?).to eq(true)
		end
	end

	describe "#header_length" do
		it "returns the length of the TLV header" do
			expect(node.header_length).to eq(2)
		end
	end

	describe "#data_length" do
		it "returns the purported length of the data" do
			expect(node.data_length).to eq(1)
		end
	end

	describe "#der_length" do
		it "returns the length of the entire DER encoding for this node" do
			expect(node.der_length).to eq(3)
		end
	end

	describe "#complete?" do
		it "indicates whether the node is complete" do
			expect(node.complete?).to eq(true)
		end
	end

	describe "#data" do
		it "returns the raw data portion of the node" do
			expect(node.data).to eq("*")
		end
	end

	describe "#offset" do
		it "returns the default" do
			expect(node.offset).to eq(0)
		end
	end

	describe "#depth" do
		it "returns the default" do
			expect(node.offset).to eq(0)
		end
	end

	describe "#rest" do
		it "has no leftover DER" do
			expect(node.rest).to eq("")
		end
	end

	context "with a specified depth and offset" do
		let(:node) { DerParse::Node.new("\x02\x01\x00", offset: 4, depth: 2) }

		describe "#offset" do
			it "returns the specified offset" do
				expect(node.offset).to eq(4)
			end
		end

		describe "#depth" do
			it "returns the specified depth" do
				expect(node.depth).to eq(2)
			end
		end
	end

	context "with extra DER afterwards" do
		let(:node) { DerParse::Node.new("\x02\x01\x00\x00") }

		describe "#rest" do
			it "returns the excess DER" do
				expect(node.rest).to eq("\x00")
			end
		end
	end

	context "with incomplete data" do
		let(:node) { DerParse::Node.new("\x02\x02\x00") }

		describe "#data" do
			it "returns what data it has" do
				expect(node.data).to eq("\x00")
			end
		end

		describe "#data_length" do
			it "returns what the data length *should* have been" do
				expect(node.data_length).to eq(2)
			end
		end

		describe "#complete?" do
			it "indicates a lack of completeness" do
				expect(node.complete?).to eq(false)
			end
		end
	end

	context "with an incomplete header" do
		let(:node) { DerParse::Node.new("\x02\x84\xff\xff\xff") }

		describe "#data" do
			it "returns nil" do
				expect(node.data).to be(nil)
			end
		end

		describe "#header_length" do
			it "describes what the header length *should* have been" do
				expect(node.header_length).to eq(6)
			end
		end

		describe "#complete?" do
			it "indicates a lack of completeness" do
				expect(node.complete?).to eq(false)
			end
		end
	end
end
