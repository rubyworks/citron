#require 'citron/pending'
#require 'citron/test_context'
require 'citron/test_advice'
require 'citron/test_setup'
require 'citron/test_proc'
require 'citron/world'

module Citron

  # Test Case encapsulates a collection of
  # unit tests organized into groups of contexts.
  #
  class TestCase

    # The parent context in which this case resides.
    attr :context

    # Brief description of the test case.
    attr :label

    # List of tests and sub-cases.
    attr :tests

    # The setup and teardown advice.
    attr :setup

    # Pattern mathing before and after advice.
    attr :advice

    # Module for evaluating tests.
    attr :scope

    # A test case +target+ is a class or module.
    #
    def initialize(settings={}, &block)
      @context = settings[:context]
      @label   = settings[:label]
      @setup   = settings[:setup]
      @skip    = settings[:skip]

      if @context
        @advice = context.advice.clone
      else
        @advice = TestAdvice.new
      end

      @tests = []

      @scope = Scope.new(self)

      @scope.module_eval(&block) if block
    end

    #
    def <<(test_object)
      @tests << test_object
    end

    # Iterate over each test and subcase.
    def each(&block)
      tests.each(&block)
    end

    # Number of tests plus subcases.
    def size
      tests.size
    end

    # Subclasses of TestCase can override this to describe
    # the type of test case they define.
    def type
      'Case'
    end

    #
    def to_s
      label.to_s
    end

    #
    def skip?
      @skip
    end

    #
    def skip=(reason)
      @skip = reason
    end

    # Run test in the context of this case.
    #
    # @param [TestProc] test
    #   The test unit to run.
    #
    def run(test, &block)
      advice[:before].each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end

      block.call

      advice[:after].each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
    end

    #
    class Scope < World

      # Setup new evaluation scope.
      def initialize(testcase) #, &code)
        @_case  = testcase
        @_setup = testcase.setup
        @_skip  = false

        if testcase.context
          extend(testcase.context.scope)
        end
      end

      #--
      # TODO: Instead of reusing TestCase can we have a TestContext
      #       that more generically mimics it's context context?
      #++

      # Create a sub-case.
      def Context(label, &block)
        settings = {
          :context => @_case,
          :setup   => @_setup,
          :skip    => @_skip,
          :label   => label
        }
        testcase = TestCase.new(settings, &block)
        @_case.tests << testcase
        testcase
      end

      alias :context :Context

      # Create a test.
      def Test(label=nil, &procedure)
        settings = {
          :context => @_case,
          :setup   => @_setup,
          :skip    => @_skip,
          :label   => label
        }
        testunit = TestProc.new(settings, &procedure)
        if procedure.arity == 0 || (RUBY_VERSION < '1.9' && procedure.arity == -1)
          @_case.tests << testunit
        else
          @_test = testunit
        end
        testunit
      end

      alias :test :Test

      #
      #
      def Ok(*args)
        test = @_test
        test.arguments = args
        @_case << test
        @_test = nil
        return test
      end

      alias :ok :Ok

      #
      #
      def No(*args)
        test = @_test
        test.arguments = args
        test.negate    = true
        @_case << test
        @_test = nil
        return test
      end

      alias :no :No

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] label
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(label=nil, &proc)
        @_setup = TestSetup.new(@_case, label, &proc)
      end

      alias :setup :Setup

      #alias_method :Concern, :Setup
      #alias_method :concern, :Setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&proc)
        @_setup.teardown = proc
      end

      alias :teardown :Teardown

      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def Before(*matches, &procedure)
        @_case.advice[:before][matches] = procedure
      end

      alias :before :Before

      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # teardown code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def After(*matches, &procedure)
        @_case.advice[:after][matches] = procedure
      end

      alias :after :After

      # Mark tests or subcases to be skipped.
      #
      # @example
      #   skip("reason for skipping") do
      #     test "some test" do
      #       ...
      #     end
      #   end
      #
      def Skip(reason=true, &block)
        @_skip = reason
        block.call
        @_skip = false
      end

      alias :skip :Skip

    end

  end

end
