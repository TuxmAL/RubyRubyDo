# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'Qt4'
require 'yaml'
#require 'enumerator'

require 'plasma_to_do'

module RubyRubyDo

  class Main < Qt::Widget

    slots :add_text
    slots :selected

    def initialize(parent = nil, name = nil)
      super
      self.set_minimum_size 350, 350
      #@layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      #self.layout = @layout

      #@label = Qt::Label.new self
      #@label.text = 'RubyRubyDo ToDo list:'
      #@layout.addItem @label

      @model = PlasmaToDo.new self

      @treeview = Qt::TreeView.new self
      native_tree = @treeview #.native_widget
      # now we try to camouflage the treeview into a listview
      native_tree.root_is_decorated = false
      native_tree.all_columns_show_focus = true
      native_tree.items_expandable = false
      # and more, into a checklistview
      native_tree.model = @model
      native_tree.item_delegate = PriorityDelegate.new @treeview #native_tree
      (0..@model.columnCount(0)).each { |i| native_tree.resizeColumnToContents i }
      native_tree.alternatingRowColors = true

      #@layout.add_item @treeview
      #@lineedit = Plasma::LineEdit.new self
      #begin
      #  @lineedit.clear_button_shown = true # not supported in early plasma versions
      #  @lineedit.click_message = 'Add a new string...'
      #rescue
      #  puts "clear_button_shown or click_message not found!"
      #  nil # but that doesn't matter
      #end
      #Qt::Object.connect(@lineedit,  SIGNAL(:returnPressed), self, SLOT(:add_text) )
      #@layout.addItem @lineedit
  end

    def add_text
      col1 = Qt::StandardItem.new
      col1.check_state = Qt.Unchecked
      col1.checkable = true
      col1.editable= false
      col2 = Qt::StandardItem.new  '1'
      col3 = Qt::StandardItem.new  @lineedit.text
      col4 = Qt::StandardItem.new  Time.now.strftime '%d/%m/%Y'
      @model.append_row [col1, col2, col3, col4]
      @lineedit.text = ""
    end

  end

  if $0 == __FILE__
    a = Qt::Application.new(ARGV)
    w = Main.new
#w.setGeometry(100, 100, 200, 120)
    #a.main_widget = w
    w.show
    a.exec
  end
end
