# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
#require 'plasma_applet'
#require 'enumerator'

#We need ToDo Library
require 'plasma_task'

module RubyRubyDo
  class PlasmaToDo  < Qt::AbstractItemModel
    signals 'dataChanged(const QModelIndex &, const QModelIndex &)'

    @@todo_list = nil

    def self.todo
      @@todo_list
    end
    
    def todo
      @@todo_list ||= load_to_do_list
    end

    def initialize parent
      super parent
      @font = parent.font
      # Work around for QT4.6.2 bug that prevent italic, underline, overline
      # and strikeout on a font if the weight is Qt::Font.Normal.
      @font_normal = Qt::Font.Normal
      @font_normal += 1 if Qt.version == '4.6.2'      
    end

    def rowCount(index = Qt::ModelIndex.new)
      return todo.count
    end

    def columnCount(index = Qt::ModelIndex.new)
      # we will have 5 columns: done, priority, description, due_date
      return 5
    end

    def data(index, role)
      #puts index
      #puts "data function -> index: is_valid? #{index.is_valid}, row:#{index.row}, column: #{index.column}; Role: #{role}"
      return Qt::Variant.new unless index.is_valid
      return Qt::Variant.new if (index.row >= todo.count)
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
            ret_val = (task.overdue? and !task.done?)? '!': ''
          when 4
            if task.done?
              ret_val =  task.fulfilled_date
            else
              ret_val =  (task.due_date.nil?)? '-': task.due_date
            end
          else
            ret_val = nil
        end
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
      when Qt::FontRole
        ret_val = @font
        if index.column == 3
          ret_val.weight = Qt::Font.Bold
        else
          ret_val.weight = @font_normal
        end
        ret_val.setStrikeOut(task.done?)
        return Qt::Variant.fromValue(ret_val)
      when Qt::TextAlignmentRole
        if index.column == 3
          ret_val = Qt::AlignHCenter.to_i
        else
          ret_val = Qt::AlignLeft.to_i
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
          Qt::Variant.new Qt::Object.trUtf8('Priority')
        when 2
          Qt::Variant.new Qt::Object.trUtf8('Task')
        when 4
          Qt::Variant.new Qt::Object.trUtf8('Due for')
      else
        return Qt::Variant.new
      end
    end
    
    def flags(index)
      return Qt::NoItemFlags unless index.is_valid
      return Qt::NoItemFlags if (index.row >= todo.count)
      case index.column
        when 0
          return Qt::ItemIsUserCheckable + Qt::ItemIsSelectable + Qt::ItemIsEnabled
        when 1
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled + Qt::ItemIsEditable
        when 2
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled + Qt::ItemIsEditable
        when 3
          return Qt::ItemIsSelectable + Qt::ItemIsEnabled
        when 4
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
      return createIndex(row, column, todo[row])
    end

    def setData(index, value, role)
      return QT::Variant.new unless index.is_valid
      return QT::Variant.new if (index.row >= todo.count)
      task = index.internal_pointer
      case role
      when Qt::CheckStateRole
        if index.column == 0
          case value.value
          when (Qt::Checked).to_i
            task.done
          when (Qt::Unchecked).to_i
            task.undone
          end
        end
      emit layoutAboutToBeChanged
      idx = index # Remember the QModelIndex that will change
      # Update your internal data
      changePersistentIndex(idx, idx)
      emit layoutChanged
      when Qt::EditRole
        case index.column
        when 1
          task.priority = (value.to_i)
        when 2
          task.description = value
        when 4
          task.due_date = nil
          puts "setData: value=#{value.value}; isValid=#{value.is_valid}"
          task.due_date = Date.jd(value.toDate.toJulianDay) if value.is_valid and value.value != '-'
        end
      end
      emit(dataChanged( index, index )) if [Qt::CheckStateRole, Qt::EditRole].include? role
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

   private
   
   def load_to_do_list
      todo = ToDo::ToDo.new
      a_task = ToDo::Task.new 'compra il latte', 1, Date.today + 1
      todo << a_task
      a_task = ToDo::Task.new 'Telefonare!', 2, Date.today + 3
      todo << a_task
      a_task = ToDo::Task.new 'Garage', 1, Date.today + 15
      todo << a_task
      a_task = ToDo::Task.new 'bollette', 5, Date.today - 5
      todo << a_task
      a_task = ToDo::Task.new 'test', 1
      todo << a_task
      a_task = ToDo::Task.new 'fatto', 1
      a_task.done
      todo << a_task
      #todo.load
      #todo.each {|t| puts t.to_yaml}
    end

 end

end
