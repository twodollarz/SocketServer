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
        before do
          @spec_obj.send_text({:from_uid => 'lithium', :to_uid => 'neon', :timestamp => '20120101000000000', :message => 'message'})
          pipe_dbh = Pipes::Model::Pipe.new()
          pipe = pipe_dbh.find_with_uids('lithiumneon')
          @found_msg = @spec_obj.find_with_pipe_id(pipe[:pipe_id])
        end
        subject { @found_msg }
        it { should_not be nil }
      end
      context 'When multi byte character message' do
        before do
          @spec_obj.send_text({:from_uid => 'neon', :to_uid => 'lithium', :timestamp => '20120101000000001', :message => 'メッセージ'})
          pipe_dbh = Pipes::Model::Pipe.new()
          pipe = pipe_dbh.find_with_uids('lithiumneon')
          @found_msg = @spec_obj.find_with_pipe_id(pipe[:pipe_id])
        end
        subject { @found_msg }
        it { should_not be nil }
      end
    end
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
      context "With a non-existing uid" do
        it "Message should not be sent" do
          expect { @spec_obj.send_text({:from_uid => 'goto', :to_uid => 'hell', :timestamp => '20120101000000000', :message => 'message'}) }.to raise_error(Pipes::Model::Message::UserNotFoundError)
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
    context 'With invalid params' do
      it 'Pipe Should be found ' do
        expect {@spec_obj.find_with_pipe_id(1)}.to raise_error(Pipes::Model::Message::MessageNotFoundError)
      end
    end
  end

  describe :send_image do
  end

  describe :offline_log do
  end
end

