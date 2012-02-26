module Citron

  # Test Case encapsulates a collection of
  # unit tests organized into groups of contexts.
  #
  class TestCase

    # The parent context in which this case resides.
    attr :context

    # Brief description of the test case.
    attr :label

    # Symbol list of tags. Trailing element may be Hash
    # of `symbol => object`.
    attr :tags

    # List of tests and sub-cases.
    attr :tests

    # The setup advice.
    attr :setup

    # The teardown advice.
    attr :teardown

    # Pattern mathing before and after advice.
    #attr :advice

    # Module for evaluating tests.
    attr :scope

    # A test case +target+ is a class or module.
    #
    def initialize(settings={}, &block)
      @context = settings[:context]
      @label   = settings[:label]
      @tags    = settings[:tags]
      #@setup   = settings[:setup]
      @skip    = settings[:skip]

      if @context
        @setup    = context.setup.copy(self)    if context.setup
        @teardown = context.teardown.copy(self) if context.teardown
      end

      @tests = []

      @scope = Scope.new(self)

      @scope.module_eval(&block) if block
    end

    #
    def setup=(test_setup)
      @setup = test_setup
    end

    #
    def teardown=(test_teardown)
      @teardown = test_teardown
    end

    #
    # Add new test or sub-case.
    #
    def <<(test_object)
      @tests << test_object
    end

    #
    # Iterate over each test and subcase.
    #
    def each(&block)
      tests.each(&block)
    end

    # 
    #def call
    #  yield
    #end

    #
    # Number of tests and sub-cases.
    #
    # @return [Fixnum] size
    #
    def size
      tests.size
    end

    #
    # Subclasses of TestCase can override this to describe
    # the type of test case they define.
    #
    # @return [String]
    #
    #def type
    #  'TestCase'
    #end

    #
    # Test case label.
    #
    # @return [String]
    #
    def to_s
      label.to_s
    end

    #
    # Is test case to be skipped?
    #
    def skip?
      @skip
    end

    #
    # Set test case to be skipped.
    #
    def skip=(reason)
      @skip = reason
    end

    #
    # Run +test+ in the context of this case.
    #
    # @param [TestProc] test
    #   The test unit to run.
    #
    def run(test)
      setup.call(scope) if setup
      #scope.instance_exec(*arguments, &procedure)
      scope.instance_eval(&test.procedure)
      teardown.call(scope) if teardown
    end

    #
    class Scope < World

      #
      # Initialize new evaluation scope.
      #
      def initialize(testcase) #, &code)
        @_case  = testcase
        @_setup = testcase.setup
        @_skip  = false

        if testcase.context
          extend(testcase.context.scope)
        end
      end

      # TODO: Instead of reusing TestCase can we have a TestContext
      #       that more generically mimics it's context?

      #
      # Create a sub-case.
      #
      def Context(label, *tags, &block)
        settings = {
          :context => @_case,
          #:setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags
        }

        testcase = TestCase.new(settings, &block)

        @_case.tests << testcase

        testcase
      end

      alias :context :Context

      #
      # Create a test, or a parameterized test.
      #
      def Test(label=nil, *tags, &procedure)
        settings = {
          :context => @_case,
          #:setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags
        }

        if procedure.arity == 0 || (RUBY_VERSION < '1.9' && procedure.arity == -1)
          test = TestProc.new(settings, &procedure)
          @_case.tests << test
          @_test = nil
          test
        else
          @_test = [settings, procedure]
        end
      end

      alias :test :Test

      #
      # Actualize a parameterized test.
      #
      # @todo Better name than `Ok` ?
      #
      def Ok(*args)
        settings, procedure = *@_test

        test = TestProc.new(settings) do
          procedure.call(*args)
        end

        @_case << test
        #@_test = nil

        return test
      end

      alias :ok :Ok

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] label
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(label=nil, &proc)
        if proc
          @_case.setup    = TestSetup.new(@_case, label, &proc)
          @_case.teardown = nil  # if the setup is reset, then so it the teardown
        else
          @_case.setup
        end
      end

      alias :setup :Setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&proc)
        if proc
          @_case.teardown = TestTeardown.new(@_case, &proc)
        else
          @_case.teardown
        end
      end

      alias :teardown :Teardown

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

=begin
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
=end

    end

  end

end
