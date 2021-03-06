# -*- encoding: UTF-8 -*- :nodoc:
# 
# ToDo::Task task definition for ToDo.
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
$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/

require 'date'

module ToDo
  # Part of this class (the one dealing with "dirtyness" and changes of some of 
  # the attributes) is stolen from the ActiveRecord::Dirty module.
  class Task
    PRIORITYMAX = 1
    PRIORITYMIN = 5

    attr_reader :description, :due_date, :category, :id, :priority, :fulfilled_date

    def initialize(description = '<empty task>', priority = Task::PRIORITYMIN,
        due_date = nil,category = nil)
      raise RangeError, "Priority out of range (was #{priority.inspect}, expected #{PRIORITYMAX}-#{PRIORITYMIN})" unless !priority.nil? && priority.between?(PRIORITYMAX, PRIORITYMIN)
      @fulfilled=false
      @description = description
      @priority = priority
      @due_date = due_date
      @fulfilled_date = nil
      @category = category
      @id = Time.now.tv_usec
      @changed_attributes = nil
    end

    # Define how to order two  _tasks_.
    # if not done yet, a task is ordered by due date (no due date are always at the
    # bottom) and if equals by priority (_PRIORITYMAX_ being the highest and 
    # __PRIORITYMIN__ the lowest).
    # if the task is already done, then we first check if both are fulfilled:
    # in this case the ordering is first by fulfillment date 
    def <=>(a_task)
      if !(@fulfilled_date.nil? or a_task.fulfilled_date.nil?)
        return (-(@fulfilled_date <=> a_task.fulfilled_date)).nonzero? || compare_by_due_date(a_task)
      else
        return compare_by_due_date(a_task) if (@fulfilled_date.nil? and a_task.fulfilled_date.nil?)
        return -1 if @fulfilled_date.nil?
        return 1 if a_task.fulfilled_date.nil?
      end
    end

    def done
      if ! @fulfilled
        changed_attributes[:fulfilled] = @fulfilled
        @fulfilled_date = Date.today
        @fulfilled = true
      end
      self
    end

    def undone
      if @fulfilled
        changed_attributes[:fulfilled] = @fulfilled
        @fulfilled_date = nil
        @fulfilled = false
      end
      self
    end

    def done?
      return @fulfilled
    end

    alias_method :fulfilled, :done?

    def priority=(value)
      raise RangeError, "Priority out of range (was #{value.inspect}, expected #{PRIORITYMAX}-#{PRIORITYMIN})" unless !value.nil? && value.between?(PRIORITYMAX, PRIORITYMIN)
      if @priority != value
        changed_attributes[:priority] = @priority
        @priority = value
      end
    end
    
    def description=(value)
      if @description != value 
        changed_attributes[:description] = @description
        @description = value
      end
    end

    def due_date=(value)
      if @due_date != value 
        changed_attributes[:due_date] = @due_date
        @due_date = value
      end
      
    end
    def category=(value)
      if @category != value 
        changed_attributes[:category] = @category
        @category = value
      end
    end
    
    def overdue?
      !@fulfilled && !@due_date.nil? && (@due_date < Date.today)
    end

    def due_today?
      !@fulfilled && !@due_date.nil? && (@due_date == Date.today)
    end

    def due_tomorrow?
      !@fulfilled && !@due_date.nil? && (@due_date == Date.today+ 1)
    end

    def due_this_week?
      !@fulfilled && !@due_date.nil? && ((Date.today..(Date.today + 6)).include? @due_date)
    end

    def due_with_no_date?
      !@fulfilled && @due_date.nil?
    end

    def saved
      changed_attributes.clear
    end  

    def saved?
      ! changed?
    end

    # Do any attributes have unsaved changes?
    #   task.changed? # => false
    #   task.priority = 5
    #   task.changed? # => true
    def changed?
      !changed_attributes.empty?
    end
    
    # List of attributes with unsaved changes.
    #   task.changed # => []
    #   task.description = 'take a beer'
    #   task.changed # => ['description']
    def changed
      changed_attributes.keys
    end

    # Map of changed attrs => [original value, new value].
    #   task.changes # => {}
    #   task.description = 'take a beer'
    #   task.changes # => { 'description' => ['go fishing', 'take a beer'] }
    def changes
      changed.inject({}) { |h, attr| h[attr] = attribute_change(attr); h }
    end

    # For the attributes :description, :due_date, :done, :priority, :category
    # this handle <tt>*_changed?</tt>, <tt>*_was</tt> and <tt>*_change</tt>.
    [:description, :due_date, :priority, :category].each do |attr|
      define_method("#{attr}_changed?") do
        changed_attributes.include?(attr)
      end
      define_method("#{attr}_was") do
        attribute_changed?(attr) ? changed_attributes[attr] : __send__(attr)
      end
      define_method("#{attr}_change") do
        [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
      end
    end
      
  private
    # Handle <tt>*_changed?</tt> for +method_missing+.
    def attribute_changed?(attr)
      changed_attributes.include?(attr)
    end

    # Handle <tt>*_change</tt> for +method_missing+.
    def attribute_change(attr)
      [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
    end

    # Map of change <tt>attr => original value</tt>.
    def changed_attributes
      @changed_attributes ||= {}
    end

    def compare_by_due_date(a_task)
      if !(@due_date.nil? or a_task.due_date.nil?)
        (@due_date <=> a_task.due_date).nonzero? || @priority <=> a_task.priority
      else
        return (@priority <=> a_task.priority) if @due_date.nil? and (a_task.due_date).nil?
        return 1 if (@due_date).nil?
        return -1 if (a_task.due_date).nil?
      end
    end
  
  end
  
end
