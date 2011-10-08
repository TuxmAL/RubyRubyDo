# -*- encoding: UTF-8 -*- :nodoc:
# 
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::   _to be choosen_
require 'date'

$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/
module ToDo
  class Task
    PRIORITYMAX = 1
    PRIORITYMIN = 5

    attr_accessor :description, :due_date, :category
    attr_reader :id, :priority, :fulfilled_date

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
      @id = Time.now.tv_usec
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
      self
    end

    def undone
      @saved &= false
      @fulfilled_date = nil
      @done = false
      self
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
      !@done && !@due_date.nil? && (@due_date < Date.today)
    end

    def due_today?
      !@done && !@due_date.nil? && (@due_date == Date.today)
    end

    def due_tomorrow?
      !@done && !@due_date.nil? && (@due_date == Date.today+ 1)
    end

    def due_this_week?
      !@done && !@due_date.nil? && ((Date.today..(Date.today + 6)).include? @due_date)
    end

    def due_with_no_date?
      !@done && @due_date.nil?
    end

    def saved
      @saved = true      
    end

    def saved?
      @saved
    end

  end
  
end
