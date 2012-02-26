testcase "Test Scope" do

  def helper_method
    "helped!"
  end

  test "can use helper method" do
    helper_method.assert == "helped!"
  end

  context "sub-case inherits helpers" do

    test "can use helper method" do
      helper_method.assert == "helped!"
    end

  end

  test "test can't access case methods" do
    #expect NoMethodError do
      method(:setup)
    #end
  end

end
