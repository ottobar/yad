namespace :yad do
  namespace :app do

    desc "Starts the application server"
    remote_task :start, :roles => :app do
      cmd = Yad::Commands::App::Passenger.build_start_command(current_release)
      run(cmd)
    end

  end
end
