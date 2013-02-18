# -*- encoding: UTF-8 -*-
require 'Qt4'
require_relative 'to_do'

class MyModel < Qt::AbstractItemModel
  def index(row, column = 0, parent = Qt::ModelIndex.new)
    Qt::ModelIndex.new if not parent.valid?
    createIndex(row, column, Qt::ModelIndex.new)
  end
  
  def parent(index)
    Qt::ModelIndex.new
  end
  
  def data(index, role)
    return Qt::Variant.new if (not index.valid?)
    case role
      #### needed both for bug action!!!
      #when Qt::StatusTipRole, Qt::ToolTipRole
      #  ret_val = 'StatusTip, ToolTip'
      #  return Qt::Variant.new(ret_val)
      when Qt::DisplayRole
        return Qt::Variant.new("datum")
      else
        return Qt::Variant.new
    end
  end

  def rowCount(index)
    5
  end

  def columnCount(index)
    3
  end

  def flags(index)
    return Qt::NoItemFlags
  end
end

 class ToDoQtModelItem
    attr_writer :to_do_task
    attr_accessor :parent
    attr_reader :children

    def initialize(data, parent = nil)
      @to_do_task = data
      @parent = parent
      @children = []
      parent.addChild(self) if parent
    end

    def child(row)
      @children[row]
    end

    def childRow(item)
      @children.index(item)
    end

    def rowCount
      @children.size
    end

    def hasChildren
      rowCount > 0
    end

    def addChild(item)
      item.parent = self
      @children << item
    end
    
    # Items created as needed fro every kind of row and column.
    def flags(column)
      return Qt::ItemIsEnabled 
    end

    def data(column, role)
      ret_val = nil
        puts "io sono #{@to_do_task.class}"

      if @to_do_task.class != ToDo::Task
        puts "e valgo #{@to_do_task}"
        case role
          when Qt::DisplayRole
            ret_val = @to_do_task
            ret_val = "sono una stringa"
        end
      else
        puts "OGGETTO"

        case role
          when Qt::DisplayRole
            ret_val = "sono un task"
         end
      end
      return (ret_val.nil?)? Qt::Variant.new() : Qt::Variant.new(ret_val)
    end
  
  end
 
class MyToDoQtModel < Qt::AbstractItemModel
    # Number of title rows to display
    TITLEROWS = 7
    TITLEROWS.freeze
    # ToDo columns to display
    TODOCOLUMNS = 5
    TODOCOLUMNS.freeze

    # The invisible root item in the tree.
    attr_reader :root

    def initialize(parent = nil)
      super
      @widget = parent
      @root = nil
      @todo_list = nil
      load
    end

    def todo
      @todo_list ||= setup_todo
    end

    def load
      @root = ToDoQtModelItem.new('',nil)
      overdue = ToDoQtModelItem.new('Overdue', @root)
      today = ToDoQtModelItem.new('Today', @root)
      tomorrow = ToDoQtModelItem.new('Tomorrow', @root)
      next_days = ToDoQtModelItem.new('Next days', @root)
      next_weeks = ToDoQtModelItem.new('Next weeks', @root)
      no_date = ToDoQtModelItem.new('No date', @root)
      done = ToDoQtModelItem.new('Done', @root)
      to_do = todo
      to_do.due_for(Date.today).each {|t| ToDoQtModelItem.new(t, today)}
      to_do.due_for(Date.today + 1).each {|t| ToDoQtModelItem.new(t, tomorrow)}
      to_do.due_between(Date.today + 2, Date.today + 7).each {|t| ToDoQtModelItem.new(t, next_days)}
      to_do.due_after(Date.today + 7).each {|t| ToDoQtModelItem.new(t, next_weeks)}
      to_do.overdue.each {|t| ToDoQtModelItem.new(t, overdue)}
      to_do.with_no_date.each {|t| ToDoQtModelItem.new(t, no_date)}
      to_do.done.each {|t| ToDoQtModelItem.new(t, done)}
      return to_do
    end
 
    def itemFromIndex(index)
      return @root if not index.valid?
      index.internalPointer
    end

    def index(row, column = 0, parent = Qt::ModelIndex.new)
      item = itemFromIndex(parent)
      if item
        child = item.child(row)
        return createIndex(row, column, child) if child
      end
      Qt::ModelIndex.new
    end

    def parent(index)
      return Qt::ModelIndex.new if not index.valid?

      item = itemFromIndex(index)
      parent = item.parent
      return Qt::ModelIndex.new if parent == @root

      pparent = parent.parent
      return Qt::ModelIndex.new if not pparent

      createIndex(pparent.childRow(parent), 0, parent)
    end

    def data(index, role)
      return Qt::Variant.new if (not index.valid?)
      case role
