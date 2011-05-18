if $0 == __FILE__
  require 'Qt4'
  require 'to_do'
end

class PlasmaEditTask < Qt::Dialog
  attr_reader :task
  slots :edit_ok
  slots :delete_task

  def initialize (parent = nil, task_idx = nil)
    super parent, nil
    @task_idx = task_idx
    setup_dialog self
    if @task_idx.nil?
      # TODO find how to add a new element to the treeview
      #@task_idx =
      title = Qt::Object.trUtf8('New Task')
      @delete_button.visible = false
    else
      task = task_idx.internal_pointer
      title = Qt::Object.trUtf8('Edit Task')
      @delete_button.visible = true
      @description.plain_text = task.description
      (@tool_buttons[task.priority - 1]).checked = true
      # TODO: this code, stolen from plasma_task, *must* be _refactored_!
      idx = @combo_box.findData Qt::Variant.new(task.due_date)
      puts " find_data=#{idx}; task.due_date=#{task.due_date}"
      @combo_box.current_index = (idx != -1)? idx: 10
      # TODO set the combo selected value for date not founn with findData (idx returned == -1)
      @combo_box.setEditText(task.due_date.strftime('%d/%m/%Y')) if idx == -1
      ############################################
      @done_check.checked = task.done?
      msg = []
      msg << Qt::Object.trUtf8('overdue') if task.overdue?
      msg << Qt::Object.trUtf8("fulfilled at #{task.fulfilled_date.strftime('%d/%m/%Y')}") if task.done?
      @task_info.text = "#{Qt::Object.trUtf8('Task is')} #{msg.join(Qt::Object.trUtf8(' and '))}." if msg.size > 0
    end
    self.window_title = title
  end

  def delete_task
    ret_val = Qt::MessageBox.question(self, Qt::Object.trUtf8('RubyRubyDo'),
         Qt::Object.trUtf8("Do you really want to delete this task?"), 
         Qt::MessageBox.Yes | Qt::MessageBox.No, Qt::MessageBox.No)
    if ret_val == Qt::MessageBox.Yes
      @task_idx.model.removeRow(@task_idx.row)
      emit accept
    end
  end

  def edit_ok
    unless @description.to_plain_text.strip.empty?
      # TODO Now cannot create a new element the old way: @task ||= ToDo::Task.new() because we now use a Qt:ModelIndex object.
      #@task_idx.internal_pointer ||= ToDo::Task.new()
      task = @task_idx.internal_pointer
      task.description = @description.to_plain_text.strip
      @tool_buttons.each_with_index { |itm, idx| task.priority = (idx+1) if itm.checked }
      value = @combo_box.item_data(@combo_box.current_index())
      task.due_date = Date.jd(value.toDate.toJulianDay)
      if @done_check.checked
        task.done
      else
        task.undone
      end
      emit accept()
    else
       Qt::MessageBox.warning(self, Qt::Object.trUtf8('RubyRubyDo'),
         Qt::Object.trUtf8('Task cannot have empty description.'),
         Qt::MessageBox.Ok)
    end
  end

  def setup_dialog(dialog)
    dialog.windowModality = Qt::WindowModal
    dialog.resize(259, 174)
    sizePolicy.heightForWidth = dialog.sizePolicy.hasHeightForWidth
    dialog.modal = true
    button_box = nil
    delete_button = nil
    tool_buttons = []
    combo_box = nil
    description = nil
    done_check = nil
    task_info = nil
    vertical_layout = Qt::VBoxLayout.new() do
      setContentsMargins(0, 0, 0, 0)
      horizontal_layout = Qt::HBoxLayout.new() do
        label = Qt::Label.new(Qt::Object.trUtf8('Priority:'))
        addWidget(label)
        addItem(Qt::SpacerItem.new(5, 20, Qt::SizePolicy::Fixed, Qt::SizePolicy::Minimum))
        ToDo::Task::PRIORITYMAX.upto ToDo::Task::PRIORITYMIN do |pri|
          tool_button = Qt::ToolButton.new() do
            self.checkable = true
            self.autoExclusive = true
            self.text = Qt::Object.trUtf8(pri.to_s)
          end
          addWidget(tool_button)
          tool_buttons << tool_button
        end
         tool_buttons.first.checked = true
        label.buddy = tool_buttons.first
        addItem(Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum))
      end
      addLayout(horizontal_layout)
      label = Qt::Label.new(Qt::Object.trUtf8('Description:'))
      addWidget(label)
      description = Qt::PlainTextEdit.new() do
        self.frameShadow = Qt::Frame::Sunken
        self.horizontalScrollBarPolicy = Qt::ScrollBarAlwaysOff
        self.tabChangesFocus = true
      end
      addWidget(description)
      label.buddy = description
      horizontal_layout = Qt::HBoxLayout.new() do
        label = Qt::Label.new(Qt::Object.trUtf8('Due for:'))
        addWidget(label)
        combo_box = Qt::ComboBox.new() do
          self.sizeAdjustPolicy = Qt::ComboBox::AdjustToContents
        end
        addWidget(combo_box)
        label.buddy = combo_box
        addItem(Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum))
      end
      addLayout(horizontal_layout)
      done_check = Qt::CheckBox.new(Qt::Object.trUtf8('Done'))
      addWidget(done_check)
      task_info = Qt::Label.new()
      addWidget(task_info)
      button_box = Qt::DialogButtonBox.new(Qt::DialogButtonBox::Cancel|Qt::DialogButtonBox::Ok, Qt::Horizontal) do
        self.centerButtons = false
        delete_button = Qt::PushButton.new(Qt::Object.trUtf8('Delete'))
        addButton(delete_button, Qt::DialogButtonBox::ActionRole)
      end
      addWidget(button_box)
      ToDo::Task::PRIORITYMAX.upto(ToDo::Task::PRIORITYMIN - 1) do |pri|
        Qt::Widget.setTabOrder(tool_buttons[pri - 1], tool_buttons[pri])
      end
      Qt::Widget.setTabOrder(tool_buttons[ToDo::Task::PRIORITYMIN], description)
      Qt::Widget.setTabOrder(description, combo_box)
      Qt::Widget.setTabOrder(combo_box, button_box)
      # TODO: this code, stolen from plasma_task, *must* be _refactored_!
      a_date = Date.today
      combo_box.add_item a_date.strftime('%a %d/%m/%y - Today'), Qt::Variant.new(a_date)
      a_date += 1
      combo_box.add_item a_date.strftime('%a %d/%m/%y - Tomorrow'), Qt::Variant.new(a_date)
      a_date += 1
      a_date.upto(a_date + 5) do |d|
        combo_box.add_item d.strftime('%a %d/%m/%y'), Qt::Variant.new(d)
      end
      a_date += 6
      combo_box.add_item((a_date).strftime('%a %d/%m/%y - Next week'), Qt::Variant.new(a_date))
      combo_box.add_item Qt::Object.trUtf8('No date'), Qt::Variant.new('-')
      combo_box.add_item Qt::Object.trUtf8('Choose date...'), Qt::Variant.new()
      # get the minimum width that fits the largest item.
      width = combo_box.minimum_size_hint.width
      # set the ComboBox to that width.
      combo_box.minimum_width = width
      ############################################
    end
    connect(button_box, SIGNAL('accepted()'), dialog, SLOT('edit_ok()'))
    connect(button_box, SIGNAL('rejected()'), dialog, SLOT('reject()'))
    connect(delete_button, SIGNAL('clicked()'), dialog, SLOT('delete_task()'))
    Qt::MetaObject.connectSlotsByName(dialog)
    setLayout vertical_layout

    @description = description
    @tool_buttons = tool_buttons
    @combo_box = combo_box
    @done_check = done_check
    @task_info = task_info
    @delete_button = delete_button
  end
#    def setup_ui(dialog)
#      retranslateUi(dialog)
#    end
#
#    def retranslateUi(dialog)
#    @comboBox.insertItems(0, [Qt::Application.translate("Dialog", "Today - 12/12/2012", nil, Qt::Application::UnicodeUTF8),
#        Qt::Application.translate("Dialog", "Tomorrow - 12/12/2010", nil, Qt::Application::UnicodeUTF8)])
#    end # retranslateUi
#
#    def retranslate_ui(dialog)
#        retranslateUi(dialog)
#    end

end

if $0 == __FILE__
  Qt::Application.new(ARGV) do
    task = ToDo::Task.new #nil
    PlasmaEditTask.new nil, nil, nil do
      show
    end
  exec
  end
end
