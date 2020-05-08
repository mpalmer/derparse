require_relative '../spec_helper'
require 'derparse'

describe DerParse do
	describe "#traverse" do
		let(:parser) { DerParse.new(der) }
		def traverse
			->(b) { parser.traverse(&b) }
		end

		context "when passed a block" do
			context "with a single complete primitive" do
				let(:der) { "\x02\x01\x00" }

				it "yields once" do
					expect(&traverse).to yield_with_args(instance_of(DerParse::Node::Integer))
				end

				it "does not modify the original string" do
					der.freeze

					parser.traverse { true }
				end

				it "returns itself" do
					dp = DerParse.new(der)

					expect(dp.traverse { |n| true }).to eq(dp)
				end
			end

			context "with multiple complete primitives" do
				let(:der) { "\x02\x01\x2a\x02\x01\x45" }

				it "yields twice" do
					expect(&traverse).to yield_successive_args(
						instance_of(DerParse::Node::Integer),
						instance_of(DerParse::Node::Integer),
					)
				end
			end

			context "with a sequence of two primitives" do
				let(:der) { "0\x06\x02\x01\x99\x02\x01\xff" }

				it "yields thrice" do
					expect(&traverse).to yield_successive_args(
						instance_of(DerParse::Node::Sequence),
						instance_of(DerParse::Node::Integer),
						instance_of(DerParse::Node::Integer),
					)
				end
			end
		end

		context "when not passed a block" do
			context "with a sequence of two primitives" do
				let(:der) { "0\x08\x02\x03\x01\x00\x01\x02\x01\x00" }

				it "returns an enumerator" do
					expect(parser.traverse).to be_an(Enumerator)
				end

				context "the enumerator" do
					let(:enum) { parser.traverse }

					it "dumps out the nodes one by one" do
						expect(enum.next).to be_a(DerParse::Node::Sequence)
						expect(enum.next).to be_a(DerParse::Node::Integer)
						expect(enum.next).to be_a(DerParse::Node::Integer)
						expect { enum.next }.to raise_error(StopIteration)
					end
				end
			end
		end
	end
end
