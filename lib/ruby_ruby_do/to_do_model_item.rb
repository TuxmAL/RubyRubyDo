# An example of a ModelItem for use in RQtModel. Note that it does not need to descend from QObject.
#
# The ModelItem consists of a data member (the text displayed in the tree), a parent ToDoQtModelItem, and an array of child ToDoQtModelItems. This array corresponds directly to the Model 'rows' owned by this item.
# See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
class ToDoQtModelItem

  # Workaround for QT4.6.2 bug that prevent italic, underline, overline
  # and strikeout on a font if the weight is Qt::Font.Normal.
  QT_FONT_NORMAL = Qt::Font.Normal
  QT_FONT_NORMAL += 1 if Qt.version[0...4] == '4.6.' and ((2..3).map {|i| i.to_s}).include? Qt.version[4].chr
  QT_FONT_NORMAL.freeze

  attr_writer :data
  attr_accessor :parent
  attr_reader :children
  
  @@font = nil
  #@@icons = {} #{:collapsed => nil, :expanded => nil}

  def self.font=(font)
    @@font = font
  end
  
  def self.font
    @@font
  end
  
  def self.icons(args)
    @@icons ||= args
    @@icons.merge args
  end
  
  def initialize(data, parent = nil)
    @data = data
    @parent = parent
    @children = []
    parent.addChild(self) if parent
    lg = Qt::LinearGradient.new( 0, 0, 1, 1)
    lg.setColorAt(0, Qt::Color.fromRgb(255, 0, 0, 0))  # 231, 231,231)) # '#e7e7e7'
    lg.setColorAt(1, Qt::Color.fromRgb(0, 0, 255, 0)) #203, 203, 203)) # '#cbcbcb'
    @brush_for_categories = Qt::Variant.fromValue(Qt::Brush.new(lg))
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

  # Items created as needed fro everi kind of row and column.
  def flags(column)
    if hasChildren
      return Qt::ItemIsEnabled
    else
      case column
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
  end

  #
  def data(column, role)
    ret_val = nil
    if @data.class != ToDo::Task 
      case role
        when Qt::DisplayRole
          ret_val = @data
        when Qt::DecorationRole
          if column == 0
            return @@icons[:expanded]
          else
            return Qt::Variant.new
          end
        when Qt::BackgroundRole
          return @brush_for_categories 
      end
    else
      task = @data
      case role
        when Qt::CheckStateRole
          if column == 0
              ret_val = ((task.done?)? Qt::Checked: Qt::Unchecked).to_i
          else
            ret_val = nil
          end
        when Qt::DisplayRole
          case column
            when 0
              ret_val = ''
            when 1
              ret_val = task.priority
            when 2
              ret_val = task.description
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
        when Qt::FontRole
          ret_val = @@font
          ret_val.weight = (column == 3)? Qt::Font.Bold: QT_FONT_NORMAL
          ret_val.setStrikeOut(task.done?) if hasChildren
          return Qt::Variant.fromValue(ret_val)
        when Qt::TextAlignmentRole
          if column == 3
            ret_val = Qt::AlignHCenter.to_i
          else
            ret_val = Qt::AlignLeft.to_i
          end
       end
    end
    return (ret_val.nil?)? Qt::Variant.new() : Qt::Variant.new(ret_val)
  end

end
