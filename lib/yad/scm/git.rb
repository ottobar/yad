module Yad
  module Scm
    class Git
      def self.build_checkout_command(repository, destination_directory, options = {})
        default_options = { :revision => 'origin/master', :enable_submodules => true }
        options = default_options.merge(options)

        commands = ["([ -d #{destination_directory}/cached-copy/.git ] && echo 'Existing repository found' || git clone #{repository} #{destination_directory}/cached-copy)",
                    "cd #{destination_directory}/cached-copy",
                    "git fetch",
                    "git reset --hard #{options[:revision]}"
                   ]

        if options[:enable_submodules]
          commands << [ "git submodule -q init",
                        "git submodule -q update"
                      ]
        end
        commands.join(" && ")
      end

      def self.build_export_command(source_directory, destination_directory)
        "mkdir -p #{destination_directory} && rsync -a -f '- .git' #{source_directory}/cached-copy/ #{destination_directory}"
      end
      
      def self.build_inline_revision_identifier_command(scm_directory, options = {})
        default_options = { :revision => 'origin/master' }
        options = default_options.merge(options)
        "`cd #{scm_directory}/cached-copy && git rev-parse #{options[:revision]}`"
      end

      def self.define_tasks
        return if @tasks_already_defined
        @tasks_already_defined = true
        namespace :yad do
          namespace :scm do
            
            desc "Updates the source code on the application servers and exports it as the latest release"
            remote_task :update, :roles => :app do
              begin
                options = Rake::RemoteTask.get_options_hash(:revision, :enable_submodules)
                checkout_command = Yad::Scm::Git.build_checkout_command(repository, scm_path, options)
                export_command = Yad::Scm::Git.build_export_command(scm_path, release_path)
                cmd = Yad::Core.build_update_source_code_command(checkout_command, export_command, release_path)
                run(cmd)
                puts("source code updated on #{target_host}")
              rescue => e
                cmd = Yad::Core.build_remove_directory_command(release_path)
                run(cmd)
                raise e
              end
            end
            
          end
        end

      end
      
    end # class Git
    
  end # module Scm
end # module Yad
