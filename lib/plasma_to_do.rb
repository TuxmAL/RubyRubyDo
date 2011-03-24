# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
#require 'enumerator'

#We need ToDo tasks
require 'to_do'
require 'task'

require 'plasma_task'

module RubyRubyDo
  class PlasmaToDo  < Qt::AbstractItemModel

    @@todo_list = nil

    def self.todo_list
      @@todo_list
    end

    def initialize parent
      super parent
      if @@todo_list.nil?
        @@todo_list = ToDo::ToDo.new
        #@@todo_list.load        
        a_task = ToDo::Task.new 'compra il latte', 1, (Date.jd(DateTime.now.jd) + 1)
        @@todo_list << a_task
        a_task = ToDo::Task.new 'Telefonare!', 2, (Date.jd(DateTime.now.jd) + 3)
        @@todo_list << a_task
        a_task = ToDo::Task.new 'Garage', 1, (Date.jd(DateTime.now.jd) + 15)
        @@todo_list << a_task
        a_task = ToDo::Task.new 'bollette', 5
        @@todo_list << a_task
        a_task = ToDo::Task.new 'test', 1
        @@todo_list << a_task
        a_task = ToDo::Task.new 'fatto', 1
        a_task.done
        @@todo_list << a_task
      end
      #@@todo_list.each {|t| puts t.to_yaml}
    end

    def rowCount(index = Qt::ModelIndex.new)
      return @@todo_list.count
    end

    def columnCount(index = Qt::ModelIndex.new)
      # we will have 4 colums: done, priority, description, due_date
      return 4
    end

    def data(index, role)
      #puts index
      #puts "data function -> index: is_valid? #{index.is_valid}, row:#{index.row}, column: #{index.column}; Role: #{role}"
      return QT::Variant.new unless index.is_valid
      return QT::Variant.new if (index.row >= @@todo_list.count)
      task = index.internal_pointer
      #puts task.inspect
      #puts 'case switch'
      case role
      when Qt::CheckStateRole
        if index.column == 0
            ret_val = ((task.done?)? Qt::Checked: Qt::Unchecked).to_i
        else
          ret_val = nil
        end
      when Qt::DisplayRole
        #puts task
        case index.column
#          when 0
            #ret_val = (task.done?) ? 'done': 'to do'
          when 1
            ret_val =  task.priority
          when 2
            ret_val =  task.description
          when 3
            ret_val =  (task.due_date.nil?)? '-': task.due_date #task.due_date.strftime('%d/%m/%Y')
          else
            ret_val = nil
        end
      when Qt::StatusTipRole, Qt::ToolTipRole
        case index.column
          when 0
            ret_val = 'Is task accomplished?'
          when 1
            ret_val = 'Task priority.'
          when 2
            ret_val = 'Task description.'
          when 3
                ret_val = 'Task due date.'
          else
            ret_val = 'Pluto!'
        end
      else
        ret_val = nil
     end
     #puts "data: exit for role #{role}, ret_val= #{ret_val}"
     return (ret_val.nil?)?  Qt::Variant.new : Qt::Variant.new(ret_val)
    end

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
        when 3
          Qt::Variant.new 'Due for'
      else
        return Qt::Variant.new
      end
    end
    
    def flags(index)
      return Qt::NoItemFlags unless index.is_valid
      return Qt::NoItemFlags if (index.row >= @@todo_list.count)
      case index.column
        when 0
          return Qt::ItemIsUserCheckable + Qt::ItemIsSelectable + Qt::ItemIsEnabled
        when 1
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled + Qt::ItemIsEditable
        when 2
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled + Qt::ItemIsEditable
        when 3
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled + Qt::ItemIsEditable
        else
          return Qt::NoItemFlags
      end
    end

    def parent(index)
      return Qt::ModelIndex.new
    end

    def index(row,column = 0, parent = Qt::ModelIndex.new )
      #puts "index function -> parent:#{parent}, row:#{row}, column:#{column}, hasIndex: #{hasIndex(row, column, parent)}"
      return Qt::ModelIndex.new if ! hasIndex(row, column, parent)
      return createIndex(row, column, @@todo_list[row])
    end

    def setData(index, value, role)
      ret_val = false
      return QT::Variant.new unless index.is_valid
      return QT::Variant.new if (index.row >= @@todo_list.count)
      task = index.internal_pointer
      case role
      when Qt::CheckStateRole
        if index.column == 0
          case value.value
          when (Qt::Checked).to_i
            task.done
            ret_val |= true
          when (Qt::Unchecked).to_i
            task.undone
            ret_val |= true
          end
        end
      when Qt::EditRole
        case index.column
        when 1
          task.priority = (value.to_i)
        when 2
          task.description = value
        when 3
          puts
          task.due_date = value
        end
      end
      dataChanged( index, index ) if ret_val
    end

    #def header_data=
    #  # The headerDataChanged() signals must be emitted explicitly when reimplementing the setHeaderData() function
    #end
    
    def insertRow(row, parent = Qt::ModelIndex.new)
      insertRows(row, 1, parent)
    end

    def insertRows(row, count, parent = Qt::ModelIndex.new)
      beginInsertRows(parent, row, (row + (count - 1)))
      endInsertRows()
      return true
    end

    def removeRow(row, parent = Qt::ModelIndex.new)
      return removeRows(row, 1, parent)
    end

   def removeRows(row, count, parent= Qt::ModelIndex.new)
     beginRemoveRows(parent, row, row) # must be beginRemoveRows(parent, row, *count*)?
     node = nodeFromIndex(parent)
     node.removeChild(row)
     endRemoveRows()
     return true
   end
  end
end

