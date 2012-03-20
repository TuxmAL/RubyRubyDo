# -*- encoding: UTF-8 -*-
# QT main for RubyRubyDo todo application.
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


#required libraries to rely on.
require 'Qt4'

$:.unshift File.join(File.dirname(__FILE__))
require 'to_do'
require 'to_do_model'
require 'to_do_model_item_delegate'
require 'to_do_edit_task'

module RubyRubyDo
  APP_NAME = 'RubyRubyDo'

  # Set the display date format
  TODO_DATE_FORMAT = '%d/%m/%Y'
  TODO_DATE_FORMAT.freeze

  def self.resize_treeview(treeview)
    unless treeview.model.todo.empty?
      (0..treeview.model.columnCount(0)).each { |i| treeview.resizeColumnToContents i }
    end    
  end

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
        self.header_hidden = true #false
        self.items_expandable = false #true
        self.style_sheet = RubyRubyDo::style_from_sheet()
        #self.edit_triggers =Qt::AbstractItemView.SelectedClicked #| Qt::AbstractItemView.CurrentChanged
        # and more, into a checklistview
        self.model = model
        self.item_delegate = ToDoQtModelItemDelegate.new self
        #(0..model.columnCount(0)).each { |i| resizeColumnToContents i }
        #self.alternatingRowColors = true
        self.model.connect(SIGNAL('dataChanged(const QModelIndex &, const QModelIndex &)')) do
          self.model.todo.save
        end
        self.model.connect(SIGNAL('rowsInserted(const QModelIndex &, int, int)')) do
          self.model.todo.save
        end
        self.model.connect(SIGNAL('rowsRemoved(const QModelIndex &, int, int)')) do
          self.model.todo.save
        end        
      end
      treeview.expand_all
      root_index = Qt::ModelIndex.new
      (0...model.titleCount).each { |i| treeview.set_first_column_spanned(i, root_index, true)}

      self.layout = Qt::VBoxLayout.new do
        h_layout = Qt::HBoxLayout.new do
          date_show = Qt::Label.new
          button = Qt::PushButton.new() do
            self.icon = Qt::Icon.fromTheme('view-pim-calendar') #'view-calendar'
            self.flat = true
            #TODO: add the choosen date to the new task.
            connect(SIGNAL :clicked) do
              dlg = ToDoCalendarDialog.new(self)
              if (dlg.exec == Qt::Dialog::Accepted)
                date_show.text = Date.jd(dlg.selected_date).strftime(TODO_DATE_FORMAT)
              else
                date_show.text = nil
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
          add_widget date_show
          button_add = Qt::PushButton.new() do
            self.icon = Qt::Icon.fromTheme('list-add') #'view-task-add'
            self.flat = true
            connect(SIGNAL :clicked) do
              if line_edit.display_text != ""
                #todo = treeview.model.todo
                if treeview.selectionModel.hasSelection
                  puts "selection: #{treeview.model.itemFromIndex(treeview.selected_indexes.first)}"
                  pri = 1 || (treeview.model.itemFromIndex(treeview.selected_indexes.first)).task.priority
                else
                  pri = 1
                end
                new_task = ToDo::Task.new(line_edit.display_text, pri, ((date_show.text.nil?)? nil: Date.strptime(date_show.text, TODO_DATE_FORMAT)))
                treeview.model.insertRow new_task, 1
                RubyRubyDo.resize_treeview(treeview)
              end
              line_edit.text = date_show.text = nil
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
              dlg = ToDoQtEditTask.new self.parent, task_idx
              if (dlg.exec == Qt::Dialog::Accepted)
                treeview.model.todo.save
                puts "ok"
              else
                puts "cancel"
              end
            end
          end
          add_widget(button_detail, 0, Qt::AlignLeft)
          button_quit = Qt::PushButton.new(Qt::Object.trUtf8('Quit')) do
            connect(SIGNAL :clicked) { Qt::Application.instance.quit }
          end
          add_widget(button_quit, 0, Qt::AlignRight)
        end
        add_layout h_layout
        #self.activate
      end
      # need to shift focus on line_edit instead of date button.
      treeview.set_focus(Qt::OtherFocusReason)
      RubyRubyDo::resize_treeview(treeview)
      unless treeview.model.todo.empty?
        (0..treeview.model.columnCount(0)).each { |i| treeview.resizeColumnToContents i }
      end
      show
    end
    exec
  end
 
end
