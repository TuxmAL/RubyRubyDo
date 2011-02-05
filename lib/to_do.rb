module ToDo
  class ToDo
    include Enumerable

  def initialize
    @tasks = Array.new
  end

  def add(task)
    @tasks << task
  end
  
  def save
    @tasks.reduce('') do |buff, t|
      buff + JSON.dump(t)
    end
  end
end
