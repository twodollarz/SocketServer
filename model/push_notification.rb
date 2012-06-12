require 'openssl'
require 'socket'
require 'apns'
require 'active_support/core_ext'
require 'user'

class PushNotification

  def initialize(environment = 'dev')
    if environment == 'dev'
      @hostname = 'gateway.sandbox.push.apple.com'
    else
      @hostname = 'gateway.push.apple.com'
    end
    APNS.host = @hostname
    APNS.pem = File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "apns-#{environment}.pem"))
    APNS.pass = "10xlabgaiax"
  end

  def notify(uid, message, badge = 0, sound = 'default')
    return false if uid.blank? || message.blank?
    user_dbh = Pipes::Model::User.new
    user = user_dbh.find(uid)
    return false if user.nil?

    token = user[:device_token]
    APNS.send_notification(token, alert: message, badge: badge, sound: sound)
  end
end
