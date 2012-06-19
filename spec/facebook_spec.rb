require 'spec_helper'
require 'facebook'
require 'server'

describe Facebook do
  before :all do
    @test_users = Koala::Facebook::TestUsers.new(app_id: ChatServer::FB_APP_ID, secret: ChatServer::FB_SECRET)
    user = @test_users.create(true, "user_photos")
    @token = user["access_token"]
    pipe_dbh = Pipes::Model::Pipe.new
    pipe_dbh.set_facebook_token('lithium', 'neon', @token)
    @facebook = Facebook.new('lithium', 'neon')
  end

  describe 'create album' do
    before (:all) { @album = @facebook.create_album }
    subject { @album }
    it { should_not be_nil }
    it 'has album id' do
      subject["id"].should match(/^\d+$/)
    end
    it 'has album url' do
      subject["link"].should_not be_nil
    end
    it 'is private aljum' do
      subject["privacy"].should eql 'custom'
    end
  end

  describe 'upload photo' do
  end
end
