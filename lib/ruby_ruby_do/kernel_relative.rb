module Kernel
  if RUBY_VERSION =~ /1\.8/
    def require_relative (filename)
      puts "#{__FILE__}->File.dirname(__FILE__)}/../#{filename}"
      require "#{File.dirname(__FILE__)}/../#{filename}"
    end
  end
end