module Yad
  module Web
    class Apache
      def self.build_start_command(options = {})
        default_options = { :apache_command => 'apachectl' }
        options = default_options.merge(options)
        "#{options[:apache_command]} start"
      end

      def self.build_stop_command(options = {})
        default_options = { :apache_command => 'apachectl' }
        options = default_options.merge(options)
        "#{options[:apache_command]} stop"
      end

      def self.build_restart_command(options = {})
        default_options = { :apache_command => 'apachectl' }
        options = default_options.merge(options)
        "#{options[:apache_command]} restart"
      end
      
      def self.define_tasks
        return if @tasks_already_defined
        @tasks_already_defined = true
        namespace :yad do
          namespace :web do
            
            desc "Starts the web server"
            remote_task :start, :roles => :web do
              options = Rake::RemoteTask.get_options_hash(:apache_command)
              cmd = Yad::Web::Apache.build_start_command(options)
              use_sudo_for_apache = Rake::RemoteTask.fetch(:use_sudo_for_apache, true)
              if use_sudo_for_apache
                sudo(cmd)
              else
                run(cmd)
              end
              puts("Apache started on #{target_host}")
            end

            desc "Stops the web server"
            remote_task :stop, :roles => :web do
              options = Rake::RemoteTask.get_options_hash(:apache_command)
              cmd = Yad::Web::Apache.build_stop_command(options)
              use_sudo_for_apache = Rake::RemoteTask.fetch(:use_sudo_for_apache, true)
              if use_sudo_for_apache
                sudo(cmd)
              else
                run(cmd)
              end
              puts("Apache stopped on #{target_host}")
            end
            
          end
        end

      end
      
    end # class Apache
    
  end # module Web
end # module Yad
