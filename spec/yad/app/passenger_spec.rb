require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Yad::App::Passenger do

  it "should build the start command" do
    cmd = Yad::App::Passenger.build_start_command('path/to/release')
    cmd.should eql("touch path/to/release/tmp/restart.txt")
  end
  
end
