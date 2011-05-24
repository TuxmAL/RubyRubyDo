# -*- encoding: UTF-8 -*- :nodoc:
# 
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::   _to be choosen_

require 'yaml'

$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/
module ToDo
  class ToDo
    include Enumerable

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
        f.write(@tasks.to_yaml)
        @tasks.each {|t| t.saved}
      end
    end

    def load
      @tasks = YAML::load( File.open(@filename, 'r')) # YAML::load_stream( File.open(@filename) )
    end

  end
end
