namespace :yad do
  namespace :db do

    desc "Creates the database for the application"
    remote_task :create, :roles => :app do
      break unless target_host == Rake::RemoteTask.hosts_for(:app).first
      options = Rake::RemoteTask.get_options_hash(:app_env, :rake_cmd)
      cmd = Yad::Commands::Db::Rails.build_create_db_command(current_path, options)
      run(cmd)
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
      cmd = Yad::Commands::Db::Rails.build_migrate_db_command(target_directory, options)
      run(cmd)
    end
    
  end
end
