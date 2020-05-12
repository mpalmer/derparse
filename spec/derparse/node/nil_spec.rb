require_relative "../../spec_helper"

require "derparse"

describe DerParse::Node::Nil do
	let(:node) { DerParse::Node::Nil.new }
	it "is a type of node" do
		expect(node).to be_a_kind_of(DerParse::Node)
	end

	it "smells like nil" do
		expect(node).to be_nil
	end

	it "doesn't have a next_node" do
		expect(node.next_node).to be_a(DerParse::Node::Nil)
	end

	it "doesn't have a child" do
		expect(node.first_child).to be_a(DerParse::Node::Nil)
	end

	it "doesn't have a value" do
		expect(node.value).to eq(nil)
	end
end

