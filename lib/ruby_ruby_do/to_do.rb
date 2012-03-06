# -*- encoding: UTF-8 -*-
# ToDo module for RubyRubyDo todo library.
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
