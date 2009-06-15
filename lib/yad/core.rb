module Yad
  class Core
    def self.build_setup_command(deployment_directory, options = {})
      default_options = { :umask => '02',
        :shared_subdirectories => ['config'] }
      
      options = default_options.merge(options)
      dirs = [File.join(deployment_directory, "releases"),
              File.join(deployment_directory, "scm"),
              File.join(deployment_directory, "shared")
             ]
      options[:shared_subdirectories].each do |subdirectory|
        dirs << File.join(deployment_directory, "shared", subdirectory)
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

    def self.build_update_symlink_command(current_release_symlink, new_release_directory)
      "rm -f #{current_release_symlink} && ln -s #{new_release_directory} #{current_release_symlink}"
    end
    
    def self.build_revision_log_command(timestamp, inline_revision_identifier_command, new_release_directory, deployment_directory)
      "echo #{timestamp} $USER #{inline_revision_identifier_command} #{File.basename(new_release_directory)} >> #{deployment_directory}/revisions.log"
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
            cmd = Yad::Core.build_setup_command(deploy_to, options)
            run(cmd)
          end

          remote_task :update_symlink, :roles => :app do
            begin
              symlinked = false
              cmd = Yad::Core.build_update_symlink_command(current_path, release_path)
              run(cmd)
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
