if $0 == __FILE__
  require 'Qt4'
  require 'to_do'
end

class PlasmaEditTask < Qt::Dialog
    attr_reader :task

    def initialize (parent = nil, name = nil, task = nil)
      super parent, name
      if task.nil?
        title = Qt::Object.trUtf8('New Task')
      else
        title = Qt::Object.trUtf8('Edit Task')
      end
      self.window_title = title
      self.windowModality = Qt::WindowModal
      self.resize(259, 174)
      sizePolicy.heightForWidth = self.sizePolicy.hasHeightForWidth
      self.modal = true
      button_box = nil
      delete_button = nil
      first_tool_button = nil
      combo_box = nil
      vertical_layout = Qt::VBoxLayout.new() do
        setContentsMargins(0, 0, 0, 0)
        horizontal_layout = Qt::HBoxLayout.new() do
          label = Qt::Label.new(Qt::Object.trUtf8('Priority:'))
          addWidget(label)
          addItem(Qt::SpacerItem.new(5, 20, Qt::SizePolicy::Fixed, Qt::SizePolicy::Minimum))
          ToDo::Task::PRIORITYMAX.upto ToDo::Task::PRIORITYMIN do |pri|
            tool_button =  Qt::ToolButton.new() do
              self.checkable = true
              self.autoExclusive = true
              self.text = Qt::Object.trUtf8(pri.to_s)
            end
            first_tool_button ||= tool_button
            addWidget(tool_button)
          end
          first_tool_button.checked = true
          label.buddy = first_tool_button
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
        button_box = Qt::DialogButtonBox.new(Qt::DialogButtonBox::Cancel|Qt::DialogButtonBox::Ok, Qt::Horizontal) do
          self.centerButtons = false
          delete_button = Qt::PushButton.new(Qt::Object.trUtf8('Delete'))
          addButton(delete_button, Qt::DialogButtonBox::ActionRole)
          delete_button.visible = !task.nil?
        end
        addWidget(button_box)
        Qt::Widget.setTabOrder(first_tool_button, description)
        Qt::Widget.setTabOrder(description, combo_box)
        Qt::Widget.setTabOrder(combo_box, button_box)
      end
      connect(button_box, SIGNAL('accepted()'), self, SLOT('accept()'))
      connect(button_box, SIGNAL('rejected()'), self, SLOT('reject()'))
      connect(delete_button, SIGNAL('clicked()'), self, SLOT('accept()'))
      Qt::MetaObject.connectSlotsByName(self)
      setLayout vertical_layout
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
