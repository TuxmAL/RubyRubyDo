module ToDo
  class Task
    PRIORITYMAX = 1
    PRIORITYMIN = 5

    attr_accessor :description, :due_date, :category
    attr_reader :priority

    def initialize(description = '<empty task>', priority = Task::PRIORITYMIN,
        due_date = nil,category = nil)
      raise RangeError, "Priority out of range (was #{priority.inspect}, expected #{PRIORITYMAX}-#{PRIORITYMIN})" unless !priority.nil? && priority.between?(PRIORITYMAX, PRIORITYMIN)
      @done=false
      @description = description
      @priority = priority
      @due_date = due_date
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
      @done = true
    end

    def undone
      @saved &= false
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
