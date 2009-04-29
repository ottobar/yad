$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rake'
require 'open4'
require 'yaml'

require "ext/rake/remote_task"
require "ext/rake"

module Yad
  # :stopdoc:
  VERSION = if File.exist?(File.join(File.dirname(__FILE__), '..', 'VERSION.yml'))
              config = YAML.load(File.read('VERSION.yml'))
              "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
            else
              "0.0.0"
            end
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  def self.version
    VERSION
  end

end
