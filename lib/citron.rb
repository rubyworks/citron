$TEST_SUITE ||= []

module Citron
  require 'citron/world'
  require 'citron/test_setup'
  require 'citron/test_teardown'
  require 'citron/test_proc'
  require 'citron/test_case'

  module DSL
    #
    # Define a general test case.
    #
    def test_case(label, &block)
      $TEST_SUITE << Citron::TestCase.new(:label=>label, &block)
    end

    alias :TestCase :test_case
    alias :testcase :test_case
  end

end

extend Citron::DSL

