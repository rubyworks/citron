testcase "Example of using setup in a testcase" do
  setup "the number one" do
    @x = 1
  end

  test "has setup without a topic" do
    @x.assert == 1
  end

  context "sub-case inherits parent setup" do
    test "has setup" do
      @x.assert == 1
    end
  end

  context "sub-case with setup override parent setup" do
    setup "has setup" do
      @y = 10
    end

    test "has setup" do
      @x.assert == nil
      @y.assert == 10
    end
  end
end
