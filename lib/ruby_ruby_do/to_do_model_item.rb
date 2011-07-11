# An example of a ModelItem for use in RQtModel. Note that it does not need to descend from QObject.
#
# The ModelItem consists of a data member (the text displayed in the tree), a parent ToDoQtModelItem, and an array of child ToDoQtModelItems. This array corresponds directly to the Model 'rows' owned by this item.
# See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
class ToDoQtModelItem
  attr_writer :data
  attr_accessor :parent
  attr_reader :children

  def initialize(data, parent = nil)
    @data = data
    @parent = parent
    @children = []
    parent.addChild(self) if parent
  end

  # Return the ToDoQtModelItem at index 'row' in @children. This can be made lazy
  # by using a data source (e.g. database, filesystem) instead of an array for @children.
  def child(row)
    @children[row]
  end

  # Return row of child that matches 'item'. This can be made lazy by using
  # a data source (e.g. database, filesystem) instead of an array for @children.
  def childRow(item)
    @children.index(item)
  end

  # Return number of children. This can be made lazy by using a data source
  # (e.g. database, filesystem) instead of an array for @children.
  def rowCount
    @children.size
  end

  # Used to determine if the item is expandible.
  def hasChildren
    rowCount > 0
  end

  # Add a child to this ToDoQtModelItem. This puts the item into @children.
  def addChild(item)
    item.parent = self
    @children << item
  end

  #
  def data(column, role)
    #return "#{@data}-c#{column}"
    puts "role==Qt::DecorationRole" if role == Qt::DecorationRole
    case role
#      when Qt::CheckStateRole
#        if index.column == 0
#            ret_val = ((task.done?)? Qt::Checked: Qt::Unchecked).to_i
#        else
#          ret_val = nil
#        end
      when Qt::DisplayRole
        #puts task
        case column
          when 0
            ret_val = "#{@data}-c#{column}" # (task.done?) ? 'done': 'to do'
          when 1
            ret_val =  "#{@data}-c#{column}" #task.priority
          when 2
            ret_val =  "#{@data}-c#{column}" #task.description
          when 3
            ret_val = "#{@data}-c#{column}" #(task.overdue? and !task.done?)? '!': ''
          when 4
            #if task.done?
            #  ret_val =  "#{@data}-c#{column}" #task.fulfilled_date
            #else
              ret_val =  "#{@data}-c#{column}" #(task.due_date.nil?)? '-': task.due_date
            #end
          else
            ret_val = nil
        end
      when Qt::StatusTipRole, Qt::ToolTipRole
        case column
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
#      when Qt::FontRole
#        ret_val = @font
#        if column == 3
#          ret_val.weight = Qt::Font.Bold
#        else
#          ret_val.weight = @font_normal
#        end
#        ret_val.setStrikeOut(true) #(task.done?)
#        return Qt::Variant.fromValue(ret_val)
      when Qt::TextAlignmentRole
        if column == 3
          ret_val = Qt::AlignHCenter.to_i
        else
          ret_val = Qt::AlignLeft.to_i
        end
      when Qt::DecorationRole
        if column == 0 && hasChildren
          return Qt::Variant.fromValue(Qt::Icon.fromTheme('arrow-down'))
        else
          ret_val = nil
        end
    else
      ret_val = nil
     end
     puts "data: exit for role #{role}, ret_val= #{ret_val}"
     return (ret_val.nil?)? Qt::Variant.new() : Qt::Variant.new(ret_val)

  end

end