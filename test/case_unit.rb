testcase Array do

  context '#join' do

    test "call Array#join" do
      [1,2,3].join.assert == "123"
    end

    test "unit should be class and method" do
      self.class.unit.assert == "Array#join"
    end

  end

end
