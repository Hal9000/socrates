# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "socrates"
  s.version     = '0.0.1'
  s.authors     = ["Hal Fulton, et al."]
  s.email       = ["rubyhacker@gmail.com"]
  s.homepage    = "http://github.com/Hal9000/socrates.git"
  s.summary     = "A question-answer drilling tool written in Ruby."
  s.description = <<-EOF
    A tool for quizzing on various topics, designed to be effective, flexible, and
    extensible. It is intended to support multiple users, hierarchies of topics, and 
    multiple question types.  Ultimately, a sophisticated algorithm will maximize 
    memory and learning efficiency. Part of its purpose is an experiment in attaching
    multiple user interfaces to an "engine" or model.
    EOF
                     
  s.rubyforge_project = "socrates"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

# s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]

  s.add_development_dependency %q<bundler>, ["~> 1.0.0"]
  s.add_development_dependency %q<cucumber>
  s.add_development_dependency %q<rspec>, [">= 2.5.0"]
# s.add_development_dependency %q<simplecov>, [">= 0"]
# s.add_development_dependency %q<simplecov-rcov>, [">= 0"]
# s.add_development_dependency %q<yard>, ["~> 0.6.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<mocha>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
  s.add_development_dependency %q<guard-cucumber>

  case RUBY_PLATFORM
    when /darwin/
      s.add_development_dependency %q<growl_notify>
      s.add_development_dependency %q<rb-fsevent>
    when /linux/
      gem 'rb-inotify', :require => false
  end
end
