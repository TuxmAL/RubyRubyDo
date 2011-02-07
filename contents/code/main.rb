# <Copyright and license information goes here.>
#
#required libraries to rely on.
#require 'rubygems'
require 'yaml'
#require 'enumerator'

#require 'file'

#We need ToDo tasks
require 'to_do'
require 'task'


require 'plasma_applet'

module RubyRubyDo
  class Main < PlasmaScripting::Applet
    def initialize parent
      super parent
    end

    def init
      self.has_configuration_interface = false
      resize 125, 125
      self.aspect_ratio_mode = Plasma::Square
    end

    def paintInterface(painter, option, rect)
      painter.save
      painter.pen = Qt::Color.new Qt::red
      painter.draw_text rect, Qt::AlignVCenter | Qt::AlignHCenter, "Hello Ruby!"
      painter.restore
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
