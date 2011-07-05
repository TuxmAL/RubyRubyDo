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
    childCount > 0
  end

  # Add a child to this ToDoQtModelItem. This puts the item into @children.
  def addChild(item)
    item.parent = self
    @children << item
  end

  #
  def data(column)
    return "#{@data}-c#{column}"
  end

end