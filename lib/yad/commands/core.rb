module Yad
  module Commands
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
      
    end # class Core
      
  end # module Commands
end # module Yad
