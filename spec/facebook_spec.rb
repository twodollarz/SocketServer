require 'spec_helper'
require 'facebook'

APP_ID = '353388311380759'
SECRET = 'e578b1f8339533d1c4198a6b44a3045c'

describe Facebook do
  before :all do
    @test_users = Koala::Facebook::TestUsers.new(app_id: APP_ID, secret: SECRET)
    user = @test_users.create(true, "user_photos")
    @token = user["access_token"]
    pipe_dbh = Pipes::Model::Pipe.new
    pipe_dbh.set_facebook_token('lithium', 'neon', @token)
#    pipe_dbh = Pipes::Model::Pipe.new
#    pipe = pipe_dbh.find_with_uids(pipe_dbh.concat_uid('lithium', 'neon'))
#    pipe_dbh.set_facebook_token(pipe[:pipe_id].to_s, user["access_token"])
#    user_dbh.set('lithium', { key: 'facebook_token', value: user["access_token"] })
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
