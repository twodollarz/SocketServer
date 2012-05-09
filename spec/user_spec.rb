# encoding: utf-8

require 'spec_helper'
require 'user'

describe Pipes::Model::User do
  before(:all) do
    @user_dbh= Pipes::Model::User.new()
    @user = @user_dbh.create( {:udid => '0000-0000-0000-0000'} ) 
  end

  context 'When create' do
    subject { @user }
    describe 'New user' do
      it { should_not be_nil }
      it 'uuid should be created' do
        subject[:uuid].should_not be_nil
      end
      it 'udid should be same as input' do
        subject[:udid].should == '0000-0000-0000-0000'
      end
    end
    describe 'Duplicated user' do
      it 'should not be created' do
        lambda { @user_dbh.create({:udid => '0000-0000-0000-0000'}) }.should raise_error(Pipes::Model::User::DuplicatedUserError)
      end
    end
  end

  context 'When find User' do
    subject { @user }
    context 'With existing user' do
       it 'should be found' do
         found_user = @user_dbh.find(@user[:uuid])
         found_user[:udid].should == @user[:udid]
       end
    end
    context 'With non-existing user' do
       it 'should not be found' do
         lambda { @user_dbh.find('non-existing-uuid') }.should raise_error(Pipes::Model::User::UserNotFoundError)
       end
    end
  end

  context 'When set profile' do
    subject { @user }
    it 'Tel should be chaned' do
      @user_dbh.set( @user[:uuid], { key: 'tel', value: '090-0000-0000' })
      found_user = @user_dbh.find(@user[:uuid])
      found_user[:tel].should == '090-0000-0000' 
    end
    it 'Nickname(muli-byte character) should be chaned' do
      @user_dbh.set( @user[:uuid], { key: 'nickname', value: 'akira' })
      found_user = @user_dbh.find(@user[:uuid])
      found_user[:nickname].should == 'akira' 
    end
    it 'Nickname(single-byte character should be chaned' do
      @user_dbh.set( @user[:uuid], { key: 'nickname', value: 'あきら' })
      found_user = @user_dbh.find(@user[:uuid])
      found_user[:nickname].should == 'あきら' 
    end
    it 'Duplicated userid should not be chaned' do
  
      lambda { @user_dbh.set( @user[:uuid], { key: 'userid', value: @user[:uuid] }) }.should raise_error(Pipes::Model::User::DuplicatedUserError)
    end
    it 'Userid should be chaned' do
      @user_dbh.set( @user[:uuid], { key: 'userid', value: 'f-kid' })
      found_user = @user_dbh.find(@user[:uuid])
      found_user[:userid].should == 'f-kid' 
    end
=begin
    describe 'Faceimage(base64 encoded string) should be decoded and changed' do
      @user_dbh.set( @user[:uuid], { key: 'faceimage', value: '' })
      found_user = @user_dbh.find(@user[:uuid])
      found_user[:userid].should == 'f-kid' 
    end
=end
    describe 'Invalid column' do
       
    end
  end
end

