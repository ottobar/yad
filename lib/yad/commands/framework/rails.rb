module Yad
  module Commands
    module Framework
      class Rails
        def self.build_setup_command(shared_directory, options = {})
          default_options = { :umask => '02' }
          options = default_options.merge(options)
          dirs = [File.join(shared_directory, "log"),
                  File.join(shared_directory, "pids"),
                  File.join(shared_directory, "system")
                 ]
          "umask #{options[:umask]} && mkdir -p #{dirs.join(' ')}"
        end

        def self.build_update_command(new_release_directory, shared_directory, options = {})
          default_options = { :app_env                        => 'production',
                              :framework_update_db_config_via => 'none' }
          options = default_options.merge(options)
          commands = ["rm -rf #{new_release_directory}/log #{new_release_directory}/public/system #{new_release_directory}/tmp/pids",
                      "mkdir -p #{new_release_directory}/tmp",
                      "ln -s #{shared_directory}/log #{new_release_directory}/log",
                      "ln -s #{shared_directory}/pids #{new_release_directory}/tmp/pids",
                      "ln -s #{shared_directory}/system #{new_release_directory}/public/system"
                     ]
          
          case options[:framework_update_db_config_via].to_sym
          when :copy
            commands << "cp -f #{new_release_directory}/config/database_#{options[:app_env]}.yml #{new_release_directory}/config/database.yml"  
          when :symlink
            commands << "ln -nfs #{shared_directory}/config/database.yml #{new_release_directory}/config/database.yml"
          end
          
          commands.join(" && ")
        end
        
      end # class Rails
    
    end # module Framework
  end # module Commands
end # module Yad
