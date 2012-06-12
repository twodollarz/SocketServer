# encoding: utf-8

require 'spec_helper'
require 'push_notification'
require 'apns'

describe PushNotification do
  before do
    @notification = PushNotification.new
  end
  subject { @notification }

  describe 'create object' do
    it { should_not be_nil }
    it { should be_instance_of(PushNotification) }
  end

  describe 'notify' do
    before do
      @notification = PushNotification.new()
    end
    context 'with valid params' do
      context 'with single byte character params' do
        before { @notification.notify('lithium', 'How are you?') }
        it { should be_true }
      end
      context 'with multi byte character params' do
        before { @notification.notify('lithium', 'こんにちは') }
        it { should be_true }
      end
    end
    context 'with invalid params' do
      context 'with nil uid' do
        subject { @notification.notify(nil, 'How are you>') }
        it { should be_false }
      end
      context 'with empty uid' do
        subject { @notification.notify('', 'How are you>') }
        it { should be_false }
      end
      context 'with nil alert' do
        subject { @notification.notify('lithium', nil) }
        it { should be_false }
      end
      context 'with blank alert' do
        subject { @notification.notify('lithium', '') }
        it { should be_false }
      end
    end
  end
end
