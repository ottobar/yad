require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "yad"
    gem.description = "Yad: Yet Another Deployer"
    gem.summary = %Q{Yet another deployer, pretty much stolen from Vlad}
    gem.email = "ottobar@perryburghacker.com"
    gem.homepage = "http://yad.rubyforge.org"
    gem.authors = ["Don Barlow"]
    gem.rubyforge_project = "yad"
    gem.add_dependency('rake', '~> 0.8.7')
    gem.add_dependency('open4', '~> 0.9.6')
    gem.add_development_dependency('voloko-sdoc', '~> 0.2.12.1')
    gem.add_development_dependency('technicalpickles-jeweler', '~> 1.0.1')
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
begin
  require 'sdoc'
  Rake::RDocTask.new('doc') do |rdoc|
    if File.exist?('VERSION.yml')
      config = YAML.load(File.read('VERSION.yml'))
      version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
    else
      version = ""
    end

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "Yad: Yet Another Deployer v#{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('LICENSE')
    rdoc.main = 'README.rdoc'
    rdoc.template = 'direct'
  end
rescue LoadError
  puts "Sdoc not available. Install it with: sudo gem install voloko-sdoc -s http://gems.github.com"
end

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do
    
    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]
    
    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:doc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/yad/"
        local_dir = 'doc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end
