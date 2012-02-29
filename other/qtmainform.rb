=begin
** Form generated from reading ui file 'rubyrubydo.ui'
**
** Created: lun feb 28 19:11:38 2011
**      by: Qt User Interface Compiler version 4.6.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
=end

require 'korundum4'

class Ui_MainWindow
    attr_reader :centralwidget
    attr_reader :verticalLayoutWidget
    attr_reader :verticalLayout
    attr_reader :treeView
    attr_reader :menubar
    attr_reader :statusbar

    def setupUi(mainWindow)
    if mainWindow.objectName.nil?
        mainWindow.objectName = "mainWindow"
    end
    mainWindow.resize(306, 300)
    mainWindow.windowTitle = "RubyRubyDo"
    mainWindow.documentMode = false
    mainWindow.dockOptions = Qt::MainWindow::AllowTabbedDocks
    @centralwidget = Qt::Widget.new(mainWindow)
    @centralwidget.objectName = "centralwidget"
    @verticalLayoutWidget = Qt::Widget.new(@centralwidget)
    @verticalLayoutWidget.objectName = "verticalLayoutWidget"
    @verticalLayoutWidget.geometry = Qt::Rect.new(0, 0, 301, 251)
    @verticalLayout = Qt::VBoxLayout.new(@verticalLayoutWidget)
    @verticalLayout.objectName = "verticalLayout"
    @verticalLayout.sizeConstraint = Qt::Layout::SetDefaultConstraint
    @verticalLayout.setContentsMargins(0, 0, 0, 0)
    @treeView = Qt::TreeView.new(@verticalLayoutWidget)
    @treeView.objectName = "treeView"

    @verticalLayout.addWidget(@treeView)

    mainWindow.centralWidget = @centralwidget
    @menubar = Qt::MenuBar.new(mainWindow)
    @menubar.objectName = "menubar"
    @menubar.geometry = Qt::Rect.new(0, 0, 306, 23)
    mainWindow.setMenuBar(@menubar)
    @statusbar = Qt::StatusBar.new(mainWindow)
    @statusbar.objectName = "statusbar"
    mainWindow.statusBar = @statusbar

    retranslateUi(mainWindow)

    Qt::MetaObject.connectSlotsByName(mainWindow)
    end # setupUi

    def setup_ui(mainWindow)
        setupUi(mainWindow)
    end

    def retranslateUi(mainWindow)
    end # retranslateUi

    def retranslate_ui(mainWindow)
        retranslateUi(mainWindow)
    end

end

module Ui
    class MainWindow < Ui_MainWindow
    end
end  # module Ui

if $0 == __FILE__
    about = KDE::AboutData.new("mainwindow", "MainWindow", KDE.ki18n(""), "0.1")
    KDE::CmdLineArgs.init(ARGV, about)
    a = KDE::Application.new
    u = Ui_MainWindow.new
    w = Qt::MainWindow.new
    u.setupUi(w)
    a.topWidget = w
    w.show
    a.exec
end
