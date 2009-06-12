namespace :yad do
  
  desc "Prepares one or more servers for deployment"
  remote_task :setup do
    Rake::Task['yad:core:setup_deployment'].invoke
    Rake::Task.invoke_if_defined('yad:framework:setup', :framework)
  end

  remote_task :upload_config do
    # TODO:
  end
  
  desc "Creates the database for the application"
  remote_task :create_db, :roles => :app do
    Rake::Task.invoke_if_defined('yad:db:create', :db, "Please specify the database delegate via the :db variable")
  end
  
  desc "Updates the application servers to the latest version"
  remote_task :update, :roles => :app do
    Rake::Task.invoke_if_defined('yad:scm:update', :scm)
    Rake::Task['yad:core:update_symlink'].invoke
    Rake::Task.invoke_if_defined('yad:framework:update', :framework)
  end

  desc "Runs migrations for the database for the application"
  remote_task :migrate_db, :roles => :app do
    Rake::Task.invoke_if_defined('yad:db:migrate', :db, "Please specify the database delegate via the :db variable")
  end
  
  desc "Starts the application server"
  remote_task :start_app, :roles => :app do
    Rake::Task.invoke_if_defined('yad:app:start', :app, "Please specify the app delegate via the :app variable")
  end

  remote_task :start_web, :roles => :web do
    # TODO:
  end

  remote_task :stop_web, :roles => :web do
    # TODO:
  end
  
  desc "Stops the application server"
  remote_task :stop_app, :roles => :app do
    Rake::Task.invoke_if_defined('yad:app:stop', :app, "Please specify the app delegate via the :app variable")
  end

  remote_task :rollback do
    # TODO:
  end

  remote_task :cleanup do
    # TODO:
  end

  remote_task :invoke do
    # TODO:
  end
  
  namespace :core do

    remote_task :setup_deployment, :roles => :app do
      options = Rake::RemoteTask.get_options_hash(:umask, :shared_subdirectories)
      cmd = Yad::Commands::Core.build_setup_command(deploy_to, options)
      run(cmd)
    end

    remote_task :update_symlink, :roles => :app do
      begin
        symlinked = false
        cmd = Yad::Commands::Core.build_update_symlink_command(current_path, release_path)
        run(cmd)
        symlinked = true
        scm_value = Rake::RemoteTask.fetch(:scm, false)
        if scm_value
          scm_class = eval("Yad::Commands::Scm::#{scm_value.to_s.classify}")
          options = Rake::RemoteTask.get_options_hash(:revision)
          inline_command = scm_class.build_inline_revision_identifier_command(scm_path, options)
        else
          inline_command = 'none'
        end
        cmd = Yad::Commands::Core.build_revision_log_command(Time.now.utc.strftime("%Y%m%d%H%M.%S"), inline_command, release_path, deploy_to)
        run(cmd)
      rescue => e
        if releases.length > 1 && symlinked then
          cmd = Yad::Commands::Core.build_update_symlink_command(current_path, previous_release)
          run(cmd)
        end
        cmd = Yad::Commands::Core.build_remove_directory_command(release_path)
        run(cmd)
        raise e
      end
    end
    
  end

end
