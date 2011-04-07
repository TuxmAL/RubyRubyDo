=begin
** Form generated from reading ui file 'new_task.ui'
**
** Created: mer apr 6 02:32:44 2011
**      by: Qt User Interface Compiler version 4.6.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

require 'Qt4'
require 'task'

class PlasmaEditTask < Qt::Dialog
    attr_reader :task

#    attr_reader :layoutWidget
#    attr_reader :verticalLayout
#    attr_reader :horizontalLayout
#    attr_reader :label
#    attr_reader :horizontalSpacer_2
#    attr_reader :toolButton
#    attr_reader :toolButton_2
#    attr_reader :toolButton_3
#    attr_reader :toolButton_4
#    attr_reader :toolButton_5
#    attr_reader :horizontalSpacer
#    attr_reader :label_2
#    attr_reader :description
#    attr_reader :horizontalLayout_2
#    attr_reader :label_3
#    attr_reader :comboBox
#    attr_reader :buttonBox
#    attr_reader :deleteButton

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
      sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
      sizePolicy.setHorizontalStretch(0)
      sizePolicy.setVerticalStretch(0)
      sizePolicy.heightForWidth = self.sizePolicy.hasHeightForWidth
      self.sizePolicy = sizePolicy
      self.modal = true
      button_box = nil
      delete_button = nil
      vertical_layout = Qt::VBoxLayout.new() do
        setContentsMargins(0, 0, 0, 0)
        horizontal_layout = Qt::HBoxLayout.new() do
          spacing = 0
          label = Qt::Label.new(Qt::Object.trUtf8('Priority:')) do
            sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Minimum, Qt::SizePolicy::Preferred)
            sizePolicy.setHorizontalStretch(0)
            sizePolicy.setVerticalStretch(0)
            sizePolicy.heightForWidth = sizePolicy.hasHeightForWidth
            sizePolicy = sizePolicy
          end
          addWidget(label)
          addItem(Qt::SpacerItem.new(5, 20, Qt::SizePolicy::Fixed, Qt::SizePolicy::Minimum))
          tool_button = []
          ToDo::Task::PRIORITYMAX.upto ToDo::Task::PRIORITYMIN do |pri|
            tool_button.push Qt::ToolButton.new() do
              checkable = true
              autoExclusive = true
            end
            tool_button.last.text = Qt::Object.trUtf8(pri.to_s)

            addWidget(tool_button.last)
          end
          # FIX: label buddy is the last tool button instead of the first!
          label.buddy = tool_button.first
          addItem(Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum))
        end
        addLayout(horizontal_layout)
        label = Qt::Label.new(Qt::Object.trUtf8('Description:'))
        addWidget(label)
        description = Qt::PlainTextEdit.new() do
          sizePolicy2 = Qt::SizePolicy.new(Qt::SizePolicy::Minimum, Qt::SizePolicy::Minimum)
          sizePolicy2.setHorizontalStretch(0)
          sizePolicy2.setVerticalStretch(0)
          sizePolicy2.heightForWidth = sizePolicy.hasHeightForWidth
          sizePolicy = sizePolicy2
          maximumSize = Qt::Size.new(256, 256)
          frameShadow = Qt::Frame::Sunken
          horizontalScrollBarPolicy = Qt::ScrollBarAlwaysOff
          tabChangesFocus = true
        end
        addWidget(description)
        label.buddy = description
        horizontal_layout = Qt::HBoxLayout.new() do
          label = Qt::Label.new(Qt::Object.trUtf8('Due for:'))
          addWidget(label)
          combo_box = Qt::ComboBox.new() do
            size_policy.heightForWidth = sizePolicy.hasHeightForWidth
            sizePolicy = size_policy
            sizeAdjustPolicy = Qt::ComboBox::AdjustToContents
          end
          addWidget(combo_box)
          label.buddy = combo_box
          addItem(Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum))
        end
        addLayout(horizontal_layout)
        button_box = Qt::DialogButtonBox.new(Qt::DialogButtonBox::Cancel|Qt::DialogButtonBox::Ok, Qt::Horizontal) do
          centerButtons = false
          delete_button = Qt::PushButton.new(Qt::Object.trUtf8('Delete'))
          addButton(delete_button, Qt::DialogButtonBox::ActionRole)
          delete_button.visible = !task.nil?
        end
        addWidget(button_box)
      end
      connect(button_box, SIGNAL('accepted()'), self, SLOT('accept()'))
      connect(button_box, SIGNAL('rejected()'), self, SLOT('reject()'))
      connect(delete_button, SIGNAL('clicked()'), self, SLOT('accept()'))
      Qt::MetaObject.connectSlotsByName(self)
      setLayout vertical_layout
#    Qt::Widget.setTabOrder(@toolButton, @toolButton_2)
#    Qt::Widget.setTabOrder(@toolButton_2, @toolButton_3)
#    Qt::Widget.setTabOrder(@toolButton_3, @toolButton_4)
#    Qt::Widget.setTabOrder(@toolButton_4, @toolButton_5)
#    Qt::Widget.setTabOrder(@toolButton_5, @Description)
#    Qt::Widget.setTabOrder(@Description, @comboBox)
#    Qt::Widget.setTabOrder(@comboBox, @buttonBox)
    end

#    def setupUi(dialog)
#    @layoutWidget = Qt::Widget.new(dialog)
#    @layoutWidget.objectName = "layoutWidget"
#    @layoutWidget.geometry = Qt::Rect.new(0, 10, 258, 191)
#
#    retranslateUi(dialog)
#
#    end # setupUi
#
#    def setup_ui(dialog)
#        setupUi(dialog)
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

#module Ui
#    class Dialog < Ui_Dialog
#    end
#end  # module Ui

if $0 == __FILE__
#    about = KDE::AboutData.new("dialog", "Dialog", KDE.ki18n(""), "0.1")
#    KDE::CmdLineArgs.init(ARGV, about)
#    a = KDE::Application.new
#    u = Ui_Dialog.new
#    w = Qt::Dialog.new
#    u.setupUi(w)
#    a.topWidget = w
#    w.show
#    a.exec
    Qt::Application.new(ARGV) do
      task = ToDo::Task.new #nil
      PlasmaEditTask.new nil, nil, task do
        show
      end
    exec
    end
end
