# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rdoc/task'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = 'RubyRubyDo'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'RubyRubyDo is a todo application written entirely in Ruby, aiming to be used as a KDE plasmoid.'
  s.description = s.summary + "\n" + <<SUMMARY
  RubyRubyDo is a todo application written entirely in Ruby, aiming to be used as a KDE plasmoid. 
  Currently is under development as QT desktop application, as playground for the plasmoid itself.
SUMMARY
  s.requirements << 'ruby-qt4 or qt4-qtruby package needed: install it with your favourite package manager.'
  s.requirements << 'For mswin32 platform you\'ll need also qtruby4 gem.'

  s.author = 'TuxmAL'
  s.email = 'tuxmal@tiscali.it'
  s.homepage = "http://github.com/TuxmAL/RubyRubyDo"  
  s.executables = ['qtrubyrubydo']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "RubyRubyDo Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
