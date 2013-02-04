# -*- encoding: UTF-8 -*-
require 'Qt4'

class MyModel < Qt::AbstractItemModel
#  def initialize(parent = nil)
#    super parent
#  end
  def index(row, column = 0, parent = Qt::ModelIndex.new)
    Qt::ModelIndex.new if not parent.valid?
    createIndex(row, column, Qt::ModelIndex.new)
  end
  
  def parent(index)
    Qt::ModelIndex.new
  end
  
  def data(index, role)
    return Qt::Variant.new if (not index.valid?)
    case role
      #### needed both for bug action!!!
      #when Qt::StatusTipRole, Qt::ToolTipRole
      #  ret_val = 'StatusTip, ToolTip'
      #  return Qt::Variant.new(ret_val)
      when Qt::DisplayRole
        return Qt::Variant.new("datum")
      else
        return Qt::Variant.new
    end
  end

  def rowCount(index)
    5
  end

  def columnCount(index)
    3
  end

  def flags(index)
    return Qt::NoItemFlags
  end
end

Qt::Application.new(ARGV) do
  Qt::Widget.new do
    self.window_title = 'test bug'
    self.layout = Qt::VBoxLayout.new do
      treeview = Qt::TreeView.new do #self
         #mdl = Qt::DirModel.new
       mdl = MyModel.new(Qt::Application.instance)
        # but also the following lines can be used
        # mdl = MyModel.new self
#        mdl = MyModel.new

        ### needed for bug action!
        self.style_sheet = 'QTreeView::branch {background: palette(base) ;border-image: none;} QTreeView::item:!has-children:has-siblings:!adjoins-item {background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #E1E1E1, stop: 0.4 #DDDDDD, stop: 0.5 #D8D8D8, stop: 1.0 #D3D3D3)}'

        self.model = mdl
      end
      add_widget treeview

      button_quit = Qt::PushButton.new('Quit') do
        connect(SIGNAL :clicked) { Qt::Application.instance.quit }
      end
      add_widget(button_quit, 0, Qt::AlignRight)
    end
    self.show
  end
  self.exec
end
