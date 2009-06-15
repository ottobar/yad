# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{yad}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Don Barlow"]
  s.date = %q{2009-06-12}
  s.email = %q{ottobar@perryburghacker.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "features/step_definitions/yad_steps.rb",
     "features/support/env.rb",
     "features/yad.feature",
     "lib/ext/rake.rb",
     "lib/ext/rake/remote_task.rb",
     "lib/ext/string.rb",
     "lib/yad.rb",
     "lib/yad/commands/app/passenger.rb",
     "lib/yad/commands/core.rb",
     "lib/yad/commands/db/rails.rb",
     "lib/yad/commands/framework/rails.rb",
     "lib/yad/commands/scm/git.rb",
     "lib/yad/tasks/app/passenger.rb",
     "lib/yad/tasks/core.rb",
     "lib/yad/tasks/db/rails.rb",
     "lib/yad/tasks/framework/rails.rb",
     "lib/yad/tasks/scm/git.rb",
     "spec/ext/rake/remote_task_spec.rb",
     "spec/spec_helper.rb",
     "spec/yad/commands/app/passenger_spec.rb",
     "spec/yad/commands/core_spec.rb",
     "spec/yad/commands/db/rails_spec.rb",
     "spec/yad/commands/framework/rails_spec.rb",
     "spec/yad/commands/maintenance/rails_spec.rb",
     "spec/yad/commands/scm/git_spec.rb"
  ]
  s.homepage = %q{http://yad.rubyforge.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{yad}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Yet another deployer, pretty much stolen from Vlad}
  s.test_files = [
    "spec/ext/rake/remote_task_spec.rb",
     "spec/spec_helper.rb",
     "spec/yad/commands/app/passenger_spec.rb",
     "spec/yad/commands/core_spec.rb",
     "spec/yad/commands/db/rails_spec.rb",
     "spec/yad/commands/framework/rails_spec.rb",
     "spec/yad/commands/maintenance/rails_spec.rb",
     "spec/yad/commands/scm/git_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_runtime_dependency(%q<open4>, ["~> 0.9.6"])
      s.add_development_dependency(%q<voloko-sdoc>, ["~> 0.2.12.1"])
      s.add_development_dependency(%q<technicalpickles-jeweler>, ["~> 1.0.1"])
    else
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<open4>, ["~> 0.9.6"])
      s.add_dependency(%q<voloko-sdoc>, ["~> 0.2.12.1"])
      s.add_dependency(%q<technicalpickles-jeweler>, ["~> 1.0.1"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<open4>, ["~> 0.9.6"])
    s.add_dependency(%q<voloko-sdoc>, ["~> 0.2.12.1"])
    s.add_dependency(%q<technicalpickles-jeweler>, ["~> 1.0.1"])
  end
end
