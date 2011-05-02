# -*- encoding: UTF-8 -*- :nodoc:
# 
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::   _to be choosen_

$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/
module ToDo
  class Task
    PRIORITYMAX = 1
    PRIORITYMIN = 5

    attr_accessor :description, :due_date, :category
    attr_reader :priority, :fulfilled_date

    def initialize(description = '<empty task>', priority = Task::PRIORITYMIN,
        due_date = nil,category = nil)
      raise RangeError, "Priority out of range (was #{priority.inspect}, expected #{PRIORITYMAX}-#{PRIORITYMIN})" unless !priority.nil? && priority.between?(PRIORITYMAX, PRIORITYMIN)
      @done=false
      @description = description
      @priority = priority
      @due_date = due_date
      @fulfilled_date = nil
      @category = category
      @saved = false
    end

    # TODO: see is correctly implemented the spaceship operator!
    def <=>(a_task)
      if due_date.nil?
        @priority <=> a_task.priority
      else
        (@due_date <=> a_task.due_date).nonzero? || @priority <=> a_task.priority
      end
    end

    def done
      @saved &= false
      @fulfilled_date = Date.today
      @done = true
    end

    def undone
      @saved &= false
      @fulfilled_date = nil
      @done = false
    end

    def done?
      return @done
    end

    def priority=(value)
      raise RangeError, "Priority out of range (was #{value.inspect}, expected #{PRIORITYMAX}-#{PRIORITYMIN})" unless !value.nil? && value.between?(PRIORITYMAX, PRIORITYMIN)
      @priority = value
      @saved &= false
    end

    def overdue?
      !@due_date.nil? && (@due_date < Date.today)
    end

    def saved
      @saved = true
    end

    def saved?
      @saved
    end

  end
  
end
