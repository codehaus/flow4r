require 'flow4r/acts_as_flowed'

class TestObject < ActiveRecord::Base
  acts_as_flowed do |states|
    states.start do |transitions|
      transitions.finish( :on_success=>:finish ) do |obj|
        puts "transitioning #{obj}"
      end
      transitions.go_to_middle_auto( :on_success=>:middle_auto ) 
      transitions.go_to_middle_manual( :on_success=>:middle_manual ) 
    end 
    states.middle_auto do |transitions|
      transitions.complete( :on_success=>:finish, :auto=>true )
    end
    states.middle_manual do |transitions|
      transitions.complete( :on_success=>:finish )
    end
    states.finish do |transitions|
    end 
  end
end
