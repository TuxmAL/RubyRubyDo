module ToDo
  class Task
    Task::PRIORITYMAX=1
    Task::PRIORITYMIN=5

    attr_accessor :description, :due_date, :category
    attr_reader :priority

    def initialize(description = '<empty task>', priority = Task::PRIORITYMIN,
        due_date = nil,category = nil)
      @done=false
      @description = description
      @priority = priority
      @due_date = due_date
      @category = category
      @dirty = true
    end

    def <=>(a_task)
      if due_date.nil?
        @priority <=> a_task.priority
      else
        @due_date <=> a_task.due_date
      end
    end

    def done!
      @dirty = true
      return @done = true
    end

    def undone!
      @dirty = true
      return @done = false
    end

    def done?
      return @done
    end

    def priority=(value)
      if (PRIORITYMAX..PRIORITYMIN).include? value
        @priority = value
        @saved &= false
      end
    end

  end
  
end