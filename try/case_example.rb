TestCase "Show them how to Beat It" do

  # will fail
  test "show them how to funky" do
    "funky".assert != "funky"
  end

  # will pass
  test "show them what's right" do
    "right".assert == "right"
  end

  # will error
  test "no one wants to be defeated" do
    raise SyntaxError
  end

  # pending
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
