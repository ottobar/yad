module Yad
  class Core
    def self.build_setup_command(deployment_directory, options = {})
      default_options = { :umask => '02',
        :shared_subdirectories => [] }
      
      options = default_options.merge(options)
      dirs = [File.join(deployment_directory, "releases"),
              File.join(deployment_directory, "scm"),
              File.join(deployment_directory, "shared"),
              File.join(deployment_directory, "shared", "config")
             ]
      options[:shared_subdirectories].each do |subdirectory|
        dirs << File.join(deployment_directory, "shared", subdirectory) unless subdirectory == 'config'
      end
      "umask #{options[:umask]} && mkdir -p #{dirs.join(' ')}"
    end

    def self.build_update_source_code_command(checkout_command, export_command, new_release_directory)
      [checkout_command,
       export_command,
       "chmod -R g+w #{new_release_directory}"
      ].join(" && ")
    end
    
    def self.build_remove_directory_command(directory_to_remove)
      "rm -rf #{directory_to_remove}"
    end

    def self.build_files_array(delimited_file_names)
      return [] unless delimited_file_names
      files = delimited_file_names.split(",").map { |f| f.strip }.flatten
      files = files.reject { |f| File.directory?(f) || File.basename(f)[0] == ?. }
      files
    end

    def self.build_update_symlink_command(current_release_symlink, new_release_directory)
      "rm -f #{current_release_symlink} && ln -s #{new_release_directory} #{current_release_symlink}"
    end
    
    def self.build_revision_log_command(timestamp, inline_revision_identifier_command, new_release_directory, deployment_directory)
      "echo #{timestamp} $USER #{inline_revision_identifier_command} #{File.basename(new_release_directory)} >> #{deployment_directory}/revisions.log"
    end

    def self.build_cleanup_command(max_release_count, releases_directory, all_releases)
      if all_releases.length <= max_release_count
        ""
      else
        releases_to_remove = (all_releases - all_releases.last(max_release_count)).map { |release| File.join(releases_directory, release) }.join(" ")
        "rm -rf #{releases_to_remove}"
      end
    end

    def self.build_rollback_command(current_release_symlink, previous_release_directory, latest_release_directory)
      if previous_release_directory.nil? || previous_release_directory == latest_release_directory || latest_release_directory.nil?
        ""
      else
        "rm -f #{current_release_symlink}; ln -s #{previous_release_directory} #{current_release_symlink} && rm -rf #{latest_release_directory}"
      end
    end
    
    def self.define_tasks
      return if @tasks_already_defined
      @tasks_already_defined = true
      namespace :yad do
        
        desc "Prepares one or more servers for deployment"
        remote_task :setup do
          Rake::Task['yad:core:setup_deployment'].invoke
          Rake::Task.invoke_if_defined('yad:framework:setup', :framework)
        end
        
        desc "Copies files to the shared/config directory using FILES=a,b,c (e.g. rake vlad:upload_config_files FILES=config/database.yml,config/maintenance.html)"
        remote_task :upload_config_files do
          files = Yad::Core.build_files_array(ENV["FILES"])
          if files.empty?
            puts("Please specify at least one file to upload (via the FILES environment variable)")
          else
            files.each do |file|
              rsync(file, "#{target_host}:#{File.join(shared_config_path, File.basename(file))}")
            end
            puts("uploaded #{files.inspect} to #{target_host}")
          end
        end
        
        desc "Creates the database for the application"
        remote_task :create_db, :roles => :app do
          Rake::Task.invoke_if_defined('yad:db:create', :db, "Please specify the database delegate via the :db variable")
        end
        
        desc "Updates the application servers to the latest version"
        remote_task :update, :roles => :app do
          Rake::Task.invoke_if_defined('yad:scm:update', :scm)
          Rake::Task.invoke_if_defined('yad:framework:update', :framework)
          Rake::Task['yad:core:update_symlink'].invoke
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
        
        desc "Rolls back to the previous release, but DOES NOT restart the application"
        remote_task :rollback do
          cmd = Yad::Core.build_rollback_command(current_path, previous_release, latest_release)
          if cmd.length == 0
            puts("could not rollback the code because there is no previous release")
          else
            run(cmd)
            puts("rolled back to #{File.basename(previous_release)} on #{target_host}")
          end
        end
        
        desc "Cleans up old releases"
        remote_task :cleanup do
          cmd = Yad::Core.build_cleanup_command(keep_releases, releases_path, releases)
          run(cmd)
          puts("old releases cleaned up on #{target_host}")
        end

        remote_task :invoke do
          # TODO:
        end
        
        namespace :core do

          remote_task :setup_deployment, :roles => :app do
            options = Rake::RemoteTask.get_options_hash(:umask, :shared_subdirectories)
            cmd = Yad::Core.build_setup_command(deploy_to, options)
            run(cmd)
            puts("Yad set up on #{target_host}")
          end

          remote_task :update_symlink, :roles => :app do
            begin
              symlinked = false
              cmd = Yad::Core.build_update_symlink_command(current_path, release_path)
              run(cmd)
              puts("'current' symlink updated on #{target_host}")
              symlinked = true
              scm_value = Rake::RemoteTask.fetch(:scm, false)
              if scm_value
                scm_class = eval("Yad::Scm::#{scm_value.to_s.classify}")
                options = Rake::RemoteTask.get_options_hash(:revision)
                inline_command = scm_class.build_inline_revision_identifier_command(scm_path, options)
              else
                inline_command = 'none'
              end
              cmd = Yad::Core.build_revision_log_command(Time.now.utc.strftime("%Y%m%d%H%M.%S"), inline_command, release_path, deploy_to)
              run(cmd)
            rescue => e
              if releases.length > 1 && symlinked then
                cmd = Yad::Core.build_update_symlink_command(current_path, previous_release)
                run(cmd)
              end
              cmd = Yad::Core.build_remove_directory_command(release_path)
              run(cmd)
              raise e
            end
          end
          
        end

      end
    end
    
  end # class Core
  
end # module Yad
