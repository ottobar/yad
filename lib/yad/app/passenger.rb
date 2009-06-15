module Yad
  module App
    class Passenger
      def self.build_start_command(release_directory)
        "touch #{release_directory}/tmp/restart.txt"
      end
      
       def self.define_tasks
         return if @tasks_already_defined
         @tasks_already_defined = true
         namespace :yad do
           namespace :app do

             desc "Starts the application server"
             remote_task :start, :roles => :app do
               cmd = Yad::App::Passenger.build_start_command(current_path)
               run(cmd)
             end

           end
         end
       end
       
    end # class Passenger
    
  end # module App
end # module Yad
