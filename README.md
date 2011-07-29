# Citron

<table>
<tr><td><b>Author   </b></td><td>Thomas Sawyer</td></tr>
<tr><td><b>License  </b></td><td>FreeBSD</td></tr>
<tr><td><b>Copyright</b></td><td>(c) 2011 Thomas Sawyer, Rubyworks</td></tr>
</table>

## Description

Citron is a classic unit test framework. It defines a simple
domain language for create classic-style tests.

## Example

Here's a fun example.

``` ruby
TestCase "Show them how to Beat It" do

  # fail
  test "show them how to funky" do
    "funky".assert != "funky"
  end

  # pass
  test "show them what's right" do
    "right".assert == "right"
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
```

## License

Copyright (c) 2011 Thomas Sawyer, Rubyworks

Citron is distributed according to the terms of the FreeBSD license.

See COPYING.rd for details.

