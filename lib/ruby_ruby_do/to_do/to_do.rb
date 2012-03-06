# -*- encoding: UTF-8 -*- :nodoc:
#
# ToDo::ToDo a simple class for managing a set of todo tasks.
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'yaml'

$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/
module ToDo
  class ToDo
    include Enumerable

    # where we will store our tasks
    TODOFILE = File.expand_path('~/.RubyRuby.Do')

    def initialize
      @tasks = Array.new
      @filename = TODOFILE
    end

    # Append the given _task_ to the end of the ToDo list. This expression returns the ToDo list itself, so several appends may be chained together.
    def <<(task)
      @tasks << task
      self
    end

    # Insert the given _task_  before the element with the given _index_ (which may be negative).
    def insert(index, task)
      @tasks.insert(index, task)
      self
    end

    # Remove a new task by task object
    def delete(task)
      @tasks.delete task
      self
    end

    # Remove a new task by index
    def delete_at(index)
      @tasks.delete_at index
      self
    end

    def each
      @tasks.each { |t| yield t }
    end

    # Returns all tasks due for a given _date_ not done yet.
    def due_for(date)
      (@tasks.select { |t| t.due_date == date && ! t.done? }).sort
    end
    
    # Returns all overdue tasks not done yet.
    def overdue
      (@tasks.select { |t| t.overdue? && ! t.done? }).sort
    end
    
    # Returns all done tasks.
    def done
      (@tasks.select { |t| t.done? }).sort
    end
    
    # Returns all tasks due after a given _date_ not done yet.
    def due_after(date)
      (@tasks.select { |t| ! t.due_date.nil? && ! t.done? && (t.due_date > date) }).sort
    end

    # Returns all tasks due between two given _dates_ not done yet.
    # The first date must be less or equal to the second one, else nil is returned.
    def due_between(a_date, another_date)
      #min_date, max_date = [a_date, another_date].minmax
      (@tasks.select { |t| ! t.due_date.nil? && ((a_date..another_date).include? t.due_date) && ! t.done? }).sort
    end
    
    # Returns all tasks without a due date not done yet.
    def with_no_date()
      (@tasks.select { |t| t.due_date.nil? && ! t.done? }).sort
    end

    def [](index)
      @tasks[index]
    end

    # Return the last task
    def last()
      @tasks.last
    end

    def length
      @tasks.length
    end

    def save
      File.open(@filename, 'w') do |f|
        @tasks.each {|t| t.saved}
        f.write(@tasks.to_yaml)
      end
    end

    def load      
      @tasks = YAML::load( File.open(@filename, 'r')) if File.exist?(@filename)
      return self
    end

  end
end
