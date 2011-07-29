module Citron
  $TEST_SUITE ||= []

  require 'citron/test_case'
  require 'citron/test_unit'
  require 'citron/test_advice'
  require 'citron/test_setup'
end

module Test
  extend self

  # Define a general test case.
  def Case(label, &block)
    $TEST_SUITE << Citron::TestCase.new(nil, :label=>label, &block)
  end

  alias :TestCase  :Case
  alias :test_case :Case
  alias :case :Case
end

extend Test
