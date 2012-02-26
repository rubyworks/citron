module Citron

  # Test Case encapsulates a collection of
  # unit tests organized into groups of contexts.
  #
  class TestCase < World

    class << self

      # Brief description of the test case.
      attr :label

      # Symbol list of tags. Trailing element may be Hash
      # of `symbol => object`.
      attr :tags

      # List of tests and sub-cases.
      attr :tests

      # Code unit that is subject of test case.
      attr :unit

      # Initialize new TestCase.
      #
      def __set__(settings={}, &block)
        @label   = settings[:label]
        @tags    = settings[:tags]
        @skip    = settings[:skip]

        @unit    = calc_unit(@label)

        @tests   = []

        class_eval(&block)
      end

      #
      #
      #
      def calc_unit(label)
        case label
        when Module, Class
          @label
        when /^(\.|\#|\:\:)\w+/
          if Module === superclass.unit
            [superclass.unit, @label].join('')
          else
            @label
          end
        end
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
      # Add new test or sub-case.
      #
      # @param [Class<TestCase>,TestProc] test_obejct
      #   Test sub-case or procedure to add to this case.
      #
      def <<(test_object)
        @tests ||= []
        @tests << test_object
      end

      # 
      #def call
      #  yield
      #end

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
        context = Class.new(self)
        context.__set__(
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          &block
        )

        self << context

        context
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
          :context => self,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          :file    => file,
          :line    => line
        }

        if procedure.arity == 0 || (RUBY_VERSION < '1.9' && procedure.arity == -1)
          test = TestProc.new(settings, &procedure)

          self << test

          @_test = nil

          return test
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

        self << test

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
        define_method(:setup, &proc)
        # if the setup is reset, then so should the teardown
        define_method(:teardown){}
      end

      alias :setup :Setup

      #
      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&proc)
        define_method(:teardown, &proc)
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

      alias :inspect :to_s

      #
      # Test case label.
      #
      # @return [String]
      #
      def to_s
        label.to_s
      end

    end

    #
    # Iterate over each test and sub-case.
    #
    def each
      self.class.tests.each do |test_object|
        case test_object
        when Class #TestCase
          yield(test_object.new)
        when TestProc
          yield(test_object.for(self))
        end
      end
    end

    #
    # Number of tests and sub-cases.
    #
    # @return [Fixnum] size
    #
    def size
      self.class.tests.size
    end

    #
    # Test case label.
    #
    # @return [String]
    #
    def to_s
      self.class.label.to_s
    end

    #
    # Dummy method for setup.
    #
    def setup
    end

    #
    # Dummy method for teardown.
    #
    def teardown
    end

  end

end
