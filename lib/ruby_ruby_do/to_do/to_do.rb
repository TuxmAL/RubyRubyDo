# -*- encoding: UTF-8 -*- :nodoc:
# 
# Author::    TuxmAL (mailto:tuxmal@tiscali.it)
# Copyright:: Copyright (c) 2011 TuxmAL
# License::   _to be choosen_

$KCODE = "UTF-8" if RUBY_VERSION =~ /1\.8/
module ToDo
  class ToDo
    include Enumerable

    TODOFILE = File.expand_path('~/.RubyRuby.Do')

    def initialize
      @tasks = Array.new
      @filename = TODOFILE
    end

    def <<(task)
      @tasks << task
      self
    end

    def each
      @tasks.each { |t| yield t }
    end

    def [](index)
      @tasks[index]
    end

    def length
      @tasks.length
    end
    
    def save
      File.open(@filename, 'w') do |f|
        f.write(@tasks.to_yaml)
        @tasks.each {|t| t.saved}

      end
    end

    def load
      @tasks = YAML::load( File.open(@filename, 'r')) # YAML::load_stream( File.open(@filename) )
    end
  end
end
