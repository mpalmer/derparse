Ever wanted to do terrible, terrible things with DER-encoded ASN.1 data
structures?  Now you can!

While there are plenty of DER parsers out there, they tend to suffer from the
misguided assumption that the data they're parsing is actually valid.  Wild
idea, it'll never catch on.  In contrast, `derparse` makes the opposite
assumption -- that everything is awful.  This means that it makes an attempt to
parse incomplete and, to a limited degree, corrupted DER-encoded data
structures.

Why would you *ever* want this, you might ask?  It's a niche requirement,
undoubtedly, and if you're asking the question, that's a good indication that
`derparse` probably isn't what you're looking for -- `OpenSSL::ASN1` does a
good job of parsing well-formed DER data.


# Installation

It's a gem:

    gem install derparse

There's also the wonders of [the Gemfile](http://bundler.io):

    gem 'derparse'

If you're the sturdy type that likes to run from git:

    rake install

Or, if you've eschewed the convenience of Rubygems entirely, then you
presumably know what to do already.


# Usage

Instantiate a new `DerParse` object, giving it the DER-encoded data you want
to parse:

```ruby
p = DerParse.new("0\x81\x80\x02\x01\x2a\x04\x44\x65\x72\x50\x61\x72\x73\x65\x02\x01\x45\x6e\x69\x63\x65")
```

If you've got multiple DER-encoded strings concatenated, that's no problem --
`DerParse` will handle that.  If you're traversing, you'll get multiple nodes
of depth `0`.

The {`DerParse`} class has a number of instance methods to help you examine and
work with the parsed ASN.1 data.


## Traversing the entire DER tree

If you want to examine every value in the DER, digging down into sequences
and such, then you want `#traverse`.  It walks through every element of the DER, yielding
a {`DerParse::Node`} for each ASN.1 object that is encountered.  When a constructed
element (structure, set) is encountered, a node for the sequence or set will be
yielded, followed by a node for each of the ASN.1 objects in the sequence of set.

```ruby
p.traverse do |node|
  puts "Parsing depth: #{node.depth} Offset: #{node.offset}"
  puts "Header length: #{node.header_length} Data length: #{node.data_length}"
  puts "Tag number: #{node.tag} Tag class: #{node.tag_class} Constructed: #{node.constructed?.inspect}"
  puts "Value: #{node.value rescue nil}"
  puts "INCOMPLETE!" unless node.complete?
end
```

If you call `#traverse` without a block, it'll return an `Enumerator`, which
returns the next node in the DER structure for each call to `#next`.  It is
more convenient when you want to construct parsing state machines.


## Walking around nodes

If you want more control about how you travel through the tree of nodes, you
can get the first node in the DER tree with {`DerParse#first_node`}.  Every
node has {`DerParse#next_node`} and {`DerParse#first_child`} methods, which do
what they say on the tin.  In both cases, if there is no relevant node, a
{`DerParse::Node::Nil`} will be returned.


## Examining a node

There are a whole bunch of methods which {`DerParse::Node`} has to help you
query what sort of ASN.1 object you're dealing with.

It's is particularly important to note the {`DerParse::Node#complete?`} method.
Because `DerParse` tries to give you as much data as it can, even if the DER is
incomplete or corrupt, it needs to let you know when the data it's passing back
is known to not be "correct", in a strict sense.  What counts as an
"incomplete" value, and what impact it has on the value of a given node, can
get complicated.  For full details, see the documentation for
{DerParse#traverse}.


## Finding objects in a corrupted DER

If you're working with a string that is missing its beginning, or has its early
parts corrupted, you can try using the {`DerParse#resync`} method to try and "resync"
the parser, based on knowing that an object of a particular type is in there
*somewhere*.

It works by looking for an encoded ASN.1 object of a type you specify, and returning
a node instance for that object, which you can then traverse using `#next_node`
and `#first_child` (as appropriate).

There is always the risk of a false-positive when using `#resync`, so you
should never 100% trust the values it gives back.  However, to try and minimise
the risk, we assume that the ASN.1 object you're looking for is complete (not
truncated), and that the rest of the string is valid DER.  This means that all
of the lengths remaining in the DER must line up, which isn't particularly
likely to happen at random.

The downside of this validation approach is that if the corruption extends to
having extra "garbage" data at the end of the DER, then `#resync` won't find
anything.  You can turn this off by passing `strict: false` to `#resync`, but
be aware that your false positive rate will skyrocket.


## Rendering as a string

This is quite straightforward.  If a DER consists entirely of object types that
`DerParse` knows how to decode into Ruby values, you can just use `#to_s`:

```ruby
p.to_s   # => "long, multi-line string of something something"
```

which means, of course, that you can print it to screen:

```ruby
puts p
```

If your DER contains an ASN.1 value that `DerParse` doesn't know how to
render, you'll get a {`DerParse::IncompatibleDatatypeError`}.

## A collection of Ruby objects

For this, you can use {`DerParse#to_a`}.  This attempts to turn a DER blob into
a collection of Ruby objects.  It handles many common ASN.1 data types,
including integers, octet and bit strings, sequences and sets (turns them into
arrays), and so on.  If it hits an ASN.1 type it can't handle, it'll give up
and raise {`DerParse::IncompatibleDatatypeError`}.


# Compatibility and Coverage

The parts of ASN.1 that `DerParse` best supports are those which I've needed
for my own purposes -- mainly sequences, integers, octet strings, and to a
lesser extent OIDs.  In particular, it's important to note that `DerParse` is
for ***DER*** structures, so any BER-specific things like indefinite lengths
are not, and probably will never, be supported.  Support for rendering
additional ASN.1 types into specific Ruby objects are welcomed via a
well-tested PR.


# Security

ASN.1 has a long and glorious history of being difficult to parse safely.
While parsing in a memory-safe language reduces the attack surface, I don't
recommend unconstrained parsing of arbitrary input using `DerParse`.
Reasonable care has been taken to not produce any absolute bone-headed bugs,
but this code has not been intensively vetted for potential security issues.

That being said, `DerParse` is intended to be secure, and everyone wants it to
be secure.  If you *do* find anything in `DerParse` that is security sensitive,
please e-mail [`mpalmer@hezmatt.org`](mailto:mpalmer@hezmatt.org).


# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).


# Licence

Unless otherwise stated, everything in this repo is covered by the following
copyright notice:

    Copyright (C) 2020  Matt Palmer <matt@hezmatt.org>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
