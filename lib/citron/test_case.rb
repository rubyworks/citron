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

    # Code unit that is subject of test case.
    attr :unit

    # Module for evaluating tests.
    attr :scope

  private

    # Initialize new TestCase.
    #
    def initialize(settings={}, &block)
      @context = settings[:context]
      @label   = settings[:label]
      @tags    = settings[:tags]
      #@setup  = settings[:setup]
      @skip    = settings[:skip]

      @unit    = calc_unit

      if context
        @setup    = context.setup.copy(self)    if context.setup
        @teardown = context.teardown.copy(self) if context.teardown
      end

      @tests = []

      @scope = Scope.new(self)

      @scope.module_eval(&block) if block
    end

    #
    def calc_unit
      case @label
      when Module, Class
        @label
      when /^(\.|\#|\:\:)\w+/
        if @context && Module === @context.unit
          [@context.unit, @label].join('')
        else
          @label
        end
      end
    end

  public

    #
    # Assign the setup procedure
    #
    # @param [TestSetup] test_setup
    #
    def setup=(test_setup)
      @setup = test_setup
    end

    #
    # Assign the teardown procedure.
    #
    # @param [TestTeardown] test_teardown
    #
    def teardown=(test_teardown)
      @teardown = test_teardown
    end

    #
    # Add new test or sub-case.
    #
    # @param [TestCase,TestProc] test_obejct
    #   Test sub-case or procedure to add to this case.
    #
    def <<(test_object)
      @tests << test_object
    end

    #
    # Iterate over each test and sub-case.
    #
    # @param [Proc] block
    #   Iteration procedure.
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
    # @return [Boolean,String]
    #   If +false+ or +nil+ if not skipped, otherwise
    #   +true+ or a string explain why to skip.
    #
    def skip?
      @skip
    end

    #
    # Set test case to be skipped.
    #
    # @param [Boolean,String] reason
    #   Set to +false+ or +nil+ if not skipped, otherwise
    #   +true+ or a string explain why to skip.
    #
    def skip=(reason)
      @skip = reason
    end

    def test_scope
      @test_scope ||= TestProc::Scope.new(scope)
    end

    #
    # Run +test+ in the context of this case.
    #
    # @param [TestProc] test
    #   The test unit to run.
    #
    def run(test)
      setup.call(test_scope) if setup
      #scope.instance_exec(*arguments, &procedure)
      test_scope.instance_eval(&test.procedure)
      teardown.call(test_scope) if teardown
    end

    # The evaluation scope for a test case.
    #
    class Scope < World

      #
      # Initialize new evaluation scope.
      #
      # @param [TestCase] testcase
      #   The test case this scope belongs.
      #
      def initialize(testcase) #, &code)
        @_case  = testcase
        @_setup = testcase.setup
        @_skip  = false

        if testcase.context
          include(testcase.context.scope)
        end
      end

      #
      # Create a sub-case.
      #
      # @param [String] label
      #   The breif description of the test case.
      #
      # @param [Array<Symbol,Hash>] tags
      #   List of symbols with optional trailing `symbol=>object` hash.
      #   These can be used as a means of filtering tests.
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
      # @param [String] label
      #   The breif description of the test case.
      #
      # @param [Array<Symbol,Hash>] tags
      #   List of symbols with optional trailing `symbol=>object` hash.
      #   These can be used as a means of filtering tests.
      #
      def Test(label=nil, *tags, &procedure)
        file, line, _ = *caller[0].split(':')

        settings = {
          :context => @_case,
          #:setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          :file    => file,
          :line    => line
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

        return test
      end

      alias :ok :Ok

      #
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

      #
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

      #
      # Mark tests or sub-cases to be skipped. If block is given, then
      # tests defined within the block are skipped. Without a block
      # all subsquent tests defined in a context will be skipped.
      #
      # @param [Boolean,String] reason
      #   Set to +false+ or +nil+ if not skipped, otherwise
      #   +true+ or a string explain why to skip.
      #
      # @example
      #   skip("awaiting new feature") do
      #     test "some test" do
      #       ...
      #     end
      #   end
      #
      # @example
      #   skip("not on jruby") if jruby?
      #   test "some test" do
      #     ...
      #   end
      #
      def Skip(reason=true, &block)
        if block
          @_skip = reason
          block.call if block
          @_skip = false
        else
          @_skip = reason
        end
      end

      alias :skip :Skip

    end

  end

end
