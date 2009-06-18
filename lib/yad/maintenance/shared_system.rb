module Yad
  module Maintenance
    class SharedSystem
      def self.build_turn_on_command(shared_directory, options = {})
        "cp -f #{shared_directory}/config/maintenance.html #{shared_directory}/system/"
      end
      
      def self.build_turn_off_command(shared_directory, options = {})
        "rm -f #{shared_directory}/system/maintenance.html"
      end
      
      def self.define_tasks
        return if @tasks_already_defined
        @tasks_already_defined = true
        namespace :yad do
          namespace :maintenance do
            
            desc "Turns on the maintenance page for the application"
            remote_task :turn_on, :roles => :web do
              cmd = Yad::Maintenance::SharedSystem.build_turn_on_command(shared_path)
              run(cmd)
              puts("maintenance page turned on for #{target_host}")
            end

             desc "Turns off the maintenance page for the application"
            remote_task :turn_off, :roles => :web do
              cmd = Yad::Maintenance::SharedSystem.build_turn_off_command(shared_path)
              run(cmd)
              puts("maintenance page turned off for #{target_host}")
            end
            
          end
        end
      end

    end # class Rails
    
  end # module Maintenance
end # module Yad