#        when Qt::StatusTipRole, Qt::ToolTipRole
        when Qt::ToolTipRole
          case index.column
            when 0
              ret_val = 'Checked if fulfilled.'
            when 1
              ret_val = 'Priority.'
            when 2
             ret_val = 'Task description.'
            when 3
              ret_val = 'Overdue if marked.'
            when 4
              ret_val = 'Due or fulfillment date.'
            else
              ret_val = ''
          end
          return Qt::Variant.new(ret_val)
      else
        
      end

      item = itemFromIndex(index)
      # TODO: we must comment out this because the treeview was slowed-down sensibly!
      #if item and role == Qt::DisplayRole and item.parent == @root
      #  # puts item.data(0, role).to_s if item.hasChildren
      #  @widget.setRowHidden(index.row, index.parent, (item.hasChildren)? false: true)
      #end
      item ? item.data(index.column, role) : Qt::Variant.new
    end

    # Delegate rowCount to item.
    #
    # See ToDoQtModelItem#rowCount.
    def rowCount(index)
      item = itemFromIndex(index)
      item ? item.rowCount : 0
    end

    # We will have 5 columns: done, priority, description, overdue flag, due_date
    def columnCount(index)
      TODOCOLUMNS
    end

    # We will have 7 title rows:
    #   overdue, today, tomorrow, next_days, next_weeks, no_date, done.
    def titleCount()
      TITLEROWS
    end
    
    # Items created as needed fro every kind of row and column.
    def flags(index)
      return Qt::NoItemFlags unless index.is_valid
      item = itemFromIndex(index)
      item ? item.flags(index.column) : Qt::NoItemFlags
    end

    # Don't supply any header data.
    def headerData(section, orientation, role)
      if role != Qt::DisplayRole
        return Qt::Variant.new
      end
      case section
        when 0
          Qt::Variant.new ' '
        when 1
          Qt::Variant.new 'Priority'
        when 2
          Qt::Variant.new 'Task'
        when 4
          Qt::Variant.new 'Due for'
      else
        return Qt::Variant.new
      end
    end

    private

    def index_from_due_date(task)
      # the assignation ordering must not be changed!
      idx = 4                           # as default category is "Next weeks"
      idx = 5 if task.due_with_no_date? # category is "No date"
      idx = 0 if task.overdue?          # category is "Overdue"
      idx = 3 if task.due_this_week?    # category is "This week" (but will include today and tomorrow!)
      idx = 1 if task.due_today?        # category is "Today"
      idx = 2 if task.due_tomorrow?     # category is "Tomorrow"
      idx = 6 if task.done?             # category is "Done"
      return index(idx)
    end
  
    def setup_todo
      todo_list = ToDo::ToDo.new
      todo_list.load
    end
  
  end

Qt::Application.new(ARGV) do
  Qt::Widget.new do
    self.window_title = 'test bug'
    self.layout = Qt::VBoxLayout.new do
      treeview = Qt::TreeView.new do #self
         #mdl = Qt::DirModel.new
       mdl = MyModel.new(Qt::Application.instance)
       mdl = MyToDoQtModel.new(Qt::Application.instance)
       mdl.load
        # but also the following lines can be used
        # mdl = MyModel.new self
