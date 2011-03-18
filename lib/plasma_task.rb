# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'task'

module RubyRubyDo

  class CalendarDialog < Qt::Dialog
    attr_reader :selected_date
        
    def initialize(parent = nil, name = nil)
      super
      setWindowTitle("Set due date")
      resize(400, 120)
      layout = Qt::VBoxLayout.new
      setLayout(layout)
      cal = Qt::CalendarWidget.new self
      cal.grid_visible = true
      cal.vertical_header_format = Qt::CalendarWidget::NoVerticalHeader
      cal.setFirstDayOfWeek(Qt::Monday)
      cal.connect(SIGNAL('clicked(const QDate)')) do |d|
        puts "#{d.day}/#{d.month}/#{d.year}"
        @selected_date = d.toJulianDay
        puts "#{d} #{@selected_date} {#selected_date.day}/{#selected_date.month}/{#selected_date.year}"
      end
      layout.addWidget(cal)
      ok_button = Qt::PushButton.new('Ok', self)
      ok_button.default = true
      cancel_button = Qt::PushButton.new('Cancel', self)
      layout.addWidget(ok_button)
      layout.addWidget(cancel_button)      
      connect(ok_button, SIGNAL('clicked()'), self, SLOT('accept()'))
      connect(cancel_button, SIGNAL('clicked()'), self, SLOT('reject()'))
    end

  end

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
        puts "setModelData date: #{value}. #{value.is_valid}"
        value = nil if value.to_s == '-'
        unless value.is_valid
          dlg = CalendarDialog.new editor
          if (dlg.exec == Qt::Dialog::Accepted)
            puts "setModelData calendar (a): #{dlg.selected_date} {#dlg.selected_date.day}/{#dlg.selected_date.month}/{#dlg.selected_date.year}"
            value = Date.jd(dlg.selected_date)
            puts "setModelData calendar (b): #{value}, {#dlg.selected_date.day}/{#dlg.selected_date.month}/{#dlg.selected_date.year}"
          end
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
      when 4
        editor = Qt::CalendarWidget.new parent
        editor.grid_visible = true
        editor.vertical_header_format = Qt::CalendarWidget::NoVerticalHeader
        editor.setFirstDayOfWeek(Qt::Monday)
      else
        #super.createEditor parent, option, index
        return nil #0
      end
    end
  end

end

