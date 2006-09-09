
module Flow4r

  class Workflow

    def self.create(&block)
      workflow_builder = WorkflowBuilder.new(&block)
      workflow_builder.workflow
    end

    def initialize()
      @start_state    = nil
      @states_by_name = {}
    end

    def <<(state)
      @start_state = state unless @start_state
      @states_by_name[ state.name ] = state
    end
    def [](name)
      @states_by_name[ name ]
    end
    def start_state
      @start_state
    end
  end

  class State
    def initialize(name)
      @name = name
      @transitions_ordered = []
      @transitions_by_name = {}
    end
    def name
      @name
    end
    def <<(transition)
      @transitions_ordered << transition
      @transitions_by_name[ transition.name ] = transition
    end
    def [](name)
      @transitions_by_name[ name ]
    end
  end

  class Transition
    def initialize(name,options={},&block)
      @name = name
      @auto = options[ :auto ] || false
      @block = block
      @destinations = {}
      options.each do |key, value|
        if ( key.to_s =~ /^on_(.*)$/ )
          @destinations[ $1.to_sym ] = value
        end
      end
    end
    def name
      @name
    end
    def block
      @block
    end
    def [](result)
      @destinations[ result.to_sym ]
    end
  end

  class WorkflowBuilder
    def initialize(&block)
      @workflow = Workflow.new
      block.call( self ) if block
    end
    def workflow
      @workflow
    end
    def method_missing(sym,*args,&block)
      state = StateBuilder.new(sym,&block).state
      @workflow << state
    end
  end

  class StateBuilder
    def initialize(name,&block)
      @state = State.new( name )
      block.call( self ) if block
    end
    def state
      @state
    end
    def method_missing(sym,*args,&block)
      options = args[0]
      transition = TransitionBuilder.new(sym,options,&block).transition
      @state << transition
    end
  end

  class TransitionBuilder
    def initialize(name,options={},&block)
      @transition = Transition.new( name, options, &block )
    end
    def transition
      @transition
    end
  end

end
