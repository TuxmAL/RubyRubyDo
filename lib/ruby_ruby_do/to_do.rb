# -*- encoding: UTF-8 -*-
$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/

# Standard library needed 
require 'yaml'
require 'date'

$:.unshift File.join(File.dirname(__FILE__))
# Our libraries
require 'to_do/task'
require 'to_do/to_do.rb'

module ToDo
    MAJOR = 0
    MINOR = 0
    TINY = 1

    VERSION = [MAJOR, MINOR, TINY].join('.')
end
