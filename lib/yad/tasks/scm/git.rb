namespace :yad do
  namespace :scm do
    
    desc "Updates the source code on the application servers and exports it as the latest release"
    remote_task :update, :roles => :app do
      begin
        options = Rake::RemoteTask.get_options_hash(:revision, :enable_submodules)
        checkout_command = Yad::Commands::Scm::Git.build_checkout_command(repository, scm_path, options)
        export_command = Yad::Commands::Scm::Git.build_export_command(scm_path, release_path)
        cmd = Yad::Commands::Core.build_update_source_code_command(checkout_command, export_command, release_path)
        run(cmd)
      rescue => e
        cmd = Yad::Commands::Core.build_remove_directory_command(release_path)
        run(cmd)
        raise e
      end
    end
    
  end
end
