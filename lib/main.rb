#required libraries to rely on.
require 'rubygems'
require 'json'
require 'json/pure'

#We need ToDo tasks
require 'to_do'
require 'task_to_do'

to_do = ToDo.new

a_task = TaskToDo.new 'compra il latte', 1, Time.now + 1
to_do.add a_task

a_task = TaskToDo.new 'Telefonare!', 2, Time.now + 3
to_do.add a_task
a_task = TaskToDo.new 'Garage', nil, Time.now + 1
to_do.add a_task

a_task = TaskToDo.new 'bollette', 5
to_do.add a_task

puts to_do.save
