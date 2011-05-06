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
  end

  must 'add moultiple task at once' do
    task1 = ToDo::Task.new 'compra il latte', 1, @today
    task2 = ToDo::Task.new 'Telefonare!', 2, @tomorrow
    task3 = ToDo::Task.new 'Garage', 3
    @todo_list << task1 << task2 << task3
    assert_equal(3, @todo_list.length)
  end

end
