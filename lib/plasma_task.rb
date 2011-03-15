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
      puts "setEditorData: value=#{value}; value.to_s=#{value.to_s}, #{value.to_s == '-'}"
      case index.column
      when 1
        editor.current_index = editor.find_text value.to_s
        #editor.current_index = editor.findText value
      when 3
	case value.to_s
	when '-'
	  editor.current_index = 9
	else 
	  idx = editor.findData Qt::Variant.new(value)
	  puts "setEditorData: finda_data=#{idx}; value.to_date=#{value.to_date}"
	  editor.current_index = (idx != -1)? idx: 10        
	end
      else
        editor.text = value
      end
    end

    def setModelData(editor, model,index)
      case index.column
      when 1
        value = editor.current_text
      when 3
	value = editor.item_data(editor.current_index())
	puts "setData date: #{value}. #{value.is_valid}"
	value = nil if value.to_s == '-'
	unless value.is_valid
	  #createIndex(index.row, 4, Qvariant.new)	  
	end
      else
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
        editor = Qt::ComboBox.new parent
	a_date = Date.jd(DateTime.now.jd)
        editor.add_item a_date.strftime('%a %d/%m/%y - Today'), Qt::Variant.new(a_date)
	a_date += 1
	editor.add_item a_date.strftime('%a %d/%m/%y - Tomorrow'), Qt::Variant.new(a_date)
	a_date += 1
	a_date.upto(a_date + 5) do |d|
	  editor.add_item d.strftime('%a %d/%m/%y'), Qt::Variant.new(d)
	end  
        editor.add_item((a_date + 6).strftime('%a %d/%m/%y - Next week'), Qt::Variant.new(a_date))
	editor.add_item 'No date', Qt::Variant.new('-')
	editor.add_item 'Choose date...', Qt::Variant.new()
	# get the minimum width that fits the largest item.
	width = editor.minimum_size_hint.width
	# set the ComboBox to that width.
	editor.minimum_width = width
	return editor
        #editor = Qt::DateEdit.new 
        #editor.calendar_popup = true
        #editor.calendar_widget = Qt::CalendarWidget.new parent
        #editor.add_items((ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).map { |e| e.to_s })
      else
	#super.createEditor parent, option, index
        return nil #0
      end
    end
  end

end

