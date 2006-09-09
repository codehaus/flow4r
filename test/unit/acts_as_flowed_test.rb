require File.dirname(__FILE__) + '/../test_helper'

class ActsAsFlowedTest < Test::Unit::TestCase

  def test_class_workflow
    assert TestObject.workflow
    assert TestObject.workflow[:start]
    assert TestObject.workflow[:finish]
    assert ! TestObject.workflow[:swedish]
  end

  def test_instance_workflow
    object = TestObject.new
    assert object.workflow
  end

  def test_instance_start_state
    object = TestObject.new
    assert_nil object.status
    assert_nil object.status_label
    object.save
    assert_equal 'start', object.status
    assert_equal 'Start', object.status_label
  end

  def test_transition_via
    object = TestObject.new
    assert_nil object.status
    object.save
    assert_equal 'start', object.status
    object.transition_via( :go_to_middle_manual )
    assert_equal 'start-go_to_middle_manual', object.status
  end

  def test_transition_via_bad
    object = TestObject.new
    assert_nil object.status
    object.save
    assert_equal 'start', object.status
    begin
      object.transition_via( :go_to_heck )
      fail "should have thrown"
    rescue RuntimeError => e
      # expected and correct
    end
  end

  def test_complete_transition_not_running
    object = TestObject.new
    assert_nil object.status
    object.save
    begin
      object.complete_transition( :go_to_middle_manual, :success )
      fail "should have thrown"
    rescue RuntimeError => e
      # expected and correct
    end
  end

  def test_complete_transition_not_current
    object = TestObject.new
    assert_nil object.status
    object.save
    object.status = 'start+go_to_middle_manual'
    object.save
    assert_equal 'start+go_to_middle_manual', object.status
    begin
      object.complete_transition( :go_to_middle_auto, :success )
      fail "should have thrown"
    rescue RuntimeError => e
      # expected and correct
    end
  end

  def test_complete_transition
    object = TestObject.new
    assert_nil object.status
    object.save
    object.status = 'start+go_to_middle_manual'
    object.save
    assert_equal 'start+go_to_middle_manual', object.status
    object.complete_transition( :go_to_middle_manual, :success )
    assert_equal 'middle_manual', object.status
  end

end
