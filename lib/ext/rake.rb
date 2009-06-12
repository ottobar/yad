module Rake
  module TaskManager
    # This gives us access to the tasks already defined in rake.
    def all_tasks
      @tasks
    end
  end

  # Simple shortcut for Rake.application.all_tasks
  def self.all_tasks
    Rake.application.all_tasks
  end

  # Hooks into rake and allows us to clear out a task by name or
  # regexp. Use this if you want to completely override a task instead
  # of extend it.
  def self.clear_tasks(*tasks)
    tasks.flatten.each do |name|
      case name
      when Regexp then
        all_tasks.delete_if { |k,_| k =~ name }
      else
        all_tasks.delete(name)
      end
    end
  end

  # Removes the last action added to a task. Use this when two
  # libraries define the same task and you only want one of the
  # actions.
  #
  #   require 'hoe'
  #   require 'tasks/rails'
  #   Rake.undo("test") # rolls out rails' test task
  def self.undo(*names)
    names.each do |name|
      all_tasks[name].actions.delete_at(-1)
    end
  end
  
  class Task
    # Invokes the task named +task_name+ if the +module_name+ has been
    # defined. It is the mechanism for delegating commands out of the
    # core to modules specific for your application
    def self.invoke_if_defined(task_name, module_name, error_message = nil)
      module_value = Rake::RemoteTask.fetch(module_name, false)
      if module_value
        # require deletaged task file
        require File.join(Yad::LIBPATH, 'yad', 'tasks', module_name.to_s, module_value.to_s)
        Rake::Task[task_name].invoke
      elsif error_message
        raise ArgumentError, error_message
      end
    end
  end
end

# Declare a remote host and its roles. Equivalent to <tt>role</tt>,
# but shorter for multiple roles.
def host(host_name, *roles)
  Rake::RemoteTask.host(host_name, *roles)
end

# Copy a (usually generated) file to +remote_path+. Contents of block
# are copied to +remote_path+ and you may specify an optional
# base_name for the tempfile (aids in debugging).
def put(remote_path, base_name = File.baseename(remote_path))
  require 'tempfile'
  Tempfile.open base_name do |fp|
    fp.puts yield
    fp.flush
    rsync fp.path, remote_path
  end
end

# Declare a remote task that will execute on all hosts by default. To
# limit that task to specific roles, use:
#
#     remote_task :example, :arg1, :roles => [:app, :web] do
def remote_task(name, *args_options, &b)
  Rake::RemoteTask.remote_task(name, *args_options, &b)
end

# Declare a role and assign a remote host to it. Equivalent to the
# <tt>host</tt> method; provided for capistrano compatibility.
def role(role_name, host = nil, args = {})
  if block_given? then
    raise ArgumentError, 'host not allowed with block' unless host.nil?

    begin
      Rake::RemoteTask.current_roles << role_name
      yield
    ensure
      Rake::RemoteTask.current_roles.delete role_name
    end
  else
    raise ArgumentError, 'host required' if host.nil?
    Rake::RemoteTask.role role_name, host, args
  end
end

# Execute the given command on the <tt>target_host</tt> for the
# current task.
def run(*args, &b)
  Thread.current[:task].run(*args, &b)
end

# Rsync the given files to <tt>target_host</tt>.
def rsync(local, remote)
  Thread.current[:task].rsync(local, remote)
end

# run the command w/ sudo
def sudo(command)
  Thread.current[:task].sudo(command)
end

# Declare a variable called +name+ and assign it a value. A
# globally-visible method with the name of the variable is defined.
# If a block is given, it will be called when the variable is first
# accessed. Subsequent references to the variable will always return
# the same value. Raises <tt>ArgumentError</tt> if the +name+ would
# conflict with an existing method.
def set(name, val = nil, &b)
  Rake::RemoteTask.set(name, val, &b)
end

# Returns the name of the host that the current task is executing on.
# <tt>target_host</tt> can uniquely identify a particular task/host
# combination.
def target_host
  Thread.current[:task].target_host
end

if Gem::Version.new(RAKEVERSION) < Gem::Version.new('0.8') then
  class Rake::Task
    alias task_original_execute execute

    def execute(args = nil)
      task_original_execute
    end
  end
end
