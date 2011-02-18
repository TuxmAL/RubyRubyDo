# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'yaml'
#require 'enumerator'

#We need ToDo tasks
require 'to_do'
require 'task'

module RubyRubyDo

  class PlasmaTask < Qt::AbstractListModel

    @@todo_list = nil

    def initialize parent
      super parent
      if @@todo_list.nil?
        @@todo_list = ToDo::ToDo.new
        #@@todo_list.load
        a_task = ToDo::Task.new 'compra il latte', 1, Time.now + 1
        @@todo_list.add a_task
        a_task = ToDo::Task.new 'Telefonare!', 2, Time.now + 3
        @@todo_list.add a_task
        a_task = ToDo::Task.new 'Garage', nil, Time.now + 1
        @@todo_list.add a_task
        a_task = ToDo::Task.new 'bollette', 5
        @@todo_list.add a_task
      end
      #@@todo_list.each {|t| puts t.to_yaml}
    end
    
    def row_count()
      puts @@todo_list.count
      @@todo_list.count
    end

    def column_count()
      puts 1
      #whe will have 4 colums: done, priority, description, due_date
      return 1
    end

    def data(index)
      data index, Qt::DisplayRole
    end
    def data()
      data 1, Qt::DisplayRole
    end
    
    def data(index, role)
      puts index.is_valid
      puts index
      puts role
      return QT::Variant.new unless index.is_valid
      return QT::Variant.new if (index.row >= @@todo_list.count)
      puts index.row
      puts index.column

      if role == Qt::DisplayRole
        task = @@todo_list[index.row]
        case index.column
          when 0
            return Qt::Variant.new task.done
          when 1
            return Qt::Variant.new task.priority
          when 2
            return Qt::Variant.new task.description
          when 3
            return Qt::Variant.new task.due_date
          else
            return QT::Variant.new 'Pippo!'
        end
      else
        return QT::Variant.new
     end
    end

    def header_data(section, orientation, role)
      puts "section: #{section}, orientation: #{orientation}, role: #{role}"
      if role != Qt::DisplayRole
        return QT::Variant.new
      end
       if orientation == Qt::Horizontal
         return Qt::Variant.new "Column #{section}"
       else
         return Qt::Variant.new "Row #{section}"
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

    def parent(model_index)
      return Qt::ModelIndex.new
    end

    #def index(row,column = 0, parent = Qt::ModelIndex.new )
    #  super.create_index row, column, parent
    #end

    #def data=
    #  # The dataChanged() signals must be emitted explicitly when reimplementing the setData() function
    #end
    #def header_data=
    #  # The headerDataChanged() signals must be emitted explicitly when reimplementing the setHeaderData() function
    #end


  end

  class Main < PlasmaScripting::Applet

    slots :add_text
    slots :selected

    def init
      #set_minimum_size 250, 400
      self.set_minimum_size 350, 350
      self.has_configuration_interface = false
      #self.setAspectRatioMode= Plasma::IgnoreAspectRatio
      self.aspect_ratio_mode = Plasma::IgnoreAspectRatio
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout

      @theme = Plasma::Svg.new self
      @theme.ImagePath = 'widgets/background'
      self.BackgroundHints = Plasma::Applet.DefaultBackground

      @label = Plasma::Label.new self
      @label.text = 'RubyRubyDo ToDo list:'
      @layout.addItem @label

#      @stringlist = [] #Qt::StringList.new
#      (1..10).each { |i| @stringlist << "Item #{i}, 1" }
#      @model = Qt::StringListModel.new self
#      @model.StringList= @stringlist

 
#      @model = Qt::StandardItemModel.new self
#      (1..10).each do |i|
#        col1 = Qt::StandardItem.new
#        col1.check_state = (( i % 3) == 0)? Qt.Checked : Qt.Unchecked
#        col1.checkable = true
#        col1.editable= false
#        col2 = Qt::StandardItem.new i.to_s
#        col3 = Qt::StandardItem.new("column 2 of #{i}")
#        col4 = Qt::StandardItem.new("due date for #{i}")
#        @model.append_row [col1, col2, col3, col4]
#      end

      @model = PlasmaTask.new self
      puts @model.methods(true)
      puts '************************----*************'
      puts @model.methods(false)

      puts "#{@model.row_count}, #{@model.column_count}"
      puts @model.header_data(0,1,0).value
      puts @model.header_data(1,1,0).value
      puts @model.header_data(2,1,0).value
      puts @model.header_data(3,1,0).value
      puts @model.header_data(4,1,0).value
      puts '************************----*************'

#      @treeview = Plasma::TreeView.new self
#      # now we try to camouflage the treeview into a listview
#      @treeview.native_widget.root_is_decorated = false
#      @treeview.native_widget.all_columns_show_focus = true
#      @treeview.native_widget.items_expandable = false
#      # and more, into a checklistview
#      @treeview.native_widget.model = @model
#      @layout.add_item @treeview
      
#      @listview = Qt::ListView.new
#      @listview.model = @model
#      @listview.view_mode = Qt::ListView::ListMode #Qt::ListView::IconMode
#      @listview.show
      
      @lineedit = Plasma::LineEdit.new self
      begin
        @lineedit.clear_button_shown = true # not supported in early plasma versions
      rescue
	puts "clear_button_shown not found!"
        nil # but that doesn't matter
      end
      #@lineedit.click_message = 'Add a new string...'
      Qt::Object.connect(@lineedit,  SIGNAL(:returnPressed), self, SLOT(:add_text) )
      @layout.addItem @lineedit

      #@label = Plasma::Label.new self
      #@label.text = 'This plasmoid will copy the text you enter below to the clipboard.'
      #@layout.add_item @label

      #@layout.add_item @line_edit

      #@button = Plasma::PushButton.new self
      #@button.text = 'Copy to clipboard'
      #@layout.add_item @button

      #Qt::Object.connect( @button, SIGNAL(:clicked), self, SLOT(:addText) )
      #Qt::Object.connect( @line_edit, SIGNAL(:returnPressed), self, SLOT(:addText) )
    end

    def add_text
      #Qt::Application.clipboard.text = @lineedit.text
      #@stringlist << @lineedit.text
      col1 = Qt::StandardItem.new
      col1.check_state = Qt.Unchecked
      col1.checkable = true
      col1.editable= false
      col2 = Qt::StandardItem.new  '1'
      col3 = Qt::StandardItem.new  @lineedit.text
      col4 = Qt::StandardItem.new  Time.now.strftime '%d/%m/%Y'
      @model.append_row [col1, col2, col3, col4]
      #@model.string_list = @stringlist
      @lineedit.text = ""
    end

  end
end

#to_do = ToDo::ToDo.new
#
#a_task = ToDo::Task.new 'compra il latte', 1, Time.now + 1
#to_do.add a_task
#
#a_task = ToDo::Task.new 'Telefonare!', 2, Time.now + 3
#to_do.add a_task
#
#a_task = ToDo::Task.new 'Garage', nil, Time.now + 1
#to_do.add a_task
#
#a_task = ToDo::Task.new 'bollette', 5
#to_do.add a_task
#
#to_do.each {|t| puts t.to_yaml}
#to_do.save
#
#to_do = ToDo::ToDo.new
#to_do.load
#to_do.each {|t| puts t.to_yaml}
