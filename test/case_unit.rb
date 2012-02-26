testcase Array do

  context '#join' do

    test "call Array#join" do
      [1,2,3].join.assert == "123"
    end

    test "unit should be class and method" do
      @_parent.instance_variable_get(:@_case).unit.assert == "Array#join"
    end

  end

end
