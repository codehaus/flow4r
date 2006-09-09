
require 'test/unit'
require 'flow4r'
require 'pp'

class Flow4rTest < Test::Unit::TestCase

  def test_create_empty
    workflow = Flow4r::Workflow.create do
    end
    assert workflow
  end

  def test_create_one_state
    workflow = Flow4r::Workflow.create do |states|
      states.start do
      end
    end
    assert workflow
    assert workflow[:start]
  end

  def test_create_multiple_states
    workflow = Flow4r::Workflow.create do |states|
      states.start 
      states.middle 
      states.end 
    end
    assert workflow
    assert workflow[:start]
    assert workflow[:middle]
    assert workflow[:end]
  end

  def test_create_one_transition
    workflow = Flow4r::Workflow.create do |states|
      states.start do |transitions|
        transitions.finish( :on_success=>:finish ) do |flowed|
          puts "finishing"
        end
      end
    end
    assert workflow
    assert workflow[:start]
    assert workflow[:start][:finish]
    assert ! workflow[:bart]
    assert ! workflow[:start][:swedish]
  end

end
