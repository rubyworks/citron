module Citron

  #
  class TestProc

    # New unit test procedure.
    #
    def initialize(options={}, &procedure)
      @context   = options[:context]
      @setup     = options[:setup]
      @label     = options[:label]
      @tags      = options[:tags]
      @skip      = options[:skip]

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
    # Setup and teardown procedures.
    #
    def setup
      context.setup
    end

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
      @setup
    end

    #
    # Ruby Test looks for `topic` as the desciption of a test's setup.
    #
    def topic
      @setup.to_s
    end

    #
    #def scope
    #  context.scope
    #end

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
    def to_proc
      lambda{ call }
    end

    #
    #def set_proc(&proc)
    #  @procedure = proc
    #end
  end

end
