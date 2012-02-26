module Citron

  # Ecapsulate a test case's teardown code.
  #
  class TestTeardown

    #
    # The test case to which this advice belong.
    #
    attr :context

    #
    # The setup procedures.
    #
    attr :procedures

    #
    # Initialize new Setup instance.
    #
    def initialize(context, &proc)
      @context    = context
      @procedures = []

      @procedures << proc if proc
    end

    #
    # Copy the teardown for a new context.
    #
    def copy(context)
      c = self.class.new(context)
      c.procedures = procedures
      c
    end

    #
    # Run teardown procedure in test scope.
    #
    def call(scope)
      procedures.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    #
    # Add a teardown procedure.
    #
    def add(&proc)
      procedures << proc
    end

  protected

    def procedures=(procedures)
      @procedures = procedures
    end

  end

end
