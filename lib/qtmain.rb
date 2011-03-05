# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'Qt4'
require 'yaml'
#require 'enumerator'

require 'plasma_to_do'

module RubyRubyDo
  Qt::Application.new(ARGV) do
      Qt::Widget.new do

          self.window_title = "RubyRubyDo"
          self.set_minimum_size 250, 250

          model = PlasmaToDo.new self
          treeview = Qt::TreeView.new do #self
             # now we try to camouflage the treeview into a listview
            self.root_is_decorated = false
            self.all_columns_show_focus = true
            self.items_expandable = false
            # and more, into a checklistview
            self.model = model
    #      native_tree.item_delegate = PriorityDelegate.new @treeview # native_tree
            (0..model.columnCount(0)).each { |i| resizeColumnToContents i }
            self.alternatingRowColors = true
          end
          button = Qt::PushButton.new('Quit') do
              connect(SIGNAL :clicked) { Qt::Application.instance.quit }
          end

          self.layout = Qt::VBoxLayout.new do
            add_widget treeview
            add_widget(button, 0, Qt::AlignRight)
            self.activate
          end
          show
      end
      exec
  end
  
end
