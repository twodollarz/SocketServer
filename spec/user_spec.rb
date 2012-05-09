# encoding: utf-8

require 'spec_helper'
require 'user'

describe Pipes::Model::User do
  before(:all) do
    @user_dbh = Pipes::Model::User.new()
    @user = @user_dbh.create( {:uid => 'f-kid', :udid => '0000-0000-0000-0000'} ) 
  end

  context 'When create' do
    subject { @user }
    describe 'New user' do
      it { should_not be_nil }
      it 'should be created' do
        found_user = @user_dbh.find(@user[:uid])
        found_user.should_not be_nil
        found_user[:udid].should == '0000-0000-0000-0000'
      end
    end
    it 'Duplicated user should not be created' do
      lambda { @user_dbh.create({:uid => 'twodollarz', :udid => '0000-0000-0000-0000'}) }.should raise_error(Pipes::Model::User::DuplicatedUserError)
      lambda { @user_dbh.create({:uid => 'f-kid', :udid => '1111-1111-1111-1111'}) }.should raise_error(Pipes::Model::User::DuplicatedUserError)
    end
  end

  context 'When find User' do
    subject { @user }
    context 'With existing user' do
       it 'should be found' do
         found_user = @user_dbh.find(@user[:uid])
         found_user[:udid].should == @user[:udid]
       end
    end
    context 'With non-existing user' do
       it 'should not be found' do
         lambda { @user_dbh.find('non-existing-uid') }.should raise_error(Pipes::Model::User::UserNotFoundError)
       end
    end
  end

  context 'When set profile' do
    subject { @user }
    it 'Tel should be chaned' do
      @user_dbh.set( @user[:uid], { key: 'tel', value: '090-0000-0000' })
      found_user = @user_dbh.find(@user[:uid])
      found_user[:tel].should == '090-0000-0000' 
    end
    it 'Nickname(muli-byte character) should be chaned' do
      @user_dbh.set( @user[:uid], { key: 'nickname', value: 'akira' })
      found_user = @user_dbh.find(@user[:uid])
      found_user[:nickname].should == 'akira' 
    end
    it 'Nickname(single-byte character should be chaned' do
      @user_dbh.set( @user[:uid], { key: 'nickname', value: 'あきら' })
      found_user = @user_dbh.find(@user[:uid])
      found_user[:nickname].should == 'あきら' 
    end
    it 'Non-existing user should raise error' do
      lambda { @user_dbh.set( 'non-existing-uid', { key: 'userid', value: 'f-kid' }) }.should raise_error(Pipes::Model::User::UserNotFoundError)
    end
    it 'Invalid column should not be changed' do
      lambda { @user_dbh.set( @user[:uid], { key: 'invalidcolumn', value: 'foobarbaz' }) }.should raise_error(Pipes::Model::User::UnknownColumnError)
    end
    it 'Faceimage(base64 encoded string) should be changed' do
      @user_dbh.set( @user[:uid], { key: 'faceimage_path', value: '/data/faceimage.jpg'})
      found_user = @user_dbh.find(@user[:uid])
      found_user[:faceimage_path].should == '/data/faceimage.jpg' 
    end
  end
end

