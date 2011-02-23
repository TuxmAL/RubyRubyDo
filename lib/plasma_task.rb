# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'task'

module RubyRubyDo

  class PriorityEdit < Qt::ItemDelegate
  
    def createEditor parent, option, index
      puts parent.inspect
      puts option
      puts index
      puts index.column
      #try returning 0 if nil is not good!
      return 0 unless index.is_valid
      #return nil if (index.row >= @@todo_list.count)
      task = index.internal_pointer
      case index.column
      when 1
        editor = Qt::ComboBox.new parent
        editor.add_items((ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).map { |e| e.to_s })
        return editor
      else
        return nil #0 #super.createEditor parent, option, index
      end
    end
  end

end
