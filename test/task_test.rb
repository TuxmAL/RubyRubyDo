# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require File.join(File.join(File.dirname(__FILE__), 'helper'), 'test_unit_extensions')
require 'date'
require 'task'

class TaskTest < Test::Unit::TestCase
  def setup
    @today = Date.jd(DateTime.now.jd)
    @yesterday = @today - 1
    @tomorrow = @today + 1
  end

  must 'create a default task' do
    default = ToDo::Task.new
    assert_block("Expected #{default.inspect} not as the default task") do
      default.description == '<empty task>' &&
      default.priority == ToDo::Task::PRIORITYMIN &&
      !default.done? &&
      default.due_date.nil? &&
      !default.overdue?
    end
  end

  must "priority be between #{ToDo::Task::PRIORITYMAX} and #{ToDo::Task::PRIORITYMIN}" do
    ToDo::Task::PRIORITYMIN.downto(ToDo::Task::PRIORITYMAX) do |p|
      a_task = ToDo::Task.new("task with priority #{p}", p)
      assert_equal(p, a_task.priority)
    end
  end

  must "default priority be minimal (#{ToDo::Task::PRIORITYMIN})" do
    a_task = ToDo::Task.new("task with default priority")
    assert_equal(ToDo::Task::PRIORITYMIN, a_task.priority)
  end

  must "fail when priority is outside #{ToDo::Task::PRIORITYMAX} and #{ToDo::Task::PRIORITYMIN}" do
    [-1, 0, 6, 7, 10].each do |p|
      assert_raise RangeError do
        a_task = ToDo::Task.new("task with priority (#{p}) outside range", p)
      end
    end
  end

  must "fail when assigning a priority outside #{ToDo::Task::PRIORITYMAX} and #{ToDo::Task::PRIORITYMIN}" do
    a_task = ToDo::Task.new("task with priority 1", 1)
    [-1, 0, 6, 7, 10].each do |p|
      assert_raise RangeError do
        a_task.priority= p
      end
    end
  end

  must "change priority assignement" do
    a_task = ToDo::Task.new("task with priority 1", 1)
    (ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).each do |p|
      a_task.priority = p
      assert_equal p, a_task.priority
    end
  end

  must 'task be undone' do
    a_task = ToDo::Task.new('test task', 3, @today)
    assert_equal(false, a_task.done?)
  end

  must 'task be done' do
    a_task = ToDo::Task.new('test task', 3, @today)
    a_task.done!
    assert_equal(true, a_task.done?)
  end

  must 'task be overdue' do
    a_task = ToDo::Task.new('test task', 3, @yesterday)
    assert_equal(true, a_task.overdue?)
  end

end
