# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'yaml'
#require 'enumerator'
require 'plasma_to_do'

module RubyRubyDo

  class Main < PlasmaScripting::Applet

    slots :add_text
    slots :selected

    def init
      #set_minimum_size 250, 400
      self.set_minimum_size 350, 350
      self.has_configuration_interface = false
      #self.setAspectRatioMode= Plasma::IgnoreAspectRatio
      self.aspect_ratio_mode = Plasma::IgnoreAspectRatio
      @svg = Plasma::Svg.new self
      @svg.imagePath = package.filePath("widgets", "background.svg") #'widgets/background.svg'
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout
      #self.background_hints = Plasma::Applet.DefaultBackground # Plasma::Applet.NoBackground # Plasma::Applet.TranslucentBackground

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

      @model = PlasmaToDo.new self
      #puts @model.methods(true)
      puts '************************----*************'
      #puts @model.methods(false)

      #puts "#{@model.row_count}, #{@model.column_count}"
      #puts @model.header_data(0,1,0).value
      #puts @model.header_data(1,1,0).value
      #puts @model.header_data(2,1,0).value
      #puts @model.header_data(3,1,0).value
      #puts @model.header_data(4,1,0).value
      puts '************************----*************'

      @treeview = Plasma::TreeView.new self
      native_tree = @treeview.native_widget
      # now we try to camouflage the treeview into a listview
      native_tree.root_is_decorated = false
      native_tree.all_columns_show_focus = true
      native_tree.items_expandable = false
      # and more, into a checklistview
      native_tree.model = @model
      native_tree.item_delegate = PriorityEdit.new # self  # setItemDelegate
      (0..@model.columnCount(0)).each { |i| native_tree.resizeColumnToContents i }
      native_tree.alternatingRowColors = true
      @layout.add_item @treeview

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
#puts (to_do[1]).to_yaml
#to_do.each {|t| puts t.to_yaml}
#to_do.save
#
#to_do = ToDo::ToDo.new
#to_do.load
#to_do.each {|t| puts t.to_yaml}
