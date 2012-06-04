#coding: UTF-8
# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require File.join(File.join(File.dirname(__FILE__), 'helper'), 'test_unit_extensions')
require 'ruby_ruby_do'

class TaskTest < Test::Unit::TestCase
  def setup
    @today = Date.today
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

  must 'priority not be nil' do
    assert_raise RangeError do
      a_task = ToDo::Task.new('task with priority nil', nil)
    end
  end

  must 'priority not be changed to nil' do
    a_task = ToDo::Task.new('task',1)
    assert_raise RangeError do
      a_task.priority = nil
    end
  end

  must "change priority assignment" do
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
    a_task = ToDo::Task.new('test task', 3, @today).done
    assert_equal(true, a_task.done?)
  end

  must 'task  returns self on done or undone method' do
    a_task = ToDo::Task.new('test task', 3, @today)
    x = a_task.done
    y = a_task.undone
    assert_same x, a_task, 'Done task differs from original!'
    assert_same y, a_task, 'Undone task differs from original!'
  end

  must 'task be overdue' do
    a_task = ToDo::Task.new('test task', 3, @yesterday)
    assert_equal(true, a_task.overdue?) && !a_task.done
  end

  must 'task without due date never be overdue' do
    a_task = ToDo::Task.new('test task', 3)
    assert_equal(false, a_task.overdue?)
  end

  must 'task not done has fulfilled date set to nil' do
    a_task = ToDo::Task.new('test task', 3)
    assert_equal(nil, a_task.fulfilled_date)
  end

  must 'task done has fulfilled date set to the date of fulfilment' do
    a_task = ToDo::Task.new('test task', 3).done
    assert_equal(@today, a_task.fulfilled_date)
  end

  must 'task undone has fulfilled date reset to nil' do
    a_task = (ToDo::Task.new('test task', 3)).done.undone
    assert_equal(nil, a_task.fulfilled_date)
  end

  must 'task cannot alter fulfilled date directly' do
    a_task = ToDo::Task.new('test task', 3)
    a_task.done
    assert_raise NoMethodError do
      a_task.fulfillment_date = @today + 3
    end
  end

  must 'task have different id' do
    t1, t2 = ToDo::Task.new, ToDo::Task.new
    t3 = ToDo::Task.new
    t4 = ToDo::Task.new
    assert(t1.id != t2.id, "1/2) t1.id (#{t1.id.inspect}) same as t2.id (#{t2.id.inspect}).")
    assert(t3.id != t4.id, "2/2) t3.id (#{t3.id.inspect}) same as t4.id (#{t4.id.inspect}).")
  end

  must 'task due for today if queryed for' do
    a_task = ToDo::Task.new('test task', 3, @today)
    assert_equal(a_task.due_today?, true) && assert_equal(a_task.done, false)
  end

  must 'task due for tomorrow if queryed for' do
    a_task = ToDo::Task.new('test task', 3, @tomorrow)
    assert_equal(a_task.due_tomorrow?, true) && assert_equal(a_task.done, false)
  end

  must 'task due for this week if queryed for' do
    a_task = ToDo::Task.new('test task', 3, @today + 4)
    assert_equal(a_task.due_this_week?, true) && assert_equal(a_task.done, false)
    a_task = ToDo::Task.new('test task', 3, @today + 7)
    assert_equal(a_task.due_this_week?, false) && assert_equal(a_task.done, false)
  end

  must 'task be due without date if queryed for' do
    a_task = ToDo::Task.new('test task', 3)
    assert_equal(a_task.due_with_no_date?, true) && assert_equal(a_task.done, false)
  end
  
  must 'tasks be sorted correctly' do
    list = []
    list << (ToDo::Task.new('t12', 2).done)
    list << ToDo::Task.new('t11', 1, @yesterday).done
    list << ToDo::Task.new('t10', 3)
    list << ToDo::Task.new('t09', 1)
    list << ToDo::Task.new('t07', 3, @today + 4)
    list << ToDo::Task.new('t06', 2, @today + 4)
    list << ToDo::Task.new('t08', 1, @today + 5)
    list << ToDo::Task.new('t01', 2, @yesterday)
    list << ToDo::Task.new('t00', 1, @yesterday)
    list << ToDo::Task.new('t05', 5, @tomorrow)
    list << ToDo::Task.new('t04', 4, @tomorrow)
    list << ToDo::Task.new('t03', 3, @today)
    list << ToDo::Task.new('t02', 1, @today)

    oredered_list = list.sort.map {|t| t.description }
    assert_equal(%w[t00 t01 t02 t03 t04 t05 t06 t07 t08 t09 t10 t11 t12], oredered_list)    
  end
  
  must 'task_have_changes' do 
    a_task = ToDo::Task.new('test task', 3, @today + 4)    
    a_task.description=('new description')
    assert(a_task.changed?, 'Change in description not registered!')
    a_task.category = 'new category'
    assert(a_task.changed?, 'Change in category registered!')
    a_task.due_date = @today
    assert(a_task.changed?, 'Change in due date not registered!')
    a_task.priority = 1
    assert(a_task.changed?, 'Change in priority not registered!')
    a_task.done 
    assert(a_task.changed?, 'Task done not registered!')
    a_task.undone 
    assert(a_task.changed?, 'Task undone not registered!')
  end

  must 'task_have_total_changes' do 
    a_task = ToDo::Task.new('test task', 3, @today + 4)    
    a_task.description=('new description')
    a_task.category = 'new category'
    a_task.due_date = @today
    a_task.priority = 1
    a_task.done 
    changed = [:description, :due_date, :done, :priority, :category]
    assert_equal(a_task.changed.length, changed.length)
    changed.each {|a| assert(a_task.changed.include? a)}
  end
end
