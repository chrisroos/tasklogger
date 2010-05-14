# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tasklogger}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Roos"]
  s.date = %q{2010-04-26}
  s.default_executable = %q{tasklogger}
  s.email = %q{chris@seagul.co.uk}
  s.executables = ["tasklogger"]
  s.files = ["Rakefile", "lib/task.rb", "lib/task_logger.rb", "bin/tasklogger"]
  s.homepage = %q{http://chrisroos.co.uk}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple task/time logging utility}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
