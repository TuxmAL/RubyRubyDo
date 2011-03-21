# Thanks to Gregory Brown for this snippet of code
# (see http://github.com/sandal/rbp/tree/master/testing/test_unit_extensions.rb )
# from "Ruby best practice" http://rubybestpractices.com/
# Chapter 1: Driving Code Through Tests, page 4, frame "A Test::Unit Trick to Know About"

module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock
  AssertionFailedError = Class.new(StandardError)

  class TestCase

    def self.must(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end

  end
end
