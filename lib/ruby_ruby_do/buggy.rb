# -*- encoding: UTF-8 -*-
require 'Qt4'

class ToDoQtModelItem

  attr_accessor :internal_data
  attr_accessor :parent
  attr_reader :children

  def initialize(data, parent = nil)
    @internal_data = data
    @parent = parent
    @children = []
    parent.addChild(self) if parent
  end

  def child(row)
    @children[row]
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

  def method_missing(meth_id, *args)
    puts "to_do_model_item: manca #{meth_id.id2name}(#{args.join(',')})!"
    super meth_id, *args
  end

end

class ToDoQtModel < Qt::AbstractItemModel

  # The invisible root item in the tree.
  attr_reader :root

  def initialize(parent = nil)
    super
    @widget = parent

    @root = ToDoQtModelItem.new('',nil)
    overdue = ToDoQtModelItem.new('Overdue', @root)
    today = ToDoQtModelItem.new('Today', @root)
    tomorrow = ToDoQtModelItem.new('Tomorrow', @root)
    next_days = ToDoQtModelItem.new('Next days', @root)
    next_weeks = ToDoQtModelItem.new('Next weeks', @root)
    no_date = ToDoQtModelItem.new('No date', @root)
    done = ToDoQtModelItem.new('Done', @root)
  end

  # This treats an invalid index (returned by Qt::ModelIndex.new) as the index of @root.
  # All other indexes have the item itself stored in the 'internalPointer' field.
  # See AbstractItemModel#createIndex.
  def itemFromIndex(index)
    return @root if not index.valid?
    index.internalPointer
  end

  # Return the index of the item for 'index'.
  # The key here is to treat the invalid index
  # (returned by Qt::ModelIndex.new) as the index of @root.
  # All other (valid) indexes are generated by AbstractItemModel#createIndex.
  # Note that the item itself is passed as the third parameter
  # (internalPointer) to createIndex.
  # See ToDoQtModelItem#parent and ToDoQtModelItem#childRow.
  def index(row, column = 0, parent = Qt::ModelIndex.new)
    item = itemFromIndex(parent)
    if item
      child = item.child(row)
      return createIndex(row, column, child) if child
    end
    Qt::ModelIndex.new
  end

  # Return the index of the parent item for 'index'.
  # This is made a bit complicated by the fact that the ModelIndex
  # must be created by AbstractItemModel.
  #
  # The parent of the parent is used to obtain the 'row' of the parent.
  # If the parent is root, the invalid Modelndex is used as usual.
  def parent(index)
    return Qt::ModelIndex.new if not index.valid?

    item = itemFromIndex(index)
    parent = item.parent
    return Qt::ModelIndex.new if parent == @root

    pparent = parent.parent
    return Qt::ModelIndex.new if not pparent

    createIndex(pparent.childRow(parent), 0, parent)
  end

  # Return data for ToDoQtModelItem.
  def data(index, role)
    return Qt::Variant.new if (not index.valid?)
    case role
      #### needed both for bug action!!!
      when Qt::StatusTipRole, Qt::ToolTipRole
        ret_val = 'StatusTip, ToolTip'
        return Qt::Variant.new(ret_val)
      when Qt::DisplayRole
        #item = itemFromIndex(index)
        #return (item.nil?)? Qt::Variant.new : Qt::Variant.new(item.internal_data)
        return Qt::Variant.new("datum")
      else
         return Qt::Variant.new
      end
  end

  def rowCount(index)
    item = itemFromIndex(index)
    item ? item.rowCount : 0
  end

  def columnCount(index)
    5
  end

  def flags(index)
    return Qt::NoItemFlags
  end

  def method_missing(meth_id, *args)
    puts "to_do_model: manca #{meth_id.id2name}(#{args.join(',')})!"
    super meth_id, args
  end

end

Qt::Application.new(ARGV) do
  Qt::Widget.new do
    self.window_title = 'test bug'
    mdl = nil
    treeview = Qt::TreeView.new do #self
      #mdl = Qt::DirModel.new self
      mdl = ToDoQtModel.new(Qt::Application.instance)
      # but also the following line can be used
      # mdl = ToDoQtModel.new self

      ### needed for bug action!
      self.style_sheet = 'QTreeView::branch {background: palette(base) ;border-image: none;} QTreeView::item:!has-children:has-siblings:!adjoins-item {background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #E1E1E1, stop: 0.4 #DDDDDD, stop: 0.5 #D8D8D8, stop: 1.0 #D3D3D3)}'

      self.model = mdl
    end

    self.layout = Qt::VBoxLayout.new do
      add_widget treeview

      #### needed for bug action!!!
      h_layout =  Qt::HBoxLayout.new  do
        button_quit = Qt::PushButton.new('Quit') do
          connect(SIGNAL :clicked) { Qt::Application.instance.quit }
        end
        add_widget(button_quit, 0, Qt::AlignRight)
      end
      add_layout h_layout
    end
    self.show
  end
  self.exec
end

def method_missing(meth_id, *args)
  puts "buggy: manca #{meth_id.id2name}(#{args.join(',')})!"
  super meth_id, *args
end
