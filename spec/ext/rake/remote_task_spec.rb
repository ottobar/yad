require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe Rake::RemoteTask do
  def create_example_task(options = {})
    task = Rake::RemoteTask.remote_task(:test_task, options)
    task.commands = []
    task.output = []
    task.error = []
    task.action = nil
    task
  end

  def capture_output
    require 'stringio'
    orig_stdout = $stdout.dup
    orig_stderr = $stderr.dup
    captured_stdout = StringIO.new
    captured_stderr = StringIO.new
    $stdout = captured_stdout
    $stderr = captured_stderr
    yield
    captured_stdout.rewind
    captured_stderr.rewind
    return captured_stdout, captured_stderr
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end

  it "should list all remote hosts" do
    set_example_hosts
    Rake::RemoteTask.all_hosts.should eql(%w[app.example.com db.example.com])
  end

  it "should fetch variables that have been set" do
    set :foo, 5
    Rake::RemoteTask.fetch(:foo).should eql(5)
  end

  it "should fetch the given default when a variable is not set" do
    Rake::RemoteTask.fetch(:not_here, 5).should eql(5)
  end

  it "should assign multiple roles to one remote host" do
    Rake::RemoteTask.host "test.example.com", :app, :db
    Rake::RemoteTask.roles[:app].should == { "test.example.com" => {} }
    Rake::RemoteTask.roles[:db].should == { "test.example.com" => {} }
  end

  it "should error when the host name is invalid" do
    lambda { Rake::RemoteTask.host nil, :web }.should raise_error(ArgumentError)
  end

  it "should assign multiple roles to multiple remote hosts" do
    Rake::RemoteTask.host "test.example.com", :app, :db
    Rake::RemoteTask.host "yarr.example.com", :app, :db, :no_release => true
 
    expected = {
      "test.example.com" => {},
      "yarr.example.com" => {:no_release => true}
    }
    
    Rake::RemoteTask.roles[:app].should == expected
    Rake::RemoteTask.roles[:db].should == expected
    Rake::RemoteTask.roles[:app]["test.example.com"].object_id.should_not eql(Rake::RemoteTask.roles[:db]["test.example.com"].object_id)
  end

  it "should get remote hosts for an array of roles" do
    set_example_hosts
    Rake::RemoteTask.hosts_for([:app, :db]).should eql(%w[app.example.com db.example.com])
  end

  it "should get remote hosts for one role" do
    set_example_hosts
    Rake::RemoteTask.host "app2.example.com", :app
    Rake::RemoteTask.hosts_for(:app).should eql(%w[app.example.com app2.example.com])
  end

  it "should get remote hosts for multiple roles" do
    set_example_hosts
    Rake::RemoteTask.hosts_for(:app, :db).should eql(%w[app.example.com db.example.com])
  end

  it "should get a unique list of remote hosts for given roles" do
    set_example_hosts
    Rake::RemoteTask.host "app.example.com", :web
    Rake::RemoteTask.hosts_for(:app, :db, :web).should eql(%w[app.example.com db.example.com])
  end

  it "should not set defaults for required configuration variables" do
    Rake::RemoteTask.set_defaults
    lambda { Rake::RemoteTask.repository }.should raise_error(Rake::RemoteTask::ConfigurationError)
    lambda { Rake::RemoteTask.deploy_to }.should raise_error(Rake::RemoteTask::ConfigurationError)
    lambda { Rake::RemoteTask.domain }.should raise_error(Rake::RemoteTask::ConfigurationError)
  end

  it "should assign a role for one remote host" do
    Rake::RemoteTask.role :app, "test.example.com"
    Rake::RemoteTask.roles[:app].should == { "test.example.com" => {} }
  end
  
  it "should assign a role for multiple remote hosts" do
    Rake::RemoteTask.role :app, "test.example.com", :primary => true
    Rake::RemoteTask.role :db, "yarr.example.com", :no_release => true
    Rake::RemoteTask.roles[:db].should == { "yarr.example.com" => { :no_release => true } }
    Rake::RemoteTask.roles[:app].should == { "test.example.com" => { :primary => true } }
  end

  it "should increase the number of tasks when created" do
    task = Rake::RemoteTask.remote_task(:test_task) { 5 }
    Rake.application.tasks.size.should eql(@task_count + 1)
  end

  it "should assign an empty set of roles if none are supplied" do
    task = Rake::RemoteTask.remote_task(:test_task) { 5 }
    task.options.should == { :roles => [] }
  end

  it "should assign all remote hosts to a task by default" do
    set_example_hosts
    task = Rake::RemoteTask.remote_task(:test_task) { 5 }
    task.target_hosts.should eql(%w[app.example.com db.example.com])
  end

  it "should override hosts from environment" do
    old_env_hosts = ENV["HOSTS"]
    ENV["HOSTS"] = 'other1.example.com,   other2.example.com'
    set_example_hosts
    task = Rake::RemoteTask.remote_task(:test_task) { 5 }
    task.target_hosts.should eql(%w[other1.example.com other2.example.com])
    ENV["HOSTS"] = old_env_hosts
  end

  it "should have access set variables within task body" do
    set(:some_variable, 5)
    Rake::RemoteTask.host 'www.example.com', :app
    Rake::RemoteTask.remote_task(:some_task) do $some_task_result = some_variable end
    Rake::Task['some_task'].execute nil
    Rake::RemoteTask.fetch(:some_variable).should eql($some_task_result)
  end

  it "should assign roles when creating a task" do
    task = Rake::RemoteTask.remote_task :test_task, :roles => [:app, :db] do
      fail "should not run"
    end
    task.options.should == { :roles => [:app, :db] }
  end

  it "should allow hosts to be assigned to a role after a task for a role has been created" do
    task = Rake::RemoteTask.remote_task :test_task, :roles => :web do 5 end
    Rake::RemoteTask.host 'www.example.com', :web
    task.target_hosts.should eql(%w[www.example.com])
  end

  it "should allow for roles to be overridden" do
    host "db1", :db
    host "db2", :db
    host "db3", :db
    host "master", :master_db
 
    remote_task(:migrate_the_db, :roles => [:db]) { fail "bad!" }
    task = Rake::Task["migrate_the_db"]
    task.target_hosts.should eql(%w[db1 db2 db3])
 
    task.options[:roles] = :master_db
    task.target_hosts.should eql(%w[master])
 
    task.options[:roles] = [:master_db]
    task.target_hosts.should eql(%w[master])
  end

  it "should set variables" do
    set :test, 5
    Rake::RemoteTask.test.should eql(5)
  end

  it "should do lazy evaluation of set blocks" do
    set(:test) { fail "lose" }
    lambda { Rake::RemoteTask.test }.should raise_error(RuntimeError)
  end

  it "should evaluate a set block the first time" do
    x = 1
    set(:test) { x += 2 }
    Rake::RemoteTask.test.should eql(3)
    Rake::RemoteTask.test.should eql(3)
  end

  it "should have access to set variables within set blocks" do
    Rake::RemoteTask.instance_eval do
      set(:var_one) { var_two }
      set(:var_two) { var_three }
      set(:var_three) { 5 }
    end
    
    Rake::RemoteTask.var_one.should eql(5)
  end

  it "should error when a value and a block is supplied with set" do
    lambda { set(:test, 5) { 6 } }.should raise_error(ArgumentError, "cannot provide both a value and a block")
  end

  it "should allow a variable to be set to nil" do
    set(:test, nil)
    Rake::RemoteTask.test.should be_nil
  end

  it "should not allow variables with reserved names to be set" do
    $TESTING = false
    lambda { set(:all_hosts, []) }.should raise_error(ArgumentError, "cannot set reserved name: 'all_hosts'")
    $TESTING = true
  end
  
  it "should allow a variable to be set to false" do
    set(:can_set_nil, nil)
    set(:lies_are, false)

    Rake::RemoteTask.can_set_nil.should be_nil
    Rake::RemoteTask.lies_are.should be_false
  end

  it "should fetch false as a default for a variable" do
    Rake::RemoteTask.fetch(:unknown, false).should be_false
  end
  
  it "should be enhanced with prerequisites and actions when it has been created with a body" do
    set_example_hosts
    body = Proc.new { 5 }
    task = Rake::RemoteTask.remote_task(:some_task => :foo, &body)
    action = Rake::RemoteTask::Action.new(task, body)
    task.remote_actions.should == [action]
    action.task.should eql(task)
    task.prerequisites.should eql(["foo"])
  end

  it "should not be enhanced with prerequisites or actions when it has been created without a body" do
    set_example_hosts
    task = create_example_task
    task.remote_actions.should be_empty
    task.prerequisites.should be_empty
  end

  it "should execute on all remote hosts when no role is given" do
    set_example_hosts
    set :some_variable, 1
    x = 5
    task = Rake::RemoteTask.remote_task(:some_task) { x += some_variable }
    task.execute nil
    task.some_variable.should eql(1)
    x.should eql(7)
  end
  
  it "should allow variables to be set inside of the body" do
    host "app.example.com", :app
    task = Rake::RemoteTask.remote_task(:target_task) { set(:test_target_host, target_host) }
    task.execute nil
    Rake::RemoteTask.fetch(:test_target_host).should eql("app.example.com")
  end

  it "should not excute with no remote hosts set" do
    Rake::RemoteTask.host "app.example.com", :app
    task = Rake::RemoteTask.remote_task(:flunk, :roles => :db) { fail "should not have run" }
    lambda { task.execute nil }.should raise_error(Rake::RemoteTask::ConfigurationError,
                                                   "No target hosts specified on task flunk for roles [:db]")
  end

  it "should not execute with no remote hosts for a given role" do
    task = Rake::RemoteTask.remote_task(:flunk, :roles => :junk) { fail "should not have run" }
    lambda { task.execute nil }.should raise_error(Rake::RemoteTask::ConfigurationError,
                                                   "No target hosts specified on task flunk for roles [:junk]")
  end

  it "should execute on remote hosts with a given role" do
    set_example_hosts
    set :some_variable, 1
    x = 5
    task = Rake::RemoteTask.remote_task(:some_task, :roles => :db) { x += some_variable }
    task.execute nil
    task.some_variable.should eql(1)
    x.should eql(6)
  end

  it "should build rsync commands" do
    task = create_example_task
    task.rsync 'localfile', 'app.example.com:remotefile'
    task.commands.size.should eql(1)
    task.commands.first.should eql(%w[rsync -azP --delete localfile app.example.com:remotefile])
  end

  it "should error when an rsync command fails" do
    task = create_example_task
    task.action = lambda { false }
    lambda { task.rsync 'local', 'app.example.com:remote' }.should raise_error(Rake::RemoteTask::CommandFailedError,
                                                                              "execution failed: rsync -azP --delete local app.example.com:remote")
  end
  
  it "should build get commands" do
    task = create_example_task
    task.target_host = 'app.example.com'
    lambda { task.get('tmp', 'remote1', 'remote2') }.should_not raise_error
    task.commands.size.should eql(1)
    task.commands.first.should eql(%w[rsync -azP --delete app.example.com:remote1 app.example.com:remote2 tmp])
  end
    
  it "should build put commands" do
    task = create_example_task
    task.target_host = 'app.example.com'
    lambda { task.put('dest') { 'whatever' } }.should_not raise_error
    task.commands.size.should eql(1)
    task.commands.first[3] = 'some_temp_file_name'
    task.commands.first.should eql( %w[rsync -azP --delete some_temp_file_name app.example.com:dest])
  end

  it "should run remote commands" do
    task = create_example_task
    task.output << "file1\nfile2\n"
    task.target_host = "app.example.com"
    result = nil
 
    out, err = capture_output do
      result = task.run("ls")
    end
 
    task.commands.size.should eql(1)
    task.commands.first.should eql(["ssh", "app.example.com", "ls"])

    result.should eql("file1\nfile2\n")
    out.read.should eql("file1\nfile2\n")
    err.read.should eql('')
  end

  it "should error when a remote command fails" do
    set_example_hosts
    task = create_example_task
    task.input = StringIO.new "file1\nfile2\n"
    task.target_host =  'app.example.com'
    task.action = lambda { 1 }
    lambda { task.run("ls") }.should raise_error(Rake::RemoteTask::CommandFailedError,
                                                 "execution failed with status 1: ssh app.example.com ls")
    task.commands.size.should eql(1)
  end
  
  it "should build remote sudo commands" do
    task = create_example_task
    task.target_host = "app.example.com"
    task.sudo "ls" 
    task.commands.size.should eql(1)
    task.commands.first.should eql(["ssh", "app.example.com", "sudo -p Password: ls"])
  end
  
  it "should run remote sudo commands" do
    task = create_example_task
    task.output << "file1\nfile2\n"
    task.error << 'Password:'
    task.target_host = "app.example.com"
    def task.sudo_password() "my password" end # gets defined by set
    result = nil
 
    out, err = capture_output do
      result = task.run("sudo ls")
    end
    
    task.commands.size.should eql(1)
    task.commands.first.should eql(['ssh', 'app.example.com', 'sudo ls'])
    task.input.string.should eql("my password\n")
 
    # WARN: Technically incorrect, the password line should be
    # first... this is an artifact of changes to the IO code in run
    # and the fact that we have a very simplistic (non-blocking)
    # testing model.
    result.should eql("file1\nfile2\nPassword:\n")
    out.read.should eql("file1\nfile2\n")
    err.read.should eql("Password:\n")
  end

  it "should get an options hash for a single option" do
    set :my_option, 10
    options = Rake::RemoteTask.get_options_hash(:my_option)
    options.should ==({ :my_option => 10 })
  end

  it "should get an options hash for multiple options" do
    set :my_option, 10
    set :my_other_option, 'my other option value'
    options = Rake::RemoteTask.get_options_hash(:my_option, :my_other_option)
    options.should ==({ :my_option => 10, :my_other_option => 'my other option value' })
  end
  
  it "should an empty options hash for an undefined option" do
    options = Rake::RemoteTask.get_options_hash(:my_undefined_option)
    options.should ==({})
  end
  
end
