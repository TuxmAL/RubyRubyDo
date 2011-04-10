# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'Qt4'
require 'yaml'
#require 'enumerator'

require 'to_do'
require 'plasma_to_do'

module RubyRubyDo
  Qt::Application.new(ARGV) do
    Qt::Widget.new do
      self.window_title = Qt::Object.trUtf8('RubyRubyDo')
      self.set_minimum_size 250, 250

      model = PlasmaToDo.new self
      treeview = Qt::TreeView.new do #self
        # now we try to camouflage the treeview into a listview
        self.root_is_decorated = false
        self.all_columns_show_focus = true
        self.items_expandable = false
        self.edit_triggers =Qt::AbstractItemView.SelectedClicked | Qt::AbstractItemView.CurrentChanged
        # and more, into a checklistview
        self.model = model
        self.item_delegate = PriorityDelegate.new self
        (0..model.columnCount(0)).each { |i| resizeColumnToContents i }
        self.alternatingRowColors = true
      end
      button_new = Qt::PushButton.new(Qt::Object.trUtf8('New')) do
        connect(SIGNAL :clicked) do
          todo = PlasmaToDo.todo
          puts "todo: #{todo.count}, treeview: #{treeview.model.rowCount}"
          todo << ToDo::Task.new('inserito a mano', 5 )
          treeview.model.insertRow todo.count - 1
          puts "todo: #{todo.count}, treeview: #{treeview.model.rowCount}"
        end
      end
      button = Qt::PushButton.new(Qt::Object.trUtf8('Quit')) do
        connect(SIGNAL :clicked) { Qt::Application.instance.quit }
      end
      self.layout = Qt::VBoxLayout.new do
        add_widget treeview
        h_layout =  Qt::HBoxLayout.new  do
          add_widget(button_new, 0, Qt::AlignLeft)
          add_widget(button, 0, Qt::AlignRight)
        end
        add_layout h_layout
        #self.activate
      end
      show
    end
    exec
  end
  
end
