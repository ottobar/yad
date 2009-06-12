module Yad
  module Commands
    module App
      class Passenger
        def self.build_start_command(release_directory)
          "touch #{release_directory}/tmp/restart.txt"
        end
        
      end # class Passenger
    
    end # module App
  end # module Commands
end # module Yad
