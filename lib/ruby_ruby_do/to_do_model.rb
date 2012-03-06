# This ToDoQtModel class is largely inspired to an example of a ModelItem
# from mkfs blog
# See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'to_do_model_item'

module RubyRubyDo

  # A basic tree model. The contents of all tree nodes are determined by the 
  # model items, not the model, so they may be loaded lazily.
  # See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
  class ToDoQtModel < Qt::AbstractItemModel
    signals 'dataChanged(const QModelIndex &, const QModelIndex &)'
    signals 'rowsInserted(const QModelIndex &, int, int)'
    signals 'rowsRemoved(const QModelIndex &, int, int)'

    @@todo_list = nil

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
      ToDoQtModelItem.font = parent.font
      ToDoQtModelItem.icons :expanded => Qt::Variant.fromValue(Qt::Icon.fromTheme('arrow-down')),
        :collapsed => Qt::Variant.fromValue(Qt::Icon.fromTheme('arrow-left'))
    end

    def todo
      @todo_list ||= setup_todo
    end

    # Load data into model.
    # This just creates a few top-level items as categories, then loads todos items.
    # Note: @root is created here in order to make clearing easy.
    # A clear() method just needs to set root to ModelItem.new('').
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
      to_do.due_for(Date.today + 7).each {|t| ToDoQtModelItem.new(t, next_weeks)}
      to_do.overdue.each {|t| ToDoQtModelItem.new(t, overdue)}
      to_do.with_no_date.each {|t| ToDoQtModelItem.new(t, no_date)}
      to_do.done.each {|t| ToDoQtModelItem.new(t, done)}
      #ToDoQtModelItem.new('1', next_days)
      #ToDoQtModelItem.new('2', next_days)
      return to_do
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
      when Qt::StatusTipRole, Qt::ToolTipRole
        case index.column
          when 0
            ret_val = Qt::Object.trUtf8('Checked if fulfilled.')
          when 1
            ret_val = Qt::Object.trUtf8('Priority.')
          when 2
            ret_val = Qt::Object.trUtf8('Task description.')
          when 3
            ret_val = Qt::Object.trUtf8('Overdue if marked.')
          when 4
            ret_val = Qt::Object.trUtf8('Due or fulfillment date.')
          else
            ret_val = ''
        end
        return Qt::Variant.new(ret_val)
      end
      item = itemFromIndex(index)
      # TODO: we must comment out this because the treeview was slowed-down sensibly!
      #if item and role == Qt::DisplayRole and item.parent == @root
      #  # puts item.data(0, role).to_s if item.hasChildren
      #  @widget.setRowHidden(index.row, index.parent, (item.hasChildren)? false: true)
      #end
      item ? item.data(index.column, role) : Qt::Variant.new
    end

    # Set data in a ToDoQtModelItem.
    # This is just an example to show how the signal is emitted.
    def data=(index, value, role)
      return false if (not index.valid?) or (role != Qt::EditRole and role != Qt::CheckStateRole)
      item = itemFromIndex(index)
      return false if not item
      changed = item.set_data(index.column, value, role)
      emit dataChanged(index, index) if changed      
      if [0, 4].include? index.column  
        case index.column 
        when 0 
          case value.value
          when (Qt::Checked).to_i
            category = index(6)
          when (Qt::Unchecked).to_i
            category = index_from_due_date(item.task)
          end
        when 4
          category = index_from_due_date(item.task)
        end
        p = itemFromIndex(index.parent)
        beginMoveRows(index.parent , index.row, index.row, category, rowCount(category))
        p.removeChild item
        itemFromIndex(category).addChild(item)
        endMoveRows()
      end
      changed
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

    # We will have 7 title rows:
    #   overdue, today, tomorrow, next_days, next_weeks, no_date, done.
    def titleCount()
      TITLEROWS
    end
    
    # Items created as needed fro everi kind of row and column.
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
          Qt::Variant.new Qt::Object.trUtf8('Priority')
        when 2
          Qt::Variant.new Qt::Object.trUtf8('Task')
        when 4
          Qt::Variant.new Qt::Object.trUtf8('Due for')
      else
        return Qt::Variant.new
      end
    end

    def insertRow(task, row, parent = Qt::ModelIndex.new)
      return insertRows(task, row, 1, parent)
    end

    # Warning! insertRows implementation must depends on insertRow and not viceversa as now is!
    def insertRows(task, row, count, parent = Qt::ModelIndex.new)
      y = index_from_due_date(task)
      r = rowCount y
      beginInsertRows(y, r, (r + (count - 1)))
      @todo_list << task
      ToDoQtModelItem.new(task, itemFromIndex(y))
      endInsertRows()
      emit rowsInserted y, r,  (r + (count - 1))
      return true
    end

    def delete_row(index)
      return removeRow(index.model.itemFromIndex(index), index.row, index.parent)
    end
    
    def removeRow(task, row, parent = Qt::ModelIndex.new)
      return removeRows(task, row, 1, parent)
    end

    # Warning! removeRows implementation must depends on removeRow and not viceversa as now is!
    def removeRows(task, row, count, parent = Qt::ModelIndex.new)
      beginRemoveRows(parent, row, (row + (count - 1)))
      ### nuovo codice
      parent_item = itemFromIndex(parent)
      for elem in ((row + count - 1)..row)
        eradicate_row(elem, parent_item)
      end
      ### fine nuovo codice
      #@todo_list.delete(task)
      #itemFromIndex(parent).removeChild(task)
      endRemoveRows()
      emit rowsRemoved parent, row,  (row + (count - 1))
      return true
    end

    private

    def eradicate_row(row, parent_item)
      task = parent_item.child(row)
      @todo_list.delete(task)
      parent_item.removeChild(task)
      return true
    end

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
      today = Date.today
      yesterday = today - 1
      tomorrow = today + 1
      todo_list = ToDo::ToDo.new
      task1 = ToDo::Task.new 'Compra il latte', 1, today
      task2 = ToDo::Task.new 'Telefonare!', 2, tomorrow
      task3 = ToDo::Task.new 'Garage', 3
      task4 = ToDo::Task.new 'Andare a pesca', 2, today - 9 
      task5 = ToDo::Task.new('Procurarsi chiave inglese', 2, today).done
      task6 = ToDo::Task.new('Procurarsi bulloni', 2, today + 7)
      task7 = ToDo::Task.new('Aggiustare il razzo', 2, today + 15)
      task8 = ToDo::Task.new 'Scrivere RubyRubyDo', 1
      task9 = ToDo::Task.new 'Elenchi', 1, yesterday
      todo_list << task1 << task2 << task3 << task4 << task5 << task6 <<
        task7 << task8 << task9
      todo_list << ToDo::Task.new('Compra il latte 5', 5, today)
      todo_list << ToDo::Task.new('Compra il latte 3', 3, today)
#      t = ToDo::Task.new('Chiave inglese 1', 1).done
#      todo_list << t
      t =  ToDo::Task.new('Chiave inglese 4', 4).done
      todo_list << t
#      t =  ToDo::Task.new('Procurarsi chiave a pappagallo domani 3', 3).done
#      todo_list << t
#      t =  ToDo::Task.new('Procurarsi chiave a pappagallo domani 1', 1, tomorrow)
#      todo_list << t.done
    end
  
  end
    
end
