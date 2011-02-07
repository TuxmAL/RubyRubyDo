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
      set_minimum_size 150, 150

      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self
      self.layout = @layout

      @label = Plasma::Label.new self
      @label.text = 'This plasmoid will copy the text you enter below to the clipboard.'
      @layout.add_item @label

      @line_edit = Plasma::LineEdit.new self

      begin
        @line_edit.clear_button_shown = true # not supported in early plasma versions
      rescue
        nil # but that doesn't matter
      end

      @layout.add_item @line_edit

      @button = Plasma::PushButton.new self
      @button.text = 'Copy to clipboard'
      @layout.add_item @button

      Qt::Object.connect( @button, SIGNAL(:clicked), self, SLOT(:addText) )
      Qt::Object.connect( @line_edit, SIGNAL(:returnPressed), self, SLOT(:addText) )
    end

    def addText
      Qt::Application.clipboard.text = @line_edit.text
      @line_edit.text = ""
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
