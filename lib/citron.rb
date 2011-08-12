module Citron
  $TEST_SUITE ||= []

  require 'citron/test_case'
  require 'citron/test_proc'
  require 'citron/test_advice'
  require 'citron/test_setup'
end

module Citron
  module DSL

    # Define a general test case.
    def test_case(label, &block)
      $TEST_SUITE << Citron::TestCase.new(:label=>label, &block)
    end

    alias :TestCase :test_case
    alias :testcase :test_case
  end
end

extend Citron::DSL
