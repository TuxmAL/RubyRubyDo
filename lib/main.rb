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
  class Main < PlasmaScripting::Applet

    slots :addText

    def init
      set_minimum_size 250, 400
      self.has_configuration_interface = false
      #self.setAspectRatioMode= Plasma::IgnoreAspectRatio
      # py: self.layout = QGraphicsLinearLayout(Qt.Vertical, self.applet)
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout

      @theme = Plasma::Svg.new self
      puts @theme.inspect
      @theme.setImagePath("widgets/background")
      puts @theme.inspect
      self.BackgroundHints = Plasma::Applet.DefaultBackground

      @label = Plasma::Label.new self
      @label.text = 'TreeView Example:'
      @layout.addItem @label

      #@stringlist = [] #Qt::StringList.new
      #(1..10).each { |i| @stringlist << "Item #{i}, 1" }
      #@model = Qt::StringListModel.new self
      #@model.StringList= @stringlist

      @model = Qt::StandardItemModel.new self
      (1..10).each do |i|
	col1 = Qt::StandardItem.new  "lvElem #{i}" #, "column 2 of #{i}"]
	col1.check_state = (( i % 3) == 0)? Qt.Checked : Qt.Unchecked 
	col1.checkable = true
	col2 = Qt::StandardItem.new("column 2 of #{i}")
	col3 = Qt::StandardItem.new("due date for #{i}")
	@model.append_row [col1, col2, col3]
      end

      @treeview = Plasma::TreeView.new self
      # now we try to camouflage the treeview into a listview 
      @treeview.native_widget.root_is_decorated = false
      @treeview.native_widget.all_columns_show_focus = true
      @treeview.native_widget.items_expandable = false
      # and more, into a checklistview
      @treeview.Model = @model
      @layout.add_item @treeview
      
#      @listview = Qt::ListView.new #self
#      @listview.Model = @modellv
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
      Qt::Object.connect(@lineedit,  SIGNAL(:returnPressed), self, SLOT(:addText) )
      @layout.addItem @lineedit

        self.setLayout(self.layout)
        self.resize(250,400)



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

    def addText
      #Qt::Application.clipboard.text = @lineedit.text
      @stringlist << @lineedit.text
      @model.string_list = @stringlist
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
