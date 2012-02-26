# Citron

[Website](http://rubyworks.github.com/citron) /
[Development](http://github.com/rubyworks/citron) /
[Report Issue](http://github.com/rubyworks/citron/issues) /


## Description

Citron is a traditional unit test framework. It defines a simple
domain language for creating classically styled unit tests.


## Example

Here's a fun example.

    TestCase "Show them how to Beat It" do

      setup do
        @funky = "funky"
        @right = "right"
      end

      # fail
      test "show them how to funky" do
        @funky.assert != "funky"
      end

      # pass
      test "show them what's right" do
        @right.assert == "right"
      end

      # error
      test "no one wants to be defeated" do
        raise SyntaxError
      end

      # todo
      test "better do what you can" do
        raise NotImplementedError
      end

      # omit
      test "just beat it" do
        e = NotImplementedError.new
        e.set_assertion(true)
        raise e
      end

    end


## Copyrights

Copyright (c) 2011 Rubyworks

Citron is distributable according to the terms of the **FreeBSD** license.

See COPYING.md for details.

