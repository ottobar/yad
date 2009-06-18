require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Yad::Maintenance::SharedSystem do

  it "should build the turn on command" do
    cmd = Yad::Maintenance::SharedSystem.build_turn_on_command('path/to/shared/directory')
    cmd.should eql("cp -f path/to/shared/directory/config/maintenance.html path/to/shared/directory/system/")
  end

  it "should build the turn off command" do
    cmd = Yad::Maintenance::SharedSystem.build_turn_off_command('path/to/shared/directory')
    cmd.should eql("rm -f path/to/shared/directory/system/maintenance.html")
  end

end
