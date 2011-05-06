# <Copyright and license information goes here.>
#
#required libraries to rely on.
require 'Qt4'

$:.unshift File.join(File.dirname(__FILE__))
require 'to_do'
require 'plasma_to_do'
require 'plasma_edit_task'

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
        self.edit_triggers =Qt::AbstractItemView.SelectedClicked #| Qt::AbstractItemView.CurrentChanged
        # and more, into a checklistview
        self.model = model
        self.item_delegate = PriorityDelegate.new self
        (0..model.columnCount(0)).each { |i| resizeColumnToContents i }
        self.alternatingRowColors = true
      end
      self.layout = Qt::VBoxLayout.new do
        add_widget treeview
        h_layout =  Qt::HBoxLayout.new  do
          button_new = Qt::PushButton.new(Qt::Object.trUtf8('New')) do
            connect(SIGNAL :clicked) do
              todo = PlasmaToDo.todo
              puts "todo: #{todo.count}, treeview: #{treeview.model.rowCount}"
              todo << ToDo::Task.new('inserito a mano', 5 )
              treeview.model.insertRow todo.count - 1
              puts "todo: #{todo.count}, treeview: #{treeview.model.rowCount}"
            end
          end
          add_widget(button_new, 0, Qt::AlignLeft)
          button_detail = Qt::PushButton.new(Qt::Object.trUtf8('Details...')) do
            connect(SIGNAL :clicked) do
              # TODO: set parameter correctly!
              task = nil
              task = treeview.selectedIndexes.first.internalPointer if treeview.selectionModel.hasSelection
              dlg = PlasmaEditTask.new self.parent, task
              if (dlg.exec == Qt::Dialog::Accepted)
                puts "ok"
              else
                puts "cancel"
              end
            end
          end
          add_widget(button_detail, 0, Qt::AlignCenter)
          button_quit = Qt::PushButton.new(Qt::Object.trUtf8('Quit')) do
            connect(SIGNAL :clicked) { Qt::Application.instance.quit }
          end
          add_widget(button_quit, 0, Qt::AlignRight)
        end
        add_layout h_layout
        #self.activate
      end
      show
    end
    exec
  end

end
