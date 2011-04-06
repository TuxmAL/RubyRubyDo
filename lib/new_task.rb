=begin
** Form generated from reading ui file 'new_task.ui'
**
** Created: mer apr 6 02:32:44 2011
**      by: Qt User Interface Compiler version 4.6.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

require 'korundum4'

class Ui_Dialog
    attr_reader :layoutWidget
    attr_reader :verticalLayout
    attr_reader :horizontalLayout
    attr_reader :label
    attr_reader :horizontalSpacer_2
    attr_reader :toolButton
    attr_reader :toolButton_2
    attr_reader :toolButton_3
    attr_reader :toolButton_4
    attr_reader :toolButton_5
    attr_reader :horizontalSpacer
    attr_reader :label_2
    attr_reader :description
    attr_reader :horizontalLayout_2
    attr_reader :label_3
    attr_reader :comboBox
    attr_reader :buttonBox
    attr_reader :deleteButton

    def setupUi(dialog)
    if dialog.objectName.nil?
        dialog.objectName = "dialog"
    end
    dialog.windowModality = Qt::WindowModal
    dialog.resize(259, 174)
    @sizePolicy = Qt::SizePolicy.new(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)
    @sizePolicy.setHorizontalStretch(0)
    @sizePolicy.setVerticalStretch(0)
    @sizePolicy.heightForWidth = dialog.sizePolicy.hasHeightForWidth
    dialog.sizePolicy = @sizePolicy
    dialog.modal = true
    @layoutWidget = Qt::Widget.new(dialog)
    @layoutWidget.objectName = "layoutWidget"
    @layoutWidget.geometry = Qt::Rect.new(0, 10, 258, 191)
    @verticalLayout = Qt::VBoxLayout.new(@layoutWidget)
    @verticalLayout.objectName = "verticalLayout"
    @verticalLayout.setContentsMargins(0, 0, 0, 0)
    @horizontalLayout = Qt::HBoxLayout.new()
    @horizontalLayout.spacing = 0
    @horizontalLayout.objectName = "horizontalLayout"
    @label = Qt::Label.new(@layoutWidget)
    @label.objectName = "label"
    @sizePolicy1 = Qt::SizePolicy.new(Qt::SizePolicy::Minimum, Qt::SizePolicy::Preferred)
    @sizePolicy1.setHorizontalStretch(0)
    @sizePolicy1.setVerticalStretch(0)
    @sizePolicy1.heightForWidth = @label.sizePolicy.hasHeightForWidth
    @label.sizePolicy = @sizePolicy1

    @horizontalLayout.addWidget(@label)

    @horizontalSpacer_2 = Qt::SpacerItem.new(5, 20, Qt::SizePolicy::Fixed, Qt::SizePolicy::Minimum)

    @horizontalLayout.addItem(@horizontalSpacer_2)

    @toolButton = Qt::ToolButton.new(@layoutWidget)
    @toolButton.objectName = "toolButton"
    @toolButton.checkable = true
    @toolButton.checked = true
    @toolButton.autoExclusive = true

    @horizontalLayout.addWidget(@toolButton)

    @toolButton_2 = Qt::ToolButton.new(@layoutWidget)
    @toolButton_2.objectName = "toolButton_2"
    @toolButton_2.checkable = true
    @toolButton_2.autoExclusive = true

    @horizontalLayout.addWidget(@toolButton_2)

    @toolButton_3 = Qt::ToolButton.new(@layoutWidget)
    @toolButton_3.objectName = "toolButton_3"
    @toolButton_3.checkable = true
    @toolButton_3.autoExclusive = true

    @horizontalLayout.addWidget(@toolButton_3)

    @toolButton_4 = Qt::ToolButton.new(@layoutWidget)
    @toolButton_4.objectName = "toolButton_4"
    @toolButton_4.checkable = true
    @toolButton_4.autoExclusive = true

    @horizontalLayout.addWidget(@toolButton_4)

    @toolButton_5 = Qt::ToolButton.new(@layoutWidget)
    @toolButton_5.objectName = "toolButton_5"
    @toolButton_5.checkable = true
    @toolButton_5.autoExclusive = true

    @horizontalLayout.addWidget(@toolButton_5)

    @horizontalSpacer = Qt::SpacerItem.new(40, 20, Qt::SizePolicy::Expanding, Qt::SizePolicy::Minimum)

    @horizontalLayout.addItem(@horizontalSpacer)


    @verticalLayout.addLayout(@horizontalLayout)

    @label_2 = Qt::Label.new(@layoutWidget)
    @label_2.objectName = "label_2"

    @verticalLayout.addWidget(@label_2)

    @description = Qt::PlainTextEdit.new(@layoutWidget)
    @description.objectName = "description"
    @sizePolicy2 = Qt::SizePolicy.new(Qt::SizePolicy::Minimum, Qt::SizePolicy::Minimum)
    @sizePolicy2.setHorizontalStretch(0)
    @sizePolicy2.setVerticalStretch(0)
    @sizePolicy2.heightForWidth = @description.sizePolicy.hasHeightForWidth
    @description.sizePolicy = @sizePolicy2
    @description.maximumSize = Qt::Size.new(256, 256)
    @description.frameShadow = Qt::Frame::Sunken
    @description.horizontalScrollBarPolicy = Qt::ScrollBarAlwaysOff
    @description.tabChangesFocus = true

    @verticalLayout.addWidget(@description)

    @horizontalLayout_2 = Qt::HBoxLayout.new()
    @horizontalLayout_2.objectName = "horizontalLayout_2"
    @label_3 = Qt::Label.new(@layoutWidget)
    @label_3.objectName = "label_3"

    @horizontalLayout_2.addWidget(@label_3)

    @comboBox = Qt::ComboBox.new(@layoutWidget)
    @comboBox.objectName = "comboBox"
    @sizePolicy.heightForWidth = @comboBox.sizePolicy.hasHeightForWidth
    @comboBox.sizePolicy = @sizePolicy
    @comboBox.sizeAdjustPolicy = Qt::ComboBox::AdjustToContents

    @horizontalLayout_2.addWidget(@comboBox)


    @verticalLayout.addLayout(@horizontalLayout_2)

    @buttonBox = Qt::DialogButtonBox.new(@layoutWidget)
    @buttonBox.objectName = "buttonBox"
    @buttonBox.orientation = Qt::Horizontal
    @buttonBox.standardButtons = Qt::DialogButtonBox::Cancel|Qt::DialogButtonBox::Ok
    @buttonBox.centerButtons = false

    @deleteButton = Qt::PushButton.new()
    @deleteButton.objectName = "deleteButton"
    @buttonBox.addButton(@deleteButton, Qt::DialogButtonBox::ActionRole)
    @verticalLayout.addWidget(@buttonBox)

    @label.buddy = @toolButton
    @label_2.buddy = @Description
    @label_3.buddy = @comboBox
    Qt::Widget.setTabOrder(@toolButton, @toolButton_2)
    Qt::Widget.setTabOrder(@toolButton_2, @toolButton_3)
    Qt::Widget.setTabOrder(@toolButton_3, @toolButton_4)
    Qt::Widget.setTabOrder(@toolButton_4, @toolButton_5)
    Qt::Widget.setTabOrder(@toolButton_5, @Description)
    Qt::Widget.setTabOrder(@Description, @comboBox)
    Qt::Widget.setTabOrder(@comboBox, @buttonBox)

    retranslateUi(dialog)
    Qt::Object.connect(@buttonBox, SIGNAL('accepted()'), dialog, SLOT('accept()'))
    Qt::Object.connect(@buttonBox, SIGNAL('rejected()'), dialog, SLOT('reject()'))
    Qt::Object.connect(@deleteButton, SIGNAL('clicked()'), dialog, SLOT('accept()'))

    Qt::MetaObject.connectSlotsByName(dialog)
    end # setupUi

    def setup_ui(dialog)
        setupUi(dialog)
    end

    def retranslateUi(dialog)
    dialog.windowTitle = Qt::Application.translate("Dialog", "New Task", nil, Qt::Application::UnicodeUTF8)
    @label.text = Qt::Application.translate("Dialog", "Priority:", nil, Qt::Application::UnicodeUTF8)
    @toolButton.text = Qt::Application.translate("Dialog", "1", nil, Qt::Application::UnicodeUTF8)
    @toolButton_2.text = Qt::Application.translate("Dialog", "2", nil, Qt::Application::UnicodeUTF8)
    @toolButton_3.text = Qt::Application.translate("Dialog", "3", nil, Qt::Application::UnicodeUTF8)
    @toolButton_4.text = Qt::Application.translate("Dialog", "4", nil, Qt::Application::UnicodeUTF8)
    @toolButton_5.text = Qt::Application.translate("Dialog", "5", nil, Qt::Application::UnicodeUTF8)
    @label_2.text = Qt::Application.translate("Dialog", "Description:", nil, Qt::Application::UnicodeUTF8)
    @label_3.text = Qt::Application.translate("Dialog", "Due for;", nil, Qt::Application::UnicodeUTF8)
    @comboBox.insertItems(0, [Qt::Application.translate("Dialog", "Today - 12/12/2012", nil, Qt::Application::UnicodeUTF8),
        Qt::Application.translate("Dialog", "Tomorrow - 12/12/2010", nil, Qt::Application::UnicodeUTF8)])
    @deleteButton.text = Qt::Application.translate("Dialog", "Delete", nil, Qt::Application::UnicodeUTF8)
    end # retranslateUi

    def retranslate_ui(dialog)
        retranslateUi(dialog)
    end

end

module Ui
    class Dialog < Ui_Dialog
    end
end  # module Ui

if $0 == __FILE__
    about = KDE::AboutData.new("dialog", "Dialog", KDE.ki18n(""), "0.1")
    KDE::CmdLineArgs.init(ARGV, about)
    a = KDE::Application.new
    u = Ui_Dialog.new
    w = Qt::Dialog.new
    u.setupUi(w)
    a.topWidget = w
    w.show
    a.exec
end
