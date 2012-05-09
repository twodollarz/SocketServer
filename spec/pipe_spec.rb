# encoding: utf-8

require 'spec_helper'
require 'pipe'

describe Pipes::Model::Pipe do
  before(:all) do
    @pipe_dbh = Pipes::Model::Pipe.new()
  end

  describe "#create" do
    context "With two valid uids" do
      it "Pipe should be created" do
        @pipe = @pipe_dbh.create({:from_uid => 'helium', :to_uid => 'natrium'})
        found_pipe = @pipe_dbh.find_with_uid('helium')
        found_pipe[:from_uid].should == 'helium'
        found_pipe[:to_uid].should == 'natrium'
      end 
    end
    context "With same two uids" do
      it "Pipe should not be created" do
      end 
    end
    context "With a blank uid" do
      it "Pipe should not be created" do
      end 
    end
    context "With a non-existing uid" do
      it "Pipe should not be created" do
      end 
    end
  end
end
