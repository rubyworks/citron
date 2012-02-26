$TEST_SUITE ||= []

module Citron
  require 'citron/world'
  require 'citron/test_proc'
  require 'citron/test_case'

  module DSL
    #
    # Define a general test case.
    #
    def test_case(label, *tags, &block)
      testcase = Citron::TestCase.context(label, *tags, &block)
      $TEST_SUITE << testcase.new
    end

    alias :TestCase :test_case
    alias :testcase :test_case
  end

end

extend Citron::DSL

