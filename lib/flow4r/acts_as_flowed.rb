
require 'flow4r'

require 'rubygems'
require 'active_record/base'

module ActiveRecord #:nodoc:
  module Acts #:nodoc:  

    module Flowed

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end    

      module ClassMethods
        def acts_as_flowed(&block)
          return if self.included_modules.include?( ActiveRecord::Acts::Flowed::ActMethods )

          class_eval do
            def self.workflow
              @workflow
            end

            include ActiveRecord::Acts::Flowed::ActMethods    
            @workflow = Flow4r::Workflow.create( &block )

            before_create :flow4r_initialize_start_state
          end
        end
      end # ClassMethods

      module ActMethods
        def flow4r_initialize_start_state
          write_attribute( :status, workflow.start_state.name.to_s )
        end

        def workflow
          self.class.workflow
        end

        def status_label
          case ( status )
            when /^([^\+\-]+)$/
              $1.humanize
            when /^([^\+]+)\-(.*)$/
              "#{$1.humanize} (#{$1.name.humanize} pending)"
            when /^([^\+]+)\+(.*)$/
              "#{$1.humanize} (#{$1.name.humanize} running)"
          end
        end

        def transitioning?
          status =~ /^[^\+\-]+[\+\-].*$/
        end

        def transition_pending?
          status =~ /\-/
        end

        def transition_running?
          status =~ /\+/
        end

        def current_state_name
          case ( status )
            when /^([^\+\-]+)$/
              name = $1.to_sym
            when /^([^\+\-]+)[\+\-].*$/
              name = $1.to_sym
          end 
          name
        end 

        def current_state
          workflow[ current_state_name ]
        end

        def current_transition
          return workflow[ current_state_name.to_sym ][ current_transition_name ] if transitioning?
          nil
        end

        def current_transition_name
          case ( status )
            when /^([^\+\-]+)$/
              nil
            when /^[^\+\-]+[\+\-](.*)$/
              $1.to_sym
          end 
        end

        def transition_via(transition_name)
          raise RuntimeError.new( "already transitioning" ) if transitioning?
          state = current_state
          transition = state[ transition_name ]
          raise RuntimeError.new( "no such transition #{transition_name} from #{state.name}" ) unless transition
          write_attribute( :status, "#{state.name}-#{transition.name}" )
        end

        def complete_transition(transition_name,result)
          raise RuntimeError.new( "transition not running" ) unless transition_running?
          raise RuntimeError.new( "not current transition #{transition_name}" ) unless current_transition_name == transition_name
          transition = current_transition
          destination = workflow[ transition[ result ] ]
          write_attribute( :status, destination.name.to_s )
        end

      end # ActMethods

    end # Flowed

  end # Acts
end # ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Flowed }
