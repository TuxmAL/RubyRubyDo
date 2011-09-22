# <Copyright and license information goes here.>
#
#required libraries to rely on.
require 'Qt4'

$:.unshift File.join(File.dirname(__FILE__))
require 'to_do'
require 'to_do_model'
require 'to_do_model_item_delegate'

module RubyRubyDo
  APP_NAME = 'RubyRubyDo'
     
  def self.style_from_sheet(default = false)
    filename = File.join(File.dirname(__FILE__), (APP_NAME + '.css').downcase)
    if ! default && File.exist?(filename)
      File.read(filename)
    else
      #self.style_sheet = 'QTreeView::branch {background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #e7e7e7, stop: 1 #cbcbcb) ;border-image: none;}'
      # 'QTreeView::item { background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #e7e7e7, stop: 1 #cbcbcb);color:black;}'
      #  To remove branch decoration we use QTreeview styles
      # trick: 'background: palette(base);' is needed (in qt 4.6 at least) to effectively remove decoration!      
      'QTreeView::branch {background: palette(base) ;border-image: none;}
       /*QTreeView::item:has-children, */
       QTreeView::item:!has-children:has-siblings:!adjoins-item
          {background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #E1E1E1, stop: 0.4 #DDDDDD, stop: 0.5 #D8D8D8, stop: 1.0 #D3D3D3)}'
    end
  end

  line_edit = nil
  Qt::Application.new(ARGV) do
    Qt::Widget.new do
      self.window_title = Qt::Object.trUtf8(APP_NAME)
      self.set_minimum_size 300, 350
      self.windowIcon=Qt::Icon.fromTheme('mail-mark-task')

      model = nil # PlasmaToDo.new self
      treeview = Qt::TreeView.new do #self
        model = ToDoQtModel.new self
        # now we try to camouflage the treeview into a listview
        self.root_is_decorated = false
        self.all_columns_show_focus = true
        self.header_hidden = false #true
        self.items_expandable = false #true
        self.style_sheet = RubyRubyDo::style_from_sheet()
        #self.edit_triggers =Qt::AbstractItemView.SelectedClicked #| Qt::AbstractItemView.CurrentChanged
        # and more, into a checklistview
        self.model = model
        self.item_delegate = ToDoQtModelItemDelegate.new self
        #(0..model.columnCount(0)).each { |i| resizeColumnToContents i }
        #self.alternatingRowColors = true
      end
      treeview.expand_all
      root_index = Qt::ModelIndex.new
      (0...model.titleCount).each { |i| treeview.set_first_column_spanned(i, root_index, true)}

      self.layout = Qt::VBoxLayout.new do
        h_layout = Qt::HBoxLayout.new do
          button = Qt::PushButton.new() do
            self.icon = Qt::Icon.fromTheme('view-pim-calendar') #'view-calendar'
            self.flat = true
            #TODO: add the choosen date to the new task.
            connect(SIGNAL :clicked) do
              dlg = CalendarDialog.new(self)
              if (dlg.exec == Qt::Dialog::Accepted)
                puts "new task calendar (a): #{dlg.selected_date}"
                #value = Qt::Variant.new(Qt::Date.fromJulianDay(dlg.selected_date))
              else
                #value = Qt::Variant.new index.data.value
              end               
            end
          end
          add_widget button
          line_edit = Qt::LineEdit.new do
            begin
              self.placeholder_text = Qt::Object.trUtf8('Add a new Task...')
              #self.clear_button_shown = true
            rescue
              puts "clear_button_shown or click_message not found!"
              nil # but that doesn't matter
            end
          end          
          add_widget line_edit
          button_add = Qt::PushButton.new() do
            self.icon = Qt::Icon.fromTheme('list-add') #'view-task-add'
            self.flat = true
            connect(SIGNAL :clicked) do
              if line_edit.display_text != ""
                todo = treeview.model.todo              
                if treeview.selectionModel.hasSelection
                  puts "selection: #{treeview.selected_indexes.first.inspect}"
                  priority = treeview.selected_indexes.first.internal_pointer.priority
                  row = treeview.selected_indexes.first.row
                else
                  priority = 3
                  row = todo.count - 1
                end              
                todo.insert(row + 1, ToDo::Task.new(line_edit.display_text , priority ))
                treeview.model.insertRow row
              end
              line_edit.text = ""
            end
          end
          Qt::Object.connect(line_edit,  SIGNAL(:returnPressed), button_add, SIGNAL(:clicked) )
          add_widget button_add
          button_conf = Qt::PushButton.new() do
            self.flat = true
            self.icon = Qt::Icon.fromTheme('configure')
            self.enabled= false
          end
          add_widget button_conf
        end
        #add_widget button_add
        add_item h_layout
        add_widget treeview
        h_layout =  Qt::HBoxLayout.new  do
          button_detail = Qt::PushButton.new(Qt::Object.trUtf8('Details...')) do
            connect(SIGNAL :clicked) do
              # TODO: set parameter correctly!
              task_idx ||= treeview.selectedIndexes.first if treeview.selectionModel.hasSelection
              dlg = PlasmaEditTask.new self.parent, task_idx
              if (dlg.exec == Qt::Dialog::Accepted)
                puts "ok"
              else
                puts "cancel"
              end
            end
          end
          add_widget(button_detail, 0, Qt::AlignCenter)
          button_quit = Qt::PushButton.new(Qt::Object.trUtf8('Quit')) do
            connect(SIGNAL :clicked) { Qt::Application.instance.quit }
          end
          add_widget(button_quit, 0, Qt::AlignRight)
        end
        add_layout h_layout
        #self.activate
      end
      # need to shift focus on line_edit instead of date button.
      line_edit.set_focus(Qt::OtherFocusReason)
      show
    end
    exec
  end
  
end
