$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rake'
require 'open4'
require 'yaml'

require "ext/rake/remote_task"
require "ext/rake"
require "ext/string"

require "yad/commands/core"

require "yad/commands/app/passenger"

require "yad/commands/framework/rails"

require "yad/commands/db/rails"

require "yad/commands/scm/git"

require "yad/tasks/core"

module Yad
  # :stopdoc:
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  
  VERSION = if File.exist?(File.join(PATH, 'VERSION.yml'))
              config = YAML.load_file(File.join(PATH, 'VERSION.yml'))
              "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
            else
              "0.0.0"
            end
  # :startdoc:

  # Returns the version string for the library.
  def self.version
    VERSION
  end
  
end
