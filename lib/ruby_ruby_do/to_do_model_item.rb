# This ToDoQtModelItem class is largely inspired to an example of a ModelItem
# from mkfs blog
# See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] 
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

module RubyRubyDo

  # An example of a ModelItem for use in RQtModel. Note that it does not need to
  # descend from QObject.
  # The ModelItem consists of a data member (the text displayed in the tree), a 
  # parent ToDoQtModelItem, and an array of child ToDoQtModelItems. This array 
  # corresponds directly to the Model 'rows' owned by this item.
  # See: {Ruby, Qt4, and AbstractItemModel}[http://entrenchant.blogspot.com/2011/03/ruby-qt4-and-abstractitemmodel.html] from mkfs blog
  class ToDoQtModelItem

    # Workaround for QT4.6.2 bug that prevent italic, underline, overline
    # and strikeout on a font if the weight is Qt::Font.Normal.
    QT_FONT_NORMAL = Qt::Font.Normal
    QT_FONT_NORMAL += 1 if Qt.version[0...4] == '4.6.' and ((2..3).map {|i| i.to_s}).include? Qt.version[4].chr
    QT_FONT_NORMAL.freeze
    
    # Set the difference from normal font size used for Tasks and font size used for Category
    TODO_FONT_SIZE_DIFFERENCE = -1.0
    TODO_FONT_SIZE_DIFFERENCE.freeze
    
    #Set the date format for the undone task
    TODO_DATE_FORMAT = '%d/%m/%Y'#'%a %d/%m'
    TODO_DATE_FORMAT.freeze

    attr_writer :data
    attr_accessor :parent
    attr_reader :children

    @@font = nil
    #@@icons = {} #{:collapsed => nil, :expanded => nil}

    def self.font=(font)
      @@font = font
      fi = Qt::FontInfo.new @@font
      @@font_metrics = Qt::FontMetrics.new(font)
      @@font_to_do = font.point_size_f
      @@font_category = @@font_to_do + TODO_FONT_SIZE_DIFFERENCE
      @@text_min_size = @@font_metrics.size(Qt::TextSingleLine, 'x' * 20)
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
        #lg = Qt::LinearGradient.new( 0, 0, 1, 1)
        #lg.setColorAt(0, Qt::Color.fromRgb(255, 0, 0, 0))  # 231, 231,231)) # '#e7e7e7'
        #lg.setColorAt(1, Qt::Color.fromRgb(0, 0, 255, 0)) #203, 203, 203)) # '#cbcbcb'
        #@brush_for_categories = Qt::Variant.fromValue(Qt::Brush.new(lg))
        #@brush_for_categories = Qt::Variant.fromValue(Qt::Brush.new(0.255,0))
        #@brush_for_data = Qt::Variant.fromValue(Qt::Brush.new(255.0,0))
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
    
    def removeChild(item)
      item.parent = nil
      @children.delete(item)
    end

    # Items created as needed fro every kind of row and column.
    def flags(column)
      if hasChildren
        return Qt::ItemIsEnabled
      else
        editable = 0        
        editable = Qt::ItemIsEditable if @data.respond_to?(:done?) and (!@data.done?)
        case column
          when 0
            return Qt::ItemIsUserCheckable + Qt::ItemIsSelectable + Qt::ItemIsEnabled
          when 1
            return Qt::ItemIsSelectable + Qt::ItemIsEnabled + editable
          when 2
            return Qt::ItemIsSelectable + Qt::ItemIsEnabled + editable
          when 3
            return Qt::ItemIsSelectable + Qt::ItemIsEnabled
          when 4
            return Qt::ItemIsSelectable + Qt::ItemIsEnabled + editable
          else
            return Qt::NoItemFlags
        end
      end
    end

    #
    def data(column, role)
      ret_val = nil
      #if ! @data.respond_to?(:done?)
      #Try to see if @data is a task
      if @data.class != ToDo::Task 
        case role
          when Qt::DisplayRole
            ret_val = @data
          when Qt::FontRole
            ret_val = @@font            
            ret_val.point_size_f = @@font_category
            ret_val.weight = Qt::Font.Bold
            ret_val.setStrikeOut(false)
            return Qt::Variant.fromValue(ret_val)
          when Qt::DecorationRole
            if column == 0
              return @@icons[:expanded]
            else
              return Qt::Variant.new
            end
            #when Qt::BackgroundRole
            #  return @brush_for_categories 
        end
      else
        task = @data
        case role
            #when Qt::BackgroundRole
            #  return @brush_for_data
          when Qt::SizeHintRole
            case column
            when 0
              ret_val = Qt::Size.new(20, 15)
            when 1
              ret_val = @@font_metrics.size(Qt::TextSingleLine, 'xx')
            when 2
              ret_val = @@text_min_size.expanded_to(@@font_metrics.size(Qt::TextSingleLine, task.description))
            else
              ret_val = Qt::Size.new(10, 15)              
            end
            ret_val = Qt::Size.new(0, 2) + ret_val
            puts "column: #{column}->size(#{ret_val.width},#{ret_val.height})"
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
                  ret_val =  (task.due_date.nil?)? '-': task.due_date.strftime(TODO_DATE_FORMAT)
                end
              else
                ret_val = nil
            end
          when Qt::FontRole
            ret_val = @@font
            ret_val.point_size_f = @@font_to_do
            ret_val.weight = (column == 3)? Qt::Font.Bold: QT_FONT_NORMAL
            ret_val.setStrikeOut(task.done?)
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

    def set_data(column, value, role)
      task = @data
      if @data.class == ToDo::Task
        case role
        when Qt::CheckStateRole
          if column == 0
            case value.value
            when (Qt::Checked).to_i
              task.done
            when (Qt::Unchecked).to_i
              task.undone
            end
            true
          else
            false
          end
        when Qt::EditRole
          case column
          when 1
            task.priority = (value.to_i)
          when 2
            task.description = value
          when 4
            task.due_date = nil
            puts "setData: value=#{value.value}; isValid=#{value.is_valid}"
            task.due_date = Date.jd(value.toDate.toJulianDay) if value.is_valid and value.value != '-'
          end
          true
        else
          false
        end
      else
        false
      end
    end

    def task
      @data if @data.respond_to?(:due_date)
    end
  end
end
