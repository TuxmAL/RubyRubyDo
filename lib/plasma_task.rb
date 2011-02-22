# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'

module RubyRubyDo
 
  class TaskEdit < Qt::AbstractItemDelegate
    def createEditor parent, option, index
      #try returning 0 if nil is not good!
      return nil unless index.is_valid
      return nil if (index.row >= @@todo_list.count)
      task = index.internal_pointer
      case index.column
      when 1
        editor = Qt::ComboBox.new parent
        editor.additems((Task::PRIORITYMAX..Task::PRIORITYMIN).to_a)
      when 3
      else
        return nil
      end
    end
  end

end
