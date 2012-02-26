test_case "Example of using setup in a testcase" do

  setup do
    @x = 1
  end

  test "has setup without a topic" do
    @x.assert == 1
  end

  setup "has a topic" do
    @x = 10
  end

  test "has setup with a topic" do
    @x.assert == 10
  end

  test "alos has setup with a topic" do
    @x.assert! == 5
  end

end
