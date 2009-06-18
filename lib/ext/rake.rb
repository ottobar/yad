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
        # define delegated tasks
        eval("Yad::#{module_name.to_s.classify}::#{module_value.to_s.classify}.define_tasks")
        Rake::Task[task_name].invoke
      elsif error_message
        raise ArgumentError, error_message
      end
    end
  end
end

if Gem::Version.new(RAKEVERSION) < Gem::Version.new('0.8') then
  class Rake::Task
    alias task_original_execute execute

    def execute(args = nil)
      task_original_execute
    end
  end
end
