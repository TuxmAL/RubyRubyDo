# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'plasma_applet'
require 'yaml'
#require 'enumerator'

module RubyRubyDo

  class Main < PlasmaScripting::Applet

    slots :add_text
    slots :selected

    def init
      self.set_minimum_size 350, 350
      self.has_configuration_interface = false
      self.aspect_ratio_mode = Plasma::IgnoreAspectRatio
      @svg = Plasma::Svg.new self
      @svg.imagePath = package.filePath("widgets", "background.svg") #'widgets/background.svg'
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout
      self.background_hints = Plasma::Applet.DefaultBackground

      @label = Plasma::Label.new self
      @label.text = 'RubyRubyDo ToDo list:'
      @layout.addItem @label

      @model = Qt::StandardItemModel.new self
      (1..10).each do |i|
        col1 = Qt::StandardItem.new
        col1.check_state = ((i % 3) == 0)? Qt.Checked : Qt.Unchecked
        col1.checkable = true
        col1.editable= false
        col2 = Qt::StandardItem.new((((i -1) % 5) + 1).to_s)
        col3 = Qt::StandardItem.new 'stringa'
        date = Date.today + i
        date = (date + 3 * 365) if ((i % 3) == 0)
        col4 = Qt::StandardItem.new date.strftime "%d/%m#{(date.year != DateTime.now.year)? '/%y':''}"
        @model.append_row [col1, col2, col3, col4]
      end

      @treeview = Plasma::TreeView.new self
      native_tree = @treeview.native_widget
      # now we try to camouflage the treeview into a listview
      native_tree.root_is_decorated = false
      native_tree.all_columns_show_focus = true
      native_tree.items_expandable = false
      # and more, into a checklistview
      native_tree.model = @model
      (0..@model.columnCount).each { |i| native_tree.resizeColumnToContents i }
      native_tree.alternatingRowColors = true

      @layout.add_item @treeview


      @lineedit = Plasma::LineEdit.new self
      begin
        @lineedit.clear_button_shown = true # not supported in early plasma versions
	@lineedit.click_message = 'Add a new string...'
      rescue
        puts "clear_button_shown or click_message not found!"
        nil # but that doesn't matter
      end
      Qt::Object.connect(@lineedit,  SIGNAL(:returnPressed), self, SLOT(:add_text) )
      @layout.addItem @lineedit
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
