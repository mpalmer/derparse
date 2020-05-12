require_relative '../spec_helper'
require 'derparse'

describe DerParse do
	describe "#resync" do
		let(:parser) { DerParse.new(der) }
		let(:node) { parser.resync(tag, strict: strict) }
		let(:strict) { true }

		context "with entirely valid DER" do
			let(:der) { "\x02\x01\x2a\x04\x00\x02\x01\x45" }

			context "when we ask for an integer" do
				let(:tag) { "\x02" }

				it "gives us back our Integer" do
					expect(node).to be_a(DerParse::Node::Integer)
				end

				it "syncs to the beginning" do
					expect(node.offset).to eq(0)
				end

				it "definitely found the correct integer" do
					expect(node.value).to eq(42)
				end
			end

			context "when we ask for an OctetString" do
				let(:tag) { "\x04" }

				it "gives us back our OctetString" do
					expect(node).to be_a(DerParse::Node::OctetString)
				end

				it "gives us the correct string" do
					expect(node.value).to eq("")
				end

				it "gives the correct offset" do
					expect(node.offset).to eq(3)
				end
			end

			context "when we ask for a different type of object" do
				let(:tag) { "\x30" }

				it "gives us back a nil node" do
					expect(node).to be_a(DerParse::Node::Nil)
				end
			end
		end

		context "with junky stuff before a single valid object" do
			let(:der) { "\x00\xff\x02\xff\x04\x81\xab\x02\x01\x2a" }

			context "when we ask for an integer" do
				let(:tag) { "\x02" }

				it "finds an integer" do
					expect(node).to be_a(DerParse::Node::Integer)
				end

				it "finds the valid integer" do
					expect(node.value).to eq(42)
				end

				it "indicates the correct offset to this integer" do
					expect(node.offset).to eq(7)
				end
			end

			context "when we ask for an octet string" do
				let(:tag) { "\x04" }

				it "does not find a valid octet string" do
					expect(node).to be_a(DerParse::Node::Nil)
				end
			end
		end

		context "with junk before several valid objects" do
			let(:der) { "\x00\xff\x02\xff\x04\x81\xab\x02\x01\x2a\x04\x00\x02\x01\x45" }

			context "when we ask for an integer" do
				let(:tag) { "\x02" }

				it "gives us back an Integer" do
					expect(node).to be_a(DerParse::Node::Integer)
				end

				it "definitely found the correct integer" do
					expect(node.value).to eq(42)
				end

				it "gives the correct offset to the integer" do
					expect(node.offset).to eq(7)
				end
			end

			context "when we ask for an OctetString" do
				let(:tag) { "\x04" }

				it "gives us back an OctetString" do
					expect(node).to be_a(DerParse::Node::OctetString)
				end

				it "gives us the valid string" do
					expect(node.value).to eq("")
				end

				it "gives the correct offset" do
					expect(node.offset).to eq(10)
				end
			end

			context "when we ask for a different type of object" do
				let(:tag) { "\x01" }

				it "gives us back a nil node" do
					expect(node).to be_a(DerParse::Node::Nil)
				end
			end
		end

		context "with junky stuff afterwards" do
			let(:der) { "\x02\x01\x2a\xff" }

			context "when we ask for an integer" do
				let(:tag) { "\x02" }

				it "finds nothing" do
					expect(node).to be_a(DerParse::Node::Nil)
				end

				context "in non-strict mode" do
					let(:strict) { false }

					it "finds our integer" do
						expect(node).to be_a(DerParse::Node::Integer)
						expect(node.value).to eq(42)
					end
				end
			end
		end
	end
end
