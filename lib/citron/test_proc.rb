module Citron

  # Test procedure --what you would call a honest to goodness unit test.
  #
  class TestProc

    # New unit test procedure.
    #
    def initialize(options={}, &procedure)
      @context   = options[:context]
      #@setup     = options[:setup]
      @label     = options[:label]
      @tags      = options[:tags]
      @skip      = options[:skip]
      @file      = options[:file]
      @line      = options[:line]

      @procedure = procedure
      @tested    = false
    end

  public

    #
    # The parent testcase to which this test belongs.
    #
    attr :context

    #
    # Alias for `#context`.
    #
    alias :parent :context

    #
    # Description of test.
    #
    attr :label

    #
    # Symbol list of tags. Trailing element may be Hash
    # of `symbol => object`.
    #
    attr :tags

    #
    # Test procedure, in which test assertions should be made.
    #
    attr :procedure

    #
    #
    #
    #def type
    #  'test'
    #end

    #
    # Whether to skip this test.
    #
    # @return [Boolean,String]
    #
    def skip? ; @skip ; end

    #
    # Set whether this test should be skipped of not.
    #
    # @param [Boolean,String] reason
    #   Reason to skip, or simple boolean flag.
    #
    def skip=(reason)
      @skip = reason
    end

    #
    # @todo Is this necessary?
    #
    def tested?
      @tested
    end

    #
    # @todo Is this necessary?
    #
    def tested=(boolean)
      @tested = !!boolean
    end

    #
    # Test description.
    #
    # @return [String]
    #
    def to_s
      label.to_s
    end

    #
    # @return [TestSetup] setup
    #
    def setup
      @context.setup
    end

    #
    # Ruby Test looks for `#topic` as the desciption of a test's setup.
    #
    # @return [String] Description of the setup.
    #
    def topic
      setup.to_s
    end

    # 
    # Location of test definition.
    #
    def source_location
      [file, line]
    end

    #
    # Match test's label and/or tags.
    #
    # @param [String,Symbol,Regexp,Hash] match
    #   Pattern to match against.
    #
    # @return [Boolean]
    #
    def match?(match)
      case match
      when Symbol
        tags.include?(match)
      when Hash
        if Hash === tags.last
          tags.last.any?{ |k,v| match[k] == v }
        end
      else
        match === label
      end
    end

    #
    # Run this test in context.
    #
    def call
      context.run(self)
    end

    #
    # Convert `#call` to Proc.
    #
    # @return [Proc]
    #
    def to_proc
      lambda{ call }
    end

    #
    #def set_proc(&proc)
    #  @procedure = proc
    #end

    class Scope < World

      def initialize(parent)
        #include context
        @_parent = parent
        extend parent
      end

    end

  end

end
