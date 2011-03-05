# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'task'

module RubyRubyDo

  class PriorityDelegate < Qt::StyledItemDelegate

    def initialize(parent = nil)
      super parent
    end

    #def initialize parent
    #  super parent
    #  puts "initialize #{parent.inspect}"
    #end

    #def paint painter, option, index
    #  puts "paint: #{painter}, #{option}, #{index}"
    #   super.paint painter, option, index
    #end
    
    def setEditorData(editor, index)
      value = index.data.value
      puts "setEditorData: value=#{value}"
      case index.column
      when 1
        editor.current_index = editor.find_text value.to_s
        #editor.current_index = editor.findText value
      else
        editor.text = value
      end
    end

    def setModelData(editor, model,index)
      case index.column
      when 1
        value = editor.current_text
      else
        #editor.interpret_text
        value = editor.text
      end
      model.setData(index, value, Qt::EditRole);
      puts "setData: #{value}, #{model}, #{index}"
    end

    def createEditor parent, option, index
      puts "createEditor: #{parent}, #{option}, #{index.column}"
      #try returning 0 if nil is not good!
      #return nil unless index.is_valid
      #return nil if (index.row >= @@todo_list.count)
      case index.column
      when 1
        editor = Qt::ComboBox.new parent
        editor.add_items((ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).map { |e| e.to_s })
        return editor
      when 2
        return super
      when 3
        editor = Qt::DateEdit.new parent
        #editor.add_items((ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).map { |e| e.to_s })
      else
	#super.createEditor parent, option, index
        return nil #0
      end
    end
  end

end

