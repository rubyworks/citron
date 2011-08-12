module Citron

  #
  class TestProc

    # New unit test procedure.
    #
    def initialize(options={}, &procedure)
      @context   = options[:context]
      @setup     = options[:setup]
      @label     = options[:label]
      @skip      = options[:skip]

      @procedure = procedure
      @tested    = false
    end

  public

    # The parent testcase to which this test belongs.
    attr :context

    #
    alias :parent :context

    # Setup and teardown procedures.
    attr :setup

    # Description of test.
    attr :label

    # Test procedure, in which test assertions should be made.
    attr :procedure

    # The before and after advice from the context.
    def advice
      context.advice
    end

    #
    def type
      'Test'
    end

    #
    def skip? ; @skip ; end

    #
    def skip=(reason)
      @skip = reason
    end

    #
    def tested?
      @tested
    end

    #
    def tested=(boolean)
      @tested = !!boolean
    end

    #
    def to_s
      label.to_s
    end

    #
    def setup
      @setup
    end

    # Ruby Test looks for `topic` as the desciption of a test's setup.
    def topic
      @setup.to_s
    end

    #
    def scope
      context.scope
    end

    #
    def arguments
      @arguments
    end

    #
    def arguments=(args)
      @arguments = args
    end

    # TODO: how to handle negated tests?
    def negate
      @negate
    end

    #
    def negate=(boolean)
      @negate = !!boolean
    end

    #
    def to_proc
      lambda{ call }
    end

    #
    def match?(match)
      match == target || match === description
    end

    #
    def call
      context.run(self) do
        setup.run_setup(scope)    if setup
        scope.instance_exec(*arguments, &procedure)
        setup.run_teardown(scope) if setup
      end
    end

  end

end
