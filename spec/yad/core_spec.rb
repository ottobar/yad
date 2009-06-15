require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Yad::Core do

  it "should build the setup command" do
    cmd = Yad::Core.build_setup_command('myapp', :umask => '02', :shared_subdirectories => %w(config))
    cmd.should eql("umask 02 && mkdir -p myapp/releases myapp/scm myapp/shared myapp/shared/config")
  end

  it "should build the update source code command" do
    cmd = Yad::Core.build_update_source_code_command('my checkout command', 'my export command', 'path/to/new/release')
    cmd.should eql("my checkout command && my export command && chmod -R g+w path/to/new/release")
  end

  it "should build the update symlink command" do
    cmd = Yad::Core.build_update_symlink_command('path/to/current/release', 'path/to/new/release')
    cmd.should eql("rm -f path/to/current/release && ln -s path/to/new/release path/to/current/release")
  end

  it "should build the remove directory command" do
    cmd = Yad::Core.build_remove_directory_command('path/to/directory')
    cmd.should eql("rm -rf path/to/directory")
  end
  
  it "should build the revision log command" do
    cmd = Yad::Core.build_revision_log_command('timestamp', 'inline_revision_identifier_command', 'path/to/new/release', 'path/to/deployment')
    cmd.should eql("echo timestamp $USER inline_revision_identifier_command #{File.basename('path/to/new/release')} >> path/to/deployment/revisions.log")
  end

  it "should build the rollback command"
  
end
