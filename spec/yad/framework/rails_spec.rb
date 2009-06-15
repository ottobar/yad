require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Yad::Framework::Rails do
  
  it "should build the setup command" do
    cmd = Yad::Framework::Rails.build_setup_command('path/to/shared/directory', :umask => '02')
    cmd.should eql("umask 02 && mkdir -p path/to/shared/directory/log path/to/shared/directory/pids path/to/shared/directory/system")
  end

  it "should build the update command" do
    cmd = Yad::Framework::Rails.build_update_command('path/to/new/release', 'path/to/shared/directory', :app_env => 'production', :framework_update_db_config_via => 'none')
    cmd.should eql("rm -rf path/to/new/release/log path/to/new/release/public/system path/to/new/release/tmp/pids && mkdir -p path/to/new/release/tmp && ln -s path/to/shared/directory/log path/to/new/release/log && ln -s path/to/shared/directory/pids path/to/new/release/tmp/pids && ln -s path/to/shared/directory/system path/to/new/release/public/system")
  end
    
  it "should build the update command with db config setup via copy" do
    cmd = Yad::Framework::Rails.build_update_command('path/to/new/release', 'path/to/shared/directory', :app_env => 'production', :framework_update_db_config_via => 'copy')
    cmd.should eql("rm -rf path/to/new/release/log path/to/new/release/public/system path/to/new/release/tmp/pids && mkdir -p path/to/new/release/tmp && ln -s path/to/shared/directory/log path/to/new/release/log && ln -s path/to/shared/directory/pids path/to/new/release/tmp/pids && ln -s path/to/shared/directory/system path/to/new/release/public/system && cp -f path/to/new/release/config/database_production.yml path/to/new/release/config/database.yml")
  end

  it "should build the update command with db config setup via symlink" do
    cmd = Yad::Framework::Rails.build_update_command('path/to/new/release', 'path/to/shared/directory', :app_env => 'production', :framework_update_db_config_via => 'symlink')
    cmd.should eql("rm -rf path/to/new/release/log path/to/new/release/public/system path/to/new/release/tmp/pids && mkdir -p path/to/new/release/tmp && ln -s path/to/shared/directory/log path/to/new/release/log && ln -s path/to/shared/directory/pids path/to/new/release/tmp/pids && ln -s path/to/shared/directory/system path/to/new/release/public/system && ln -nfs path/to/shared/directory/config/database.yml path/to/new/release/config/database.yml")
  end

end
