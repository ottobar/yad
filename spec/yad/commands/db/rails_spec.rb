require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

describe Yad::Commands::Db::Rails do

  it "should build the create db command" do
    cmd = Yad::Commands::Db::Rails.build_create_db_command('path/to/release', :app_env => 'production', :rake_cmd => 'rake')
    cmd.should eql("cd path/to/release; rake RAILS_ENV=production db:create")
  end

  it "should build the migrate db command" do
    cmd = Yad::Commands::Db::Rails.build_migrate_db_command('path/to/release', :app_env => 'production', :rake_cmd => 'rake', :migrate_args => 'MIGRATE=ARGS')
    cmd.should eql("cd path/to/release; rake RAILS_ENV=production db:migrate MIGRATE=ARGS")
  end
  
end
