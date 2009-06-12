module Yad
  module Commands
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
        
      end # class Rails
    
    end # module Db
  end # module Commands
end # module Yad
