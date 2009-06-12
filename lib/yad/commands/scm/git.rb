module Yad
  module Commands
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
        
      end # class Git
      
    end # module Scm
  end # module Commands
end # module Yad
