require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Yad::Web::Apache do

  it "should build the start command with an alternate apache command" do
    cmd = Yad::Web::Apache.build_start_command(:apache_command => 'apache2ctl')
    cmd.should eql("apache2ctl start")
  end

  it "should build the start command" do
    cmd = Yad::Web::Apache.build_start_command
    cmd.should eql("apachectl start")
  end

  it "should build the restart command" do
    cmd = Yad::Web::Apache.build_restart_command
    cmd.should eql("apachectl restart")
  end

  it "should build the stop command" do
    cmd = Yad::Web::Apache.build_stop_command
    cmd.should eql("apachectl stop")
  end

end
