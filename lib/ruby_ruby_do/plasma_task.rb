# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
#require 'plasma_applet'
#require 'task'

module RubyRubyDo

  class CalendarDialog < Qt::Dialog
    attr_reader :selected_date
    slots 'goto_today()'

    def initialize(parent = nil, name = nil)
      super
      @selected_date = Date.today      
      self.window_title = Qt::Object.trUtf8('Set due date')
      self.modal = true      
      cal = Qt::CalendarWidget.new self
      cal.grid_visible = true
      cal.vertical_header_format = Qt::CalendarWidget::NoVerticalHeader
      cal.setFirstDayOfWeek(Qt::Monday)
      cal.connect(SIGNAL('clicked(const QDate)')) do |d|
        puts "#{d.day}/#{d.month}/#{d.year}"
        @selected_date = d.toJulianDay
        puts "#{d} #{@selected_date} {#selected_date.day}/{#selected_date.month}/{#selected_date.year}"
        accept()
      end
      ok_button = Qt::PushButton.new(Qt::Object.trUtf8('Ok'), self)
      ok_button.default = true
      cancel_button = Qt::PushButton.new(Qt::Object.trUtf8('Cancel'), self)
      connect(ok_button, SIGNAL('clicked()'), self, SLOT('accept()'))
      connect(cancel_button, SIGNAL('clicked()'), self, SLOT('reject()'))
      today_button = Qt::PushButton.new(Qt::Object.trUtf8('Today'), self)
      today_button.connect(SIGNAL('clicked()')) do
        cal.selected_date = Qt::Date.fromJulianDay(Date.today.jd)
        @selected_date = cal.selected_date.toJulianDay
      end
      vertical_layout = Qt::VBoxLayout.new
      vertical_layout.addWidget(cal)
      horizontal_layout = Qt::HBoxLayout.new
      horizontal_layout.addWidget(ok_button)
      horizontal_layout.insertStretch(1)
      horizontal_layout.addWidget(today_button)
      horizontal_layout.insertStretch(3)
      horizontal_layout.addWidget(cancel_button)
      vertical_layout.addLayout horizontal_layout
      setLayout vertical_layout
    end

  end

  class PriorityDelegate < Qt::StyledItemDelegate

    def initialize(parent = nil)
      super parent
    end
    
    def setEditorData(editor, index)
      value = index.data.value
      puts "setEditorData: value=#{value}; value.to_s=#{value.to_s}, #{value.to_s == '-'}"
      case index.column
      when 1
        editor.current_index = editor.find_text value.to_s
        #editor.current_index = editor.findText value
      when 4
        case value.to_s
        when '-'
          editor.current_index = 9
        else
          # TODO: this code, has been stolen by plasma_edit_task and *must* be _refactored_!
          idx = editor.findData Qt::Variant.new(value)
          puts "setEditorData: finda_data=#{idx}; value.to_date=#{value.to_date}"
          editor.current_index = (idx != -1)? idx: 10
          #################################################################
        end
      else
        editor.text = value
      end
    end

    def setModelData(editor, model,index)
      case index.column
      when 1
        value = editor.current_text
      when 4
        value = editor.item_data(editor.current_index())
        puts "setModelData date: #{value}. #{value.is_valid}"
        value = Qt::Variant.new if value.to_s == '-'
        unless value.is_valid
          dlg = CalendarDialog.new editor
          if (dlg.exec == Qt::Dialog::Accepted)
            puts "setModelData calendar (a): #{dlg.selected_date} {#dlg.selected_date.day}/{#dlg.selected_date.month}/{#dlg.selected_date.year}"
            value = Qt::Variant.new(Qt::Date.fromJulianDay(dlg.selected_date))
            puts "setModelData calendar (b): #{value}, {#dlg.selected_date.day}/{#dlg.selected_date.month}/{#dlg.selected_date.year}"
          else
            value = Qt::Variant.new index.data.value
          end
          
        end
      else
        value = editor.text
      end
      model.setData(index, value, Qt::EditRole)
      puts "setData: #{value}, #{model}, #{index}"
    end

    def createEditor parent, option, index
      puts "createEditor: #{parent}, #{option}, #{index.column}"
      #try returning 0 if nil is not good!
      #return nil unless index.is_valid
      #return nil if (index.row >= @@todo.count)
      case index.column
      when 1
        editor = Qt::ComboBox.new parent
        editor.add_items((ToDo::Task::PRIORITYMAX..ToDo::Task::PRIORITYMIN).map { |e| e.to_s })
        editor.connect(SIGNAL('activated(int)')) do |idx|
          self.commitData editor
          self.closeEditor editor
        end
        return editor
      when 2
        return super
      when 4
        editor = Qt::ComboBox.new parent
        # TODO: this code, has been stolen by plasma_edit_task and *must* be _refactored_!
      	a_date = Date.today
        editor.add_item a_date.strftime('%a %d/%m/%y - Today'), Qt::Variant.new(a_date)
        a_date += 1
        editor.add_item a_date.strftime('%a %d/%m/%y - Tomorrow'), Qt::Variant.new(a_date)
        a_date += 1
        a_date.upto(a_date + 5) do |d|
          editor.add_item d.strftime('%a %d/%m/%y'), Qt::Variant.new(d)
        end
        editor.add_item((a_date + 6).strftime('%a %d/%m/%y - Next week'), Qt::Variant.new(a_date))
        editor.add_item Qt::Object.trUtf8('No date'), Qt::Variant.new('-')
        editor.add_item Qt::Object.trUtf8('Choose date...'), Qt::Variant.new()
        # get the minimum width that fits the largest item.
        width = editor.minimum_size_hint.width
        # set the ComboBox to that width.
        editor.minimum_width = width
        #################################################################
        editor.connect(SIGNAL('activated(int)')) do |idx|
          self.commitData editor
          self.closeEditor editor
        end
        return editor
      else
        #super.createEditor parent, option, index
        return nil #0
      end
    end
  end

end
