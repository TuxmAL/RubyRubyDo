require 'to_do_model_item'

module RubyRubyDo

   # A basic tree model. The contents of all tree nodes are determined by the model items, 
   # not the model, so they may be loaded lazily.
   # See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
  class ToDoQtModel < Qt::AbstractItemModel
    signals 'dataChanged(const QModelIndex &, const QModelIndex &)'

    # Number of title rows to display
    TITLEROWS = 6
    TITLEROWS.freeze
    # ToDo columns to display
    TODOCOLUMNS = 5
    TODOCOLUMNS.freeze

    # The invisible root item in the tree.
    attr_reader :root

    def initialize(parent = nil)
      super
      @root = nil
      load
      @font = parent.font
      # Workaround for QT4.6.2 bug that prevent italic, underline, overline
      # and strikeout on a font if the weight is Qt::Font.Normal.
      @font_normal = Qt::Font.Normal
      @font_normal += 1 if Qt.version[0...4] == '4.6.' and ((2..3).map {|i| i.to_s}).include? Qt.version[4].chr
    end

    # Load data into model. This just creates a few fake items as an example. A full implementation would create and fill the top-level items after creating.
    # Note: @root is created here in order to make clearing easy. A clear() method just needs to set root to ModelItem.new('').
    def load()
      @root = ToDoQtModelItem.new('',nil)
      overdue = ToDoQtModelItem.new('Overdue', @root)
      today = ToDoQtModelItem.new('Today', @root)
      tomorrow = ToDoQtModelItem.new('Tomorrow', @root)
      next_days = ToDoQtModelItem.new('Next days', @root)
      next_weeks = ToDoQtModelItem.new('Next weeks', @root)
      no_date = ToDoQtModelItem.new('No date', @root)
      ToDoQtModelItem.new('overdue 1', overdue)
      ToDoQtModelItem.new('overdue 2', overdue)
      ToDoQtModelItem.new('overdue 3', overdue)
      ToDoQtModelItem.new('today 1', today)
      ToDoQtModelItem.new('today 2', today)
      ToDoQtModelItem.new('tomorrow 1', tomorrow)
      ToDoQtModelItem.new('in the next days 1', next_days)
      ToDoQtModelItem.new('in the next days 2', next_days)
      ToDoQtModelItem.new('in the next weeks 1', next_weeks)
      ToDoQtModelItem.new('in the next weeks 2', next_weeks)
      ToDoQtModelItem.new('without a date 1', no_date)
    end
 
    # This treats an invalid index (returned by Qt::ModelIndex.new) as the index of @root.
    # All other indexes have the item itself stored in the 'internalPointer' field.
    # See AbstractItemModel#createIndex.
    def itemFromIndex(index)
      return @root if not index.valid?
      index.internalPointer
    end

    # Return the index of the parent item for 'index'.
    # The key here is to treat the invalid index (returned by Qt::ModelIndex.new) as the index of @root. All other (valid) indexes are generated by AbstractItemModel#createIndex. 
    # Note that the item itself is passed as the third parameter (internalPointer) to createIndex.
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
    # This is made a bit complicated by the fact that the ModelIndex must be created by AbstractItemModel.
    #
    # The parent of the parent is used to obtain the 'row' of the parent. If the parent is root, the invalid Modelndex is used as usual.
    def parent(index)
      return Qt::ModelIndex.new if not index.valid?

      item = itemFromIndex(index)
      parent = item.parent
      return Qt::ModelIndex.new if parent == @root

      pparent = parent.parent
      return Qt::ModelIndex.new if not pparent

      createIndex(pparent.childRow(parent), 0, parent)
    end

    # Return data for ToDoQtModelItem. This only handles the case where Display 
    # Data (the text in the Tree) is r/equested.
    def data(index, role)
      return Qt::Variant.new if (not index.valid?) or role != Qt::DisplayRole
      item = itemFromIndex(index)
      item ? Qt::Variant.new(item.data(index.column)) : Qt::Variant.new
    end

    # Set data in a ToDoQtModelItem. This is just an example to show how the signal is emitted.
    def data=(index, value, role)
      return false if (not index.valid?) or role != Qt::DisplayRole
      item = itemFromIndex(index)
      return false if not item
      item.data = value.to_s
      emit dataChanged(index, index)
      true
    end

    alias :setData :data=

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

    # We will have 5 columns: done, priority, description, overdue flag, due_date
    def titleCount()
      TITLEROWS
    end
    # All items can be enabled only.
    def flags(index)
      Qt::ItemIsEnabled
    end

    # Don't supply any header data.
    def headerData(section, orientation, role)
      return Qt::Variant.new
      if role != Qt::DisplayRole
        return Qt::Variant.new
      end
      case section
        when 0
          Qt::Variant.new ' '
        when 1
          Qt::Variant.new Qt::Object.trUtf8('Priority')
        when 2
          Qt::Variant.new Qt::Object.trUtf8('Task')
        when 4
          Qt::Variant.new Qt::Object.trUtf8('Due for')
      else
        return Qt::Variant.new
      end
    end
    
  end
  
end