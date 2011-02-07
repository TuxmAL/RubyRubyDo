module ToDo
  class Task
    attr_accessor :description, :priority, :due_date, :category

    def initialize(description = '<empty task>', priority = nil, due_date = nil,
        category = nil)
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
  end
end