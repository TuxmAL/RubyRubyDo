# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'yaml'
#require 'enumerator'

#We need ToDo tasks
require 'to_do'
require 'task'

module RubyRubyDo
  class Main < PlasmaScripting::Applet

    slots :addText

    def init
      set_minimum_size 250, 400
      self.has_configuration_interface = false
      #self.setAspectRatioMode= Plasma::IgnoreAspectRatio
      # py: self.layout = QGraphicsLinearLayout(Qt.Vertical, self.applet)
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout

      @theme = Plasma::Svg.new self
      puts @theme.inspect
      @theme.setImagePath("widgets/background")
      puts @theme.inspect
      self.BackgroundHints = Plasma::Applet.DefaultBackground

      @label = Plasma::Label.new self
      @label.text = 'TreeView Example:'
      @layout.addItem @label

      @stringlist = [] #Qt::StringList.new
      (1..10).each { |i| @stringlist << "Item #{i}, 1" }
#################
#     lv1->addColumn( "Items" );
#     lv1->setRootIsDecorated( TRUE );
#     // create a list with 4 ListViewItems which will be parent items of other ListViewItems
#     QValueList<QListViewItem *> parentList;
#     parentList.append( new QCheckListItem( lv1, "Parent Item 1", QCheckListItem::CheckBoxController ) );
#     parentList.append( new QCheckListItem( lv1, "Parent Item 2", QCheckListItem::CheckBoxController ) );
#     parentList.append( new QCheckListItem( lv1, "Parent Item 3", QCheckListItem::CheckBoxController ) );
#     parentList.append( new QCheckListItem( lv1, "Parent Item 4", QCheckListItem::CheckBoxController ) );
#################

      @model = Qt::StringListModel.new self
      @model.StringList= @stringlist

      @treeview = Plasma::TreeView.new self
      @treeview.Model = @model
      @layout.add_item @treeview

#########################################################################
# working sample in python (altough not as plasma widget)
# from PyQt4.QtCore import *
# from PyQt4.QtGui import *
# import sys
# from random import randint
#
# app = QApplication(sys.argv)
# model = QStandardItemModel()
#
# for n in range(10):
#   item = QStandardItem('Item %s' % randint(1, 100))
#   check = Qt.Checked if randint(0, 1) == 1 else Qt.Unchecked
#   item.setCheckState(check)
#   item.setCheckable(True)
#   model.appendRow(item)
#
#   view = QListView()
#   view.setModel(model)
#   view.show()
#   app.exec_()
#########################################################################

      @listview = Qt::ListView.new #self
      @listview.Model = @model
      @listview.view_mode = Qt::ListView::IconMode #Qt::ListView::ListMode
      @listview.show
      
      @lineedit = Plasma::LineEdit.new self
      begin
        @line_edit.clear_button_shown = true # not supported in early plasma versions
      rescue
        nil # but that doesn't matter
      end
      #@lineedit.click_message = 'Add a new string...'
      Qt::Object.connect(@lineedit,  SIGNAL(:returnPressed), self, SLOT(:addText) )
      @layout.addItem @lineedit

        self.setLayout(self.layout)
        self.resize(250,400)



      #@label = Plasma::Label.new self
      #@label.text = 'This plasmoid will copy the text you enter below to the clipboard.'
      #@layout.add_item @label


      #@layout.add_item @line_edit

      #@button = Plasma::PushButton.new self
      #@button.text = 'Copy to clipboard'
      #@layout.add_item @button

      #Qt::Object.connect( @button, SIGNAL(:clicked), self, SLOT(:addText) )
      #Qt::Object.connect( @line_edit, SIGNAL(:returnPressed), self, SLOT(:addText) )
    end

    def addText
      #Qt::Application.clipboard.text = @lineedit.text
      @stringlist << @lineedit.text
      @model.string_list = @stringlist
      @lineedit.text = ""
    end

  end
end

#to_do = ToDo::ToDo.new
#
#a_task = ToDo::Task.new 'compra il latte', 1, Time.now + 1
#to_do.add a_task
#
#a_task = ToDo::Task.new 'Telefonare!', 2, Time.now + 3
#to_do.add a_task
#
#a_task = ToDo::Task.new 'Garage', nil, Time.now + 1
#to_do.add a_task
#
#a_task = ToDo::Task.new 'bollette', 5
#to_do.add a_task
#
#to_do.each {|t| puts t.to_yaml}
#to_do.save
#
#to_do = ToDo::ToDo.new
#to_do.load
#to_do.each {|t| puts t.to_yaml}
