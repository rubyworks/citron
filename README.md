# Citron

[Website](http://rubyworks.github.com/citron) /
[Report Issue](http://github.com/rubyworks/citron/issues) /
[IRC Channel](irc://chat.us.freenode.net/rubyworks) /
[Mailing List](http://groups.google.com/groups/rubyworks-mailinglist) /
[Development](http://github.com/rubyworks/citron)

[![Build Status](https://secure.travis-ci.org/rubyworks/citron.png)](http://travis-ci.org/rubyworks/citron)


## Description

Citron is a classical unit testing framework. It defines a simple
domain language for creating traditionally modeled unit tests.


## Installation

Using Rubygems simply install `citron`:

    $ gem install citron

Citron depends on `ansi` for terminal colorization and `rubytest`,
so those will be installed as well if they are not already.


## Instruction

Citon tests are written as a collection of testcase and test blocks.
Here is a fun example. We'll call the test file `test/test_beatit.rb`:

```ruby
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

    end
```

Citron doesn't dictate the assertions system you use. In the above example, we are using
the [A.E.](http://rubyworks.github.com/ae) assertion framework. You can use any [BRASS](http://rubyworks.github.com)
compliant system you prefer.

Citron is built on top of [RubyTest](http://rubyworks.github.com/rubytest).
Jump over to its website to learn how to run tests and setup test run profiles.


## Copyrights

Copyright (c) 2011 Rubyworks

Citron is distributable according to the terms of the **FreeBSD** license.

See COPYING.md for details.

