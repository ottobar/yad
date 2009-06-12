namespace :yad do
  namespace :framework do

    desc "Performs additional setup needed for the framework"
    remote_task :setup, :roles => :app do
      options = Rake::RemoteTask.get_options_hash(:umask)
      cmd = Yad::Commands::Framework::Rails.build_setup_command(shared_path, options)
      run(cmd)
    end
    
    desc "Updates the framework configuration and working directories after a new release has been exported"
    remote_task :update, :roles => :app do
      options = Rake::RemoteTask.get_options_hash(:app_env, :framework_update_db_config_via)
      cmd = Yad::Commands::Framework::Rails.build_update_command(latest_release, shared_path, options)
      run(cmd)
    end
    
  end
end
