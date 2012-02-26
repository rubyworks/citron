module Citron

  # Ecapsulate a test case's setup code.
  #
  class TestSetup

    #
    # The test case to which this advice belong.
    #
    attr :context

    #
    # The setup procedures.
    #
    attr :procedures

    #
    # A brief description of the setup.
    #
    attr :label

    #
    # Initialize new Setup instance.
    #
    def initialize(context, label, &proc)
      @context    = context
      @label      = label.to_s
      @procedures = []

      @procedures << proc if proc
    end

    #
    # Copy the setup for a new context.
    #
    def copy(context)
      c = self.class.new(context, label)
      c.procedures = procedures
      c
    end

    #
    # Run setup procedure in test scope.
    #
    def call(scope)
      procedures.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    #
    # Returns the description with newlines removed.
    #
    def to_s
      label.gsub(/\n/, ' ')
    end

    #
    # Add a setup procedure.
    #
    def add(&proc)
      @procedures << proc
    end

  protected

    def procedures=(procedures)
      @procedures = procedures
    end

  end

end
