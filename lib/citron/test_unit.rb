module Citron

  #
  class TestUnit

    # New unit test procedure.
    #
    def initialize(parent, options={}, &procedure)
      @parent    = parent

      @setup     = options[:setup]
      @label     = options[:label]
      @omit      = options[:omit]

      @procedure = procedure
      @tested    = false
    end

  public

    # The parent testcase to which this test belongs.
    attr :parent

    # Setup and teardown procedures.
    attr :setup

    # Description of test.
    attr :label

    # Test procedure, in which test assertions should be made.
    attr :procedure

    #
    #def target
    #  context.target
    #end

    # The before and after advice from the context.
    def advice
      parent.advice
    end

    #
    def omit?
      @omit
    end

    #
    def omit=(boolean)
      @omit = boolean
    end

    #
    def tested?
      @tested
    end

    def tested=(boolean)
      @tested = true
    end

    def to_s
      label.to_s
    end

def subject
  @setup
end

    def scope
      parent.scope
    end

    #
    #def description
    #  if function?
    #    #"#{test_case} .#{target} #{aspect}"
    #    "#{test_case}.#{target} #{context} #{aspect}".strip
    #  else
    #    a  = /^[aeiou]/i =~ test_case.to_s ? 'An' : 'A'
    #    #"#{a} #{test_case} receiving ##{target} #{aspect}"
    #    "#{test_case}##{target} #{context} #{aspect}".strip
    #  end
    #end

    def arguments
      []
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
      parent.run(self) do
        setup.run_setup(scope)    if setup
        scope.instance_exec(*arguments, &procedure)
        setup.run_teardown(scope) if setup
      end
    end

  end

end