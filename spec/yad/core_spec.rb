require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Yad::Core do

  it "should build the setup command" do
    cmd = Yad::Core.build_setup_command('myapp', :umask => '02', :shared_subdirectories => %w(processing_files))
    cmd.should eql("umask 02 && mkdir -p myapp/releases myapp/scm myapp/shared myapp/shared/config myapp/shared/processing_files")
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

  it "should not build the rollback command if there are less than 2 releases" do
    cmd = Yad::Core.build_rollback_command('path/to/current/release', nil, 'path/to/latest/release')
    cmd.should eql("echo no previous release for rollback")
  end
  
  it "should build the rollback command if there are at lease 2 releases" do
    cmd = Yad::Core.build_rollback_command('path/to/current/release', 'path/to/previous/release', 'path/to/latest/release')
    cmd.should eql("rm -f path/to/current/release; ln -s path/to/previous/release path/to/current/release && rm -rf path/to/latest/release")
  end

  it "should not build the cleanup command when there are less than or equal to the max number of releases to keep" do
    cmd = Yad::Core.build_cleanup_command(5, 'path/to/releases', %w(release1 release2 release3 release4))
    cmd.should eql("echo keeping all releases")
    cmd = Yad::Core.build_cleanup_command(5, 'path/to/releases', %w(release1 release2 release3 release4 release5))
    cmd.should eql("echo keeping all releases")
  end

  it "should build the cleanup command when there are more than the max number of releases to keep" do
    cmd = Yad::Core.build_cleanup_command(5, 'path/to/releases', %w(release1 release2 release3 release4 release5 release6 release7))
    cmd.should eql("rm -rf path/to/releases/release1 path/to/releases/release2")
  end

  it "should build an empty files array for no files" do
    cmd = Yad::Core.build_files_array('')
    cmd.should eql([])
    cmd = Yad::Core.build_files_array(nil)
    cmd.should eql([])
  end
  
  it "should build the files array for a single file" do
    cmd = Yad::Core.build_files_array('file1')
    cmd.should eql(%w(file1))
  end

  it "should build the files array for multiple files" do
    cmd = Yad::Core.build_files_array('file1, file2,file3')
    cmd.should eql(%w(file1 file2 file3))
  end
  
end
