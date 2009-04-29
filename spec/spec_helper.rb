require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'yad'

module GlobalHelpers 
  def set_example_hosts
    Rake::RemoteTask.host "app.example.com", :app
    Rake::RemoteTask.host "db.example.com", :db
  end
end

Spec::Runner.configure do |config|
  config.include(GlobalHelpers)
  
  config.before(:each) do
    Rake::RemoteTask.reset
    Rake.application.clear
    @task_count = Rake.application.tasks.size
    Rake::RemoteTask.set :domain, "example.com"
  end
end


class StringIO
  def readpartial(size) read end
end

module Process
  def self.expected status
    @@expected ||= []
    @@expected << status
  end

  class << self
    alias :waitpid2_old :waitpid2

    def waitpid2(pid)
      [ @@expected.shift ]
    end
  end
end


class Rake::RemoteTask
  attr_accessor :commands, :action, :input, :output, :error

  Status = Struct.new :exitstatus

  class Status
    def success?() exitstatus == 0 end
  end
  
  def system(*command)
    @commands << command
    self.action ? self.action[command.join(' ')] : true
  end
  
  def popen4(*command)
    @commands << command

    @input = StringIO.new
    out = StringIO.new @output.shift.to_s
    err = StringIO.new @error.shift.to_s

    raise if block_given?

    status = self.action ? self.action[command.join(' ')] : 0
    Process.expected Status.new(status)

   return 42, @input, out, err
  end
 
  def select(reads, writes, errs, timeout)
    [reads, writes, errs]
  end

end

