#require 'citron/pending'
#require 'citron/test_context'
require 'citron/test_advice'
require 'citron/test_setup'

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

    # Advice are labeled procedures, such as before
    # and after advice.
    attr :advice

    # Module for evaluating tests.
    attr :scope

    # A test case +target+ is a class or module.
    #
    # @param [TestSuite] context
    #   The test suite or parent case to which this
    #   case belongs.
    #
    # @param [Class,Module] target
    #   A description of the test-case's purpose.
    #
    def initialize(parent, settings={}, &block)
      if parent
        @parent = parent
        @advice = parent.advice.clone
      else
        @parent = nil
        @advice = TestAdvice.new
      end

      @label   = settings[:label]
      @setup   = settings[:setup]

      @scope   = Module.new

      if parent
        @scope.extend(parent.scope)
      end

      @tests   = []

      # TODO: Don't really like this here, but how else to do it?
      $TEST_SUITE << self

      domain_eval(&block)
    end

    #
    def domain_eval(&block)
      domain = self.class.const_get(:DSL).new(self, &block)
      @scope.extend domain
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
      "#{type}: " + @label.to_s
    end

    #
    def omit?
      @omit
    end

    #
    def omit=(boolean)
      @omit = boolean
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
    #--
    # TODO: Change so that the scope is the DSL
    #       and ** includes the DSL of the context ** !!!
    #++
    #def scope
    #  @scope ||= (
    #    scope = Object.new
    #    scope.extend(domain)
    #    scope
    #  )
    #end

    #
    class DSL < Module

      #
      def initialize(testcase, &code)
        @_case  = testcase
        @_setup = testcase.setup

        module_eval(&code)
      end

      # Create a sub-case.
      #--
      # @TODO: Instead of resuing TestCase can we have a TestContext
      #        that more generically mimics it's parent context?
      #++
      def Context(label, &block)
        settings = {
          :label => label,
          :setup => @_setup
        }
        testcase = TestCase.new(@_case, settings, &block)
        @_case.tests << testcase
        testcase
      end
      alias_method :context, :Context

      # Create a test.
      def Test(label=nil, &procedure)
        settings = {
          :label => label,
          :setup => @_setup
        }
        testunit = TestUnit.new(@_case, settings, &procedure)
        if procedure.arity == 0
          @_case.tests << testunit
        else
          @_test = testunit
        end
        testunit
      end
      alias_method :test, :Test

      #
      #
      #
      def Ok(*args)
        test = @_test
        test.arguments = args
        @_case << test
        @_test = nil
        return test
      end

      #
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

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(description=nil, &procedure)
        if procedure
          @_setup = TestSetup.new(@_case, description, &procedure)
        end
      end

      alias_method :setup, :Setup

      #alias_method :Concern, :Setup
      #alias_method :concern, :Setup

      #alias_method :Subject, :Setup
      #alias_method :subject, :Setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&procedure)
        @_setup.teardown = procedure
      end

      alias_method :teardown, :Teardown

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

      alias_method :before, :Before

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

      alias_method :after, :After

      # Mark a test or testcase to be omitted.
      #
      def Omit(test_obect)
        test_object.omit = true
      end

    end

  end

end