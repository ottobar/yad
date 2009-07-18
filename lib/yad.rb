$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rake'
require 'open4'
require 'yaml'

require "ext/rake/remote_task"
require "ext/rake"
require "ext/string"

require "yad/core"
Yad::Core.define_tasks

require "yad/web/apache"

require "yad/maintenance/shared_system"

require "yad/app/passenger"

require "yad/framework/rails"

require "yad/db/rails"

require "yad/scm/git"

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
