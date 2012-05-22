# encoding: utf-8

require 'spec_helper'
require 'message'

describe Pipes::Model::Message do
  before :all do
    @spec_obj = Pipes::Model::Message.new()
  end

  describe :send_text do
    context 'With valid params' do
      context 'When single byte character message' do
        before :all do
          @spec_obj.send_text({:from_uid => 'lithium', :to_uid => 'neon', :timestamp => '20120101000000000', :message => 'message'})
          pipe_dbh = Pipes::Model::Pipe.new()
          pipe = pipe_dbh.find_with_uids('lithiumneon')
          @found_msgs = @spec_obj.find_with_pipe_id(pipe[:pipe_id])
        end
        subject { @found_msgs }
        it { should_not be nil }
        it 'Message should be correct' do
          @found_msgs.to_a.pop[:message].should == 'message'
        end
        it 'Timestamp should be correct' do
          @found_msgs.to_a.pop[:timestamp].should == '20120101000000000'
        end
      end
      context 'When multi byte character message' do
        before :all do
          @spec_obj.send_text({:from_uid => 'neon', :to_uid => 'lithium', :timestamp => '20120101000000010', :message => 'メッセージ'})
          pipe_dbh = Pipes::Model::Pipe.new()
          pipe = pipe_dbh.find_with_uids('lithiumneon')
          @found_msgs = @spec_obj.find_with_pipe_id(pipe[:pipe_id])
        end
        subject { @found_msgs }
        it { should_not be nil }
        it 'Message should be correct' do
          @found_msgs.to_a.pop[:message].should == 'メッセージ'
        end
        it 'Timestamp should be correct' do
          @found_msgs.to_a.pop[:timestamp].should == '20120101000000010'
        end
      end
    end
    # TODO with invalid(not approved) pipe user
    context 'With invalid params' do
      context "With same two uids" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'neon', :to_uid => 'neon', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank from_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => '', :to_uid => 'neon', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank to_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'lithium', :to_uid => '', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a non-existing from_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'goto', :to_uid => 'lithium', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
      context "With a non-existing to_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'lithium', :to_uid => 'hell', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
    end
  end

  describe :find_with_pipe_id do
    context 'With valid params' do
      before do
        @found_pipe = @spec_obj.find_with_pipe_id(10000)
      end
      subject { @found_pipe }
      it { should_not be_nil }
    end
  end

  describe :send_img do
    context 'With valid params' do
      context 'When single byte character message' do
        before :all do
          @spec_obj.send_img({:from_uid => 'lithium', :to_uid => 'neon', :timestamp => '20120101000000020', :image_path=> '/data/image.jpg'})
          pipe_dbh = Pipes::Model::Pipe.new()
          pipe = pipe_dbh.find_with_uids('lithiumneon')
          @found_msgs = @spec_obj.find_with_pipe_id(pipe[:pipe_id])
        end
        subject { @found_msgs }
        it { should_not be nil }
        it 'Image path should be correct' do
            @found_msgs.to_a.pop[:image_path].should == '/data/image.jpg'
        end
        it 'Timestamp should be correct' do
          @found_msgs.to_a.pop[:timestamp].should == '20120101000000020'
        end
      end
    end
    context 'With invalid params' do
      context "With same two uids" do
        it "Message should not be sent" do
          expect { @spec_obj.send_img({:from_uid => 'neon', :to_uid => 'neon', :timestamp => '20120101000000000', :image_path=> '/data/image.jpg'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank from_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_img({:from_uid => '', :to_uid => 'neon', :timestamp => '20120101000000000', :image_path=> '/data/image.jpg'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank to_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'lithium', :to_uid => '', :timestamp => '20120101000000000', :image_path => '/data/image.jpg'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a non-existing from_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'goto', :to_uid => 'lithium', :timestamp => '20120101000000000', :image_path => '/data/image.jpg'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
      context "With a non-existing to_uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'lithium', :to_uid => 'hell', :timestamp => '20120101000000000', :image_path => '/data/image.jpg'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
    end
  end

  describe :get_log do
    context 'With valid params' do
      context 'When include one message log' do
        before do
          @found_logs = @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000011'})
        end
        subject { @found_logs }
        it { should_not be nil}
      end
      context 'When from_timestamp(last online time) is same' do
        before do
          @found_logs = @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'})
        end
        subject { @found_logs }
        it { should be nil }
      end
    end
    context 'With invalid params' do
      context "With same two timestamp" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid from_timestamp" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => 'invalidtimestamp', :to_timestamp => '20120101000000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid from_timestamp(16 digits)" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '2012010100000000', :to_timestamp => '20120101000000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid from_timestamp(18 digits)" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '201201010000000000', :to_timestamp => '20120101000000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid to_timestamp" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => 'invalidtimestamp'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid to_timestamp(16 digits)" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '2012010100000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With an invalid to_timestamp(18 digits)" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '201201010000000000'}) }.to raise_error(Pipes::Model::Message::InvalidTimestampError)
        end 
      end
      context "With same two uids" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'lithium', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank from_uid" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => '', :to_uid => 'neon', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a blank to_uid" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => '', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'}) }.to raise_error(Pipes::Model::Message::InvalidUserError)
        end 
      end
      context "With a non-existing from_uid" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'goto', :to_uid => 'lithium', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
      context "With a non-existing to_uid" do
        it "Message log should not be found" do
          expect { @spec_obj.get_log({:from_uid => 'lithium', :to_uid => 'hell', :from_timestamp => '20120101000000000', :to_timestamp => '20120101000000001'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
        end 
      end
    end
  end
end

