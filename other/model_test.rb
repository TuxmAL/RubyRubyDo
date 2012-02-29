# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
#require 'enumerator'

#We need ToDo tasks
require 'to_do'
require 'task'

#require 'plasma_task'

module RubyRubyDo
  class PlasmaToDo  < Qt::AbstractItemModel

    signals 'dataChanged(const QModelIndex &, const QModelIndex &)'

    @@todo_list = nil

    def self.todo_list
      @@todo_list
    end

    def initialize parent
      super parent
      if @@todo_list.nil?
        @@todo_list = ToDo::ToDo.new
        #@@todo_list.load        
        a_task = ToDo::Task.new 'compra il latte', 1, Date.today + 1
        @@todo_list << a_task
        a_task = ToDo::Task.new 'Telefonare!', 2, Date.today + 3
        @@todo_list << a_task
        a_task = ToDo::Task.new 'Garage', 1, Date.today + 15
        @@todo_list << a_task
        a_task = ToDo::Task.new 'bollette', 5, Date.today - 15
        @@todo_list << a_task
        a_task = ToDo::Task.new 'test', 1
        @@todo_list << a_task
        a_task = ToDo::Task.new 'fatto', 1
        a_task.done
        @@todo_list << a_task
      end
      @font = Qt::Font.new('') #'Droid Sans'
    end

    def rowCount(index = Qt::ModelIndex.new)
      return @@todo_list.count
    end

    def columnCount(index = Qt::ModelIndex.new)
      # we will have 4 colums: done, priority, description, due_date
      return 5
    end

    def data(index, role)
      return QT::Variant.new unless index.is_valid
      return QT::Variant.new if (index.row >= @@todo_list.count)
      task = index.internal_pointer
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
          when 1
            ret_val =  task.priority
          when 2
            ret_val =  task.description
          when 3
            ret_val = (task.overdue?)? '!': ''
          when 4
            ret_val =  (task.due_date.nil?)? '-': task.due_date
          else
            ret_val = nil
        end
      when Qt::FontRole
	ret_val = @font
	#ret_val.italic = true
        if index.column == 3
	  ret_val.weight = Qt::Font.Bold
	else
	  ret_val.weight = Qt::Font.Light #Normal
	end
	ret_val.setStrikeOut(task.done?)
	#ret_val.setStrikeOut(true)
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
      return Qt::NoItemFlags if (index.row >= @@todo_list.count)
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
      return createIndex(row, column, @@todo_list[row])
    end

  end
end
