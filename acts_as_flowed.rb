
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

        def current_state_name
          case ( status )
            when /^([^\+\-]+)$/
              $1
            when /^([^\+\-]+)[\+\-].*$/
              $1
          end 
        end 

        def current_transition_name
          case ( status )
            when /^([^\+\-]+)$/
              nil
            when /^[^\+\-]+[\+\-](.*)$/
              $1
          end 
        end

      end # ActMethods

    end # Flowed

  end # Acts
end # ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Flowed }
