require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

describe Yad::Commands::Scm::Git do

  it "should build the default checkout command" do
    cmd = Yad::Commands::Scm::Git.build_checkout_command('ssh://some.domain.com/path/to/myapp.git', 'path/to/scm')
    cmd.should eql("([ -d path/to/scm/cached-copy/.git ] && echo 'Existing repository found' || git clone ssh://some.domain.com/path/to/myapp.git path/to/scm/cached-copy) && cd path/to/scm/cached-copy && git fetch && git reset --hard origin/master && git submodule -q init && git submodule -q update")
  end

  it "should build the checkout command with revision" do
    cmd = Yad::Commands::Scm::Git.build_checkout_command('ssh://some.domain.com/path/to/myapp.git', 'path/to/scm', :revision => 'origin/staging')
    cmd.should eql("([ -d path/to/scm/cached-copy/.git ] && echo 'Existing repository found' || git clone ssh://some.domain.com/path/to/myapp.git path/to/scm/cached-copy) && cd path/to/scm/cached-copy && git fetch && git reset --hard origin/staging && git submodule -q init && git submodule -q update")
  end
  
  it "should build the checkout command without submodules" do
    cmd = Yad::Commands::Scm::Git.build_checkout_command('ssh://some.domain.com/path/to/myapp.git',  'path/to/scm', :enable_submodules => false)
    cmd.should eql("([ -d path/to/scm/cached-copy/.git ] && echo 'Existing repository found' || git clone ssh://some.domain.com/path/to/myapp.git path/to/scm/cached-copy) && cd path/to/scm/cached-copy && git fetch && git reset --hard origin/master")
  end
  
  it "should build the export command" do
    cmd = Yad::Commands::Scm::Git.build_export_command('path/to/source', 'path/to/destination')
    cmd.should eql("mkdir -p path/to/destination && rsync -a -f '- .git' path/to/source/cached-copy/ path/to/destination")
  end

  it "should build the inline revision identifier command" do
    cmd = Yad::Commands::Scm::Git.build_inline_revision_identifier_command('path/to/scm')
    cmd.should eql("`cd path/to/scm/cached-copy && git rev-parse origin/master`")
  end

end
