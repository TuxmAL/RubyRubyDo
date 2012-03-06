# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/unit'
require File.join(File.join(File.dirname(__FILE__), 'helper'), 'test_unit_extensions')
require 'ruby_ruby_do'

class ToDoTest < Test::Unit::TestCase

  def setup
    @today = Date.today
    @yesterday = @today - 1
    @tomorrow = @today + 1
    @todo_list = ToDo::ToDo.new
    @task1 = ToDo::Task.new 'Compra il latte', 1, @today
    @task2 = ToDo::Task.new 'Telefonare!', 2, @tomorrow
    task3 = ToDo::Task.new 'Garage', 3
    task4 = ToDo::Task.new 'Andare a pesca', 2, @today - 9 
    task5 = ToDo::Task.new('Procurarsi chiave inglese', 2, @today).done
    task6 = ToDo::Task.new('Procurarsi bulloni', 2, @today + 7)
    task7 = ToDo::Task.new('Aggiustare il razzo', 2, @today + 15)
    task8 = ToDo::Task.new 'Scrivere RubyRubyDo', 1
    @todo_list << @task1 << @task2 << task3 << task4 << task5 << task6 << task7 << task8
  end

  must 'append multiple task at once' do   
    assert_equal(8, @todo_list.length)
  end

  must 'delete a task by task object' do
    before = @todo_list.length
    last_task = @todo_list.last
    @todo_list.delete(@task2)
    assert_equal(before - 1, @todo_list.length)
    assert_block("Expected #{@task2.inspect} to be deleted") do
      @todo_list.first == @task1 &&
      @todo_list.last == last_task
    end
  end

  must 'insert a task at specified index' do
     before = @todo_list.length
    task_x = ToDo::Task.new 'must be the second!', 5
    @todo_list.insert(1, task_x)
    assert_equal(before + 1, @todo_list.length)
    assert_block("Expected #{task_x.inspect} to be 2nd place in the list") do
      @todo_list[0] == @task1 &&
      @todo_list[1] == task_x
    end    
  end
  
  must 'return all tasks due for a given date (today) not yet done' do
    due_today = @todo_list.due_for(@today)
    assert_block("Expected (non empty) #{due_today.inspect} to be due for today") do
      due_today.length != 0 && due_today.each {|t| assert(t.due_date == @today && ! t.done?)}
    end
  end

  must 'return empty list if no task due for a given date (today) not yet done' do
    empty_todo = ToDo::ToDo.new 
    assert_empty empty_todo.due_for(@today)
  end

  must 'return all tasks due after a given date (next week) not yet done' do
    next_week = @today + 7
    due_next_week = @todo_list.due_after(next_week)
    assert_block("Expected (non empty) #{due_next_week.inspect} to be due for (next week)") do     
      due_next_week.length != 0 && due_next_week.each {|t| assert(t.due_date > next_week && ! t.done?)}
    end
  end

  must 'return empty list if no task due for a given date (next week) not yet done' do
    next_week = @today + 7
    empty_todo = ToDo::ToDo.new
    assert_empty empty_todo.due_for(@today)
  end

  must 'return all tasks with no due date not yet done' do
    without_due_date = @todo_list.with_no_date
    assert_block("Expected (non empty) #{without_due_date.inspect} to be due in no due date") do     
      without_due_date.length != 0 && without_due_date.each {|t| assert(t.due_date.nil? && ! t.done?)}
    end
  end

  must 'return empty list if no task exists without date not yet done' do
    empty_todo = ToDo::ToDo.new 
    assert_empty empty_todo.with_no_date
  end

  must 'return all tasks due between two dates not yet done' do
    between_dates = @todo_list.due_between(@tomorrow, @today + 6)
    assert_block("Expected (non empty) #{between_dates.inspect} to be between dates") do     
      between_dates.length != 0 && between_dates.each {|t| assert(((@tomorrow..(@today + 6)).include? t.due_date) && ! t.done?)}
    end
    assert_empty @todo_list.due_between(@today + 6, @tomorrow)
  end

  must 'return empty list if no task due between two dates not yet done' do
    empty_todo = ToDo::ToDo.new 
    assert_empty empty_todo.due_between(@today + 6, @tomorrow)
  end

  must 'return no task if 2nd date is grether than 1st' do
    assert_empty @todo_list.due_between(@today + 6, @tomorrow)
  end

  must 'return all overdue tasks not yet done' do
    overdue = @todo_list.overdue
    assert_block("Expected (non empty) #{overdue.inspect} to be overdue") do
      overdue.length != 0 && overdue.each {|t| assert t.overdue? && ! t.done?}
    end
  end
  
  must 'return empty list if no overdue task not yet done' do
    empty_todo = ToDo::ToDo.new 
    assert_empty empty_todo.overdue
  end

  must 'return all done tasks' do
    done = @todo_list.done
    assert_block("Expected (non empty) #{done.inspect} to be done") do
      done.length != 0 && done.each {|t| assert t.done? }
    end
  end
 
  must 'return empty list if no done task exists' do
    empty_todo = ToDo::ToDo.new 
    assert_empty empty_todo.done
  end

end
