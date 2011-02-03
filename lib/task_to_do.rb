# To change this template, choose Tools | Templates
# and open the template in the editor.

class TaskToDo
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