#        mdl = MyModel.new

        ### needed for bug action!
        self.style_sheet = 'QTreeView::branch {background: palette(base);border-image: none;} QTreeView::item:!has-children:has-siblings:!adjoins-item {background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #E1E1E1, stop: 0.4 #DDDDDD, stop: 0.5 #D8D8D8, stop: 1.0 #D3D3D3)}'

#        self.style_sheet = " QTreeView {
#     show-decoration-selected: 1;
# }
#
# QTreeView::item {
#      border: 1px solid #d9d9d9;
#     border-top-color: transparent;
#     border-bottom-color: transparent;
# }
#
# QTreeView::item:hover {
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #e7effd, stop: 1 #cbdaf1);
#     border: 1px solid #bfcde4;
# }
#
# QTreeView::item:selected {
#     border: 1px solid #567dbc;
# }
#
# QTreeView::item:selected:active{
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #6ea1f1, stop: 1 #567dbc);
# }
#
# QTreeView::item:selected:!active {
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #6b9be8, stop: 1 #577fbf);
# }
#
#The branches of a QTreeView are styled using the ::branch subcontrol. The following stylesheet color codes the various states when drawing a branch.
#
# QTreeView::branch {
#         background: palette(base);
# }
#
# QTreeView::branch:has-siblings:!adjoins-item {
#         background: cyan;
# }
#
# QTreeView::branch:has-siblings:adjoins-item {
#         background: red;
# }
#
# QTreeView::branch:!has-children:!has-siblings:adjoins-item {
#         background: blue;
# }
#
# QTreeView::branch:closed:has-children:has-siblings {
#         background: pink;
# }
#
# QTreeView::branch:has-children:!has-siblings:closed {
#         background: gray;
# }
#
# QTreeView::branch:open:has-children:has-siblings {
#         background: magenta;
# }
#
# QTreeView::branch:open:has-children:!has-siblings {
#         background: green;
# } QTreeView {
#     show-decoration-selected: 1;
# }
#
# QTreeView::item {
#      border: 1px solid #d9d9d9;
#     border-top-color: transparent;
#     border-bottom-color: transparent;
# }
#
# QTreeView::item:hover {
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #e7effd, stop: 1 #cbdaf1);
#     border: 1px solid #bfcde4;
# }
#
# QTreeView::item:selected {
#     border: 1px solid #567dbc;
# }
#
# QTreeView::item:selected:active{
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #6ea1f1, stop: 1 #567dbc);
# }
#
# QTreeView::item:selected:!active {
#     background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #6b9be8, stop: 1 #577fbf);
# }
#
#The branches of a QTreeView are styled using the ::branch subcontrol. The following stylesheet color codes the various states when drawing a branch.
#
# QTreeView::branch {
#         background: palette(base);
# }
#
# QTreeView::branch:has-siblings:!adjoins-item {
#         background: cyan;
# }
#
# QTreeView::branch:has-siblings:adjoins-item {
#         background: red;
# }
#
# QTreeView::branch:!has-children:!has-siblings:adjoins-item {
#         background: blue;
# }
#
# QTreeView::branch:closed:has-children:has-siblings {
#         background: pink;
# }
#
# QTreeView::branch:has-children:!has-siblings:closed {
#         background: gray;
# }
#
# QTreeView::branch:open:has-children:has-siblings {
#         background: magenta;
# }
#
# QTreeView::branch:open:has-children:!has-siblings {
#         background: green;
# }#"
#          
        self.model = mdl
      end
      add_widget treeview

      button_quit = Qt::PushButton.new('Quit') do
        connect(SIGNAL :clicked) { Qt::Application.instance.quit }
      end
      add_widget(button_quit, 0, Qt::AlignRight)
    end
    self.show
  end
  self.exec
end
