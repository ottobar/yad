module Yad
  module Db
    class Rails
      def self.build_create_db_command(release_directory, options = {})
        default_options = { :app_env  => 'production',
          :rake_cmd => 'rake'
        }
        options = default_options.merge(options)
        "cd #{release_directory}; #{options[:rake_cmd]} RAILS_ENV=#{options[:app_env]} db:create"
      end

      def self.build_migrate_db_command(release_directory, options = {})
        default_options = { :app_env      => 'production',
          :rake_cmd     => 'rake',
          :migrate_args => '',
        }
        options = default_options.merge(options)
        "cd #{release_directory}; #{options[:rake_cmd]} RAILS_ENV=#{options[:app_env]} db:migrate #{options[:migrate_args]}"
      end

      def self.define_tasks
        return if @tasks_already_defined
        @tasks_already_defined = true
        namespace :yad do
          namespace :db do

            desc "Creates the database for the application"
            remote_task :create, :roles => :app do
              break unless target_host == Rake::RemoteTask.hosts_for(:app).first
              options = Rake::RemoteTask.get_options_hash(:app_env, :rake_cmd)
              cmd = Yad::Db::Rails.build_create_db_command(current_path, options)
              run(cmd)
              puts("database created")
            end
            
            desc "Runs migrations on the database"
            remote_task :migrate, :roles => :app do
              break unless target_host == Rake::RemoteTask.hosts_for(:app).first
              options = Rake::RemoteTask.get_options_hash(:app_env, :rake_cmd, :migrate_args)
              target = Rake::RemoteTask.fetch(:migrate_target, false)
              if target
                target_directory = case target.to_sym
                                   when :current then current_path
                                   when :latest  then latest_release
                                   else raise ArgumentError, "unknown migration target #{target.inspect}"
                                   end
              else
                target_directory = latest_release
              end
              cmd = Yad::Db::Rails.build_migrate_db_command(target_directory, options)
              run(cmd)
              puts("database migrations completed")
            end
            
          end
        end
      end
      
    end # class Rails
    
  end # module Db
end # module Yad
