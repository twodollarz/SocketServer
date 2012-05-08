require 'spec_helper'
require 'user'

describe Pipes::Model::User do
  before :all do
    @user_dbh= Pipes::Model::User.new()
    @user = @user_dbh.create( {:udid => '0000-0000-0000-0000'} ) 
  end

  context 'When create, ' do
    describe 'New user' do
      subject { @user }
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
end

