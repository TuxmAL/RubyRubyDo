module ToDo
  class ToDo
    include Enumerable

    TODOFILE = File.expand_path('~/.RubyRuby.Do')

    def initialize
      @tasks = Array.new
      @filename = TODOFILE
      puts @filename
    end

    def add(task)
      @tasks << task
    end

    def each
      @tasks.each { |t| yield t }
    end

    def save
      File.open(@filename, 'w') {|f| f.write(@tasks.to_yaml) }
    end

    def load
      @tasks = YAML::load( File.open(@filename, 'r')) # YAML::load_stream( File.open( 'README' ) )
    end
  end
end
