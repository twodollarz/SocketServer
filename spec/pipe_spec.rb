# encoding: utf-8

require 'spec_helper'
require 'pipe'

describe Pipes::Model::Pipe do
  before :all do
    @pipe_dbh = Pipes::Model::Pipe.new()
  end

  describe "#create" do
    context "With two valid uids" do
      it "Pipe should be created" do
        @pipe = @pipe_dbh.create({:subj => 'helium', :obj => 'natrium'})
        found_pipe = @pipe_dbh.find_with_uid('helium')
        found_pipe[:from_uid].should == 'helium'
        found_pipe[:to_uid].should == 'natrium'
      end
    end
    context "With same two uids" do
      it "Pipe should not be created" do
        expect { @pipe_dbh.create({:subj => 'helium', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank from_uid" do
      it "Pipe should not be created" do
        expect { @pipe_dbh.create({:subj => '', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank to_uid" do
      it "Pipe should not be created" do
        expect { @pipe_dbh.create({:subj => 'helium', :obj => ''}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a non-existing from_uid" do
      it "Pipe should not be created" do
        expect { @pipe_dbh.create({:subj => 'goto', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
    context "With a non-existing to_uid" do
      it "Pipe should not be created" do
        expect { @pipe_dbh.create({:subj => 'helium', :obj => 'hell'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
  end

  describe "#approve" do
    context "With two valid uids" do
      before :all do
        @pipe = @pipe_dbh.approve({:subj => 'natrium', :obj => 'helium'})
        uids = @pipe_dbh.concat_uid('natrium', 'helium')
        @found_pipe = @pipe_dbh.find_with_uids(uids)
      end
      it "Pipe should be appoved" do
        @found_pipe[:from_uid].should == 'helium'
        @found_pipe[:to_uid].should == 'natrium'
        @found_pipe[:status].should == 1
      end
    end
    context "With same two uids" do
      it "Pipe should not be approved" do
        expect { @pipe_dbh.approve({:subj => 'helium', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank from_uid" do
      it "Pipe should not be approved" do
        expect { @pipe_dbh.approve({:subj => '', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank to_uid" do
      it "Pipe should not be approved" do
        expect { @pipe_dbh.approve({:subj => 'helium', :obj => ''}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a non-existing from_uid" do
      it "Pipe should not be approved" do
        expect { @pipe_dbh.approve({:subj => 'goto', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
    context "With a non-existing to_uid" do
      it "Pipe should not be approved" do
        expect { @pipe_dbh.approve({:subj => 'helium', :obj => 'hell'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
  end

  describe "#break" do
    context "With two valid uids (Subject is from_uid)" do
      before :all do
        @pipe = @pipe_dbh.break({:subj => 'helium', :obj => 'natrium'})
        uids = @pipe_dbh.concat_uid('helium', 'natrium')
        @found_pipe = @pipe_dbh.find_with_uids(uids)
      end
      it "Pipe should be appoved" do
        @found_pipe[:status].should == 2
      end
    end
    context "With two valid uids (Subject is to_uid)" do
      before :all do
        @pipe = @pipe_dbh.break({:subj => 'natrium', :obj => 'helium'})
        uids = @pipe_dbh.concat_uid('natrium', 'helium')
        @found_pipe = @pipe_dbh.find_with_uids(uids)
      end
      it "Pipe should be appoved" do
        @found_pipe[:status].should == 2
      end
    end
    context "With same two uids" do
      it "Pipe should not be breaked" do
        expect { @pipe_dbh.break({:subj => 'helium', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank from_uid" do
      it "Pipe should not be breaked" do
        expect { @pipe_dbh.break({:subj => '', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a blank to_uid" do
      it "Pipe should not be breaked" do
        expect { @pipe_dbh.break({:subj => 'helium', :obj => ''}) }.to raise_error(Pipes::Model::Pipe::InvalidUserError)
      end
    end
    context "With a non-existing from_uid" do
      it "Pipe should not be breaked" do
        expect { @pipe_dbh.break({:subj => 'goto', :obj => 'helium'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
    context "With a non-existing to_uid" do
      it "Pipe should not be breaked" do
        expect { @pipe_dbh.break({:subj => 'helium', :obj => 'hell'}) }.to raise_error(Pipes::Model::Pipe::UserNotFoundError)
      end
    end
  end

  describe "#concat_uid" do
    context "With uids in alphabetical order" do
      before :all do
        @uids = @pipe_dbh.concat_uid('helium', 'natrium')
      end
      it { @uids.should == 'heliumnatrium' }
    end
    context "With uids not in alphabetical order" do
      before do
        @uids = @pipe_dbh.concat_uid('natrium', 'helium')
      end
      it { @uids.should == 'heliumnatrium' }
    end
  end

  describe "#find_with_uid" do
    context "With valid params" do
      before :all do
        @found_pipe = @pipe_dbh.find_with_uid('lithium')
      end
      subject { @found_pipe }
      it { should_not be_nil }
    end
    context "With invalid params" do
      it 'Shoud be raise error' do
        expect { @pipe_dbh.find_with_uid('foo') }.to raise_error(Pipes::Model::Pipe::PipeNotFoundError)
      end
    end
  end

  describe "#find_approved_pipes" do
    context "With valid params" do
      before :all do
        @found_pipe = @pipe_dbh.find_approved_pipes('lithium')
      end
      subject { @found_pipe }
      it { should_not be_nil }
      its(:count) { should eq 1 }
    end
    context "With valid params" do
      before :all do
        @found_pipe = @pipe_dbh.find_approved_pipes('neon')
      end
      subject { @found_pipe }
      it { should_not be_nil }
      its(:count) { should eq 1 }
    end
    context "With invalid params" do
      it 'Shoud be raise error' do
        expect { @pipe_dbh.find_approved_pipes('f-kid') }.to raise_error(Pipes::Model::Pipe::PipeNotFoundError)
      end
    end
  end

  describe "#find_with_uids" do
    context "With valid params" do
      before :all do
        @found_pipe = @pipe_dbh.find_with_uids(@pipe_dbh.concat_uid('lithium','neon'))
      end
      subject { @found_pipe }
      it { should_not be_nil }
      its([:from_uid]) { should eq 'lithium' }
    end
    context "With invalid params" do
      it 'Shoud be raise error' do
        expect { @pipe_dbh.find_with_uids('foobar') }.to raise_error(Pipes::Model::Pipe::PipeNotFoundError)
      end
    end
  end

  describe "#find_applying_pipes" do
    context "With valid params" do
      before :all do
        @pipe_dbh.create({:subj => 'natrium', :obj => 'lithium'})
        @found_pipe = @pipe_dbh.find_applying_pipes('natrium')
      end
      subject { @found_pipe }
      it { should_not be_nil }
      its(:count) { should eq 1 }
    end
    context "With invalid params" do
      it 'Shoud be raise error' do
        expect { @pipe_dbh.find_applying_pipes('f-kid') }.to raise_error(Pipes::Model::Pipe::PipeNotFoundError)
      end
    end
  end

  describe "#find_applied_pipes" do
    context "With valid params" do
      before :all do
        @pipe_dbh.create({:subj => 'neon', :obj => 'helium'})
        @found_pipe = @pipe_dbh.find_applied_pipes('helium')
      end
      subject { @found_pipe }
      it { should_not be_nil }
    end
    context "With invalid params" do
      it 'Shoud be raise error' do
        expect { @pipe_dbh.find_applied_pipes('f-kid') }.to raise_error(Pipes::Model::Pipe::PipeNotFoundError)
      end
    end
  end
end
