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
    context 'with jpg' do
      before (:all) { @picture = @facebook.put_picture(File.expand_path('../images/test.jpg', __FILE__)) }
      subject { ap @picture; @picture }
      it { subject["id"].should match(/^\d+$/) }
      it { subject["picture"].should match(/^http:.*\.jpg$/) }
      it { subject["link"].should match(/^http:/) }
    end
    context 'with png' do
      before (:all) { @picture = @facebook.put_picture(File.expand_path('../images/test.png', __FILE__)) }
      subject { ap @picture; @picture }
      it { subject["id"].should match(/^\d+$/) }
      it { subject["picture"].should match(/^http:.*\.jpg$/) }
      it { subject["link"].should match(/^http:/) }
    end
    context 'with gif' do
      before (:all) { @picture = @facebook.put_picture(File.expand_path('../images/test.gif', __FILE__)) }
      subject { ap @picture; @picture }
      it { subject["id"].should match(/^\d+$/) }
      it { subject["picture"].should match(/^http:.*\.jpg$/) }
      it { subject["link"].should match(/^http:/) }
    end
  end
end
