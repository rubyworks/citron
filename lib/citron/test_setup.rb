module Citron

  # Test Setup/Concern - Setup and Teardown code.
  class TestSetup

    # The test case to which this advice belong.
    attr :context

    # A brief description of this concern.
    attr :label

    # The setup procedure.
    attr :setup

    # The teardown procedure.
    attr :teardown

    # New case instance.
    def initialize(context, label, options={}, &setup)
      @context   = context
      @label     = label.to_s
      @setup     = [setup].flatten
      @teardown  = []
    end

    #
    def teardown=(procedure)
      @teardown = [procedure]
    end

    # Setup.
    def run_setup(scope)
      setup.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    # Teardown.
    def run_teardown(scope)
      teardown.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    # Returns the description with newlines removed.
    def to_s
      label.gsub(/\n/, ' ')
    end
  end

end
