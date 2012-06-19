# encoding: utf-8

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'base64'
require 'user'
require 'pipe'
require 'message'
require 'push_notification'
require 'facebook'

class ChatServer
  DB_CONNECTIONS = 5
  DB_TIMEOUT = 10
  FB_APP_ID = '353388311380759'
  FB_SECRET = 'e578b1f8339533d1c4198a6b44a3045c'
  IMG_PATH = '/tmp'
  IMG_URL = 'http://localhost/images'

  class UserIsNotOnlineError < RuntimeError; end

  def initialize (port)
    @connections = {}
    @thread = nil
    @server = TCPServer.new("", port)
    puts "Chat Server started on port" << port.to_s
  end

  def run
    loop do
      @thread = Thread.start(@server.accept) do |sock|
        while sock.gets
          $_.chomp!
          $_.force_encoding('utf-8')
          (timestamp, id, cmd, obj1, obj2, obj3) = $_.split(":")
          puts ""
          puts "= Accept ="
          puts ":timestamp => #{timestamp}, :id => #{id}, :cmd => #{cmd}, :obj1 => #{obj1}, :obj2 => #{obj2}, :obj3 => #{obj3}"
          self.send(cmd, sock, timestamp, id, obj1, obj2, obj3)
          puts ""
          puts "= Connections ="
          ap @connections
          # Collect unnecessary objects to disconnect from database
          GC.start
        end
      end
    end
  end

  def add_socket(key, sock)
    @connections[key] = sock
  end

  def reg(sock, timestamp, id, obj1, obj2, obj3)
    uid = obj1
    udid = id
    add_socket(uid, sock)
    begin
      user_dbh = Pipes::Model::User.new
      user_dbh.create({:uid => uid, :udid => udid})
      send_toward(uid, "#{timestamp}:#{uid}:reg:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:reg:error:#{$!}")
    end
  end

  def settel(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      user_dbh = Pipes::Model::User.new
      user_dbh.set(uid, {:key => 'tel', :value => obj1})
      send_toward(uid, "#{timestamp}:#{uid}:settel:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:settel:error:#{$!}")
    end
  end

  def setnickname(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      user_dbh = Pipes::Model::User.new
      user_dbh.set(uid, {:key => 'nickname', :value => obj1})
      send_toward(uid, "#{timestamp}:#{uid}:setnickname:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:setnickname:error:#{$!}")
    end
  end

  ## TODO Faceimage: decode base64 string and store as file and update db
  def setfaceimage(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      user_dbh = Pipes::Model::User.new
      user_dbh.set(uid, {:key => 'faceimage_path', :value => obj1})
      send_toward(uid, "#{timestamp}:#{uid}:setfaceimage:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:setfaceimage:error:#{$!}")
    end
  end

  def setdevicetoken(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      user_dbh = Pipes::Model::User.new
      user_dbh.set(uid, {:key => 'device_token', :value => obj1})
      send_toward(uid, "#{timestamp}:#{uid}:setdevicetoken:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:setdevicetoken:error:#{$!}")
    end
  end

  def setfbtoken(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.set_facebook_token(uid, obj1, obj2)
      facebook = Facebook.new(uid, obj1)
      album = facebook.create_album
      send_toward(obj1, "#{timestamp}:#{uid}:setfbtoken:#{album['link']}") do
        PushNotification.new.notify(obj1, 'アルバムが作成されました')
      end
      send_toward(uid, "#{timestamp}:#{uid}:setfbtoken:success:#{album['link']}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:setfbtoken:error:#{$!}")
    end
  end

  def apply(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.create({:subj => uid, :obj => obj1})
      send_toward(obj1, "#{timestamp}:#{uid}:apply") do
        PushNotification.new.notify(obj1, '申請がありました')
      end
      send_toward(uid, "#{timestamp}:#{uid}:apply:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:apply:error:#{$!}")
    end
  end

  def approve(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.approve({:subj => uid, :obj => obj1})
      send_toward(obj1, "#{timestamp}:#{uid}:approve") do
        PushNotification.new.notify(obj1, '申請が承認されました')
      end
      send_toward(uid, "#{timestamp}:#{uid}:approve:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:approve:error:#{$!}")
    end
  end

  def break(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.break({:subj => uid, :obj => obj1})
      send_toward(obj1, "#{timestamp}:#{uid}:break")
      send_toward(uid, "#{timestamp}:#{uid}:break:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:break:error:#{$!}")
    end
  end

  def sendtext(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      msg_dbh = Pipes::Model::Message.new
      msg_dbh.send_text({:from_uid => uid, :to_uid => obj1, :timestamp => timestamp, :message => obj2})
      send_toward(obj1,"#{timestamp}:#{uid}:sendtext:#{obj1}:#{obj2}") do
        PushNotification.new.notify(obj1, obj2)
      end
      send_toward(uid, "#{timestamp}:#{uid}:sendtext:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:sendtext:error:#{$!}")
    end
  end

  def sendimg(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      tmp_file_path = save_tmp_image(uid, obj2)

      facebook = Facebook.new(uid, obj1)
      image_obj = facebook.put_picture(tmp_file_path)
      url = image_obj["picture"]

      msg_dbh = Pipes::Model::Message.new
      msg_dbh.send_img({:from_uid => uid, :to_uid => obj1, :timestamp => timestamp, :image_path=> url})
      send_toward(obj1, "#{timestamp}:#{uid}:sendimg:#{obj1}:#{url}")
      send_toward(uid, "#{timestamp}:#{uid}:sendimg:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:sendimg:error:#{$!}")
    end
  end

  def online(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    add_socket(uid, sock)
    begin
      send_toward(uid, "#{timestamp}:#{uid}:online:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:online:error:#{$!}")
    end
  end

  def offline(sock, timestamp, id, obj1, obj2, obj3)
    @connections.delete(id) if @connections.has_key?(id)
  end

  def couplelist(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipes = pipe_dbh.find_approved_pipes(uid)
      partners = []
      pipes.each do |pipe|
        theother = (id == pipe[:to_uid]) ? pipe[:from_uid] : pipe[:to_uid]
        partners.push(theother)
      end
      couplelist = partners.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:couplelist:success:#{couplelist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:couplelist:error:#{$!}")
    end
  end

  def applylist(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipes = pipe_dbh.find_applying_pipes(uid)
      applylist = pipes.map { |pipe| pipe[:to_uid] }.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:applylist:success:#{applylist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:applylist:error:#{$!}")
    end
  end

  def approvelist(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipes = pipe_dbh.find_applied_pipes(uid)
      approvelist = pipes.map { |pipe| pipe[:from_uid] }.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:approvelist:success:#{approvelist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:approvelist:error:#{$!}")
    end
  end

  def getlog(sock, timestamp, id, obj1, obj2, obj3)
    uid = id
    begin
      msg_dbh = Pipes::Model::Message.new
      logs = msg_dbh.get_log({:from_uid => uid, :to_uid => obj1, :from_timestamp => obj2, :to_timestamp => obj3})
      require 'json'
      json_str = JSON.generate(logs)
      send_toward(uid, "#{timestamp}:#{uid}:getlog:success:valid:#{json_str}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:getlog:error:#{$!}")
    end
  end

  def broadcast(key, msg)
    puts "= Broadcasting ="
    @connections.each do |id, sock|
      unless key == id then
        puts "* Broadcasting #{id}"
        msg.chomp!
        sock.puts("#{msg}")
      end
    end
  end

  def ping(key)
      puts "\n= Send Ping ="
      @connections[key].puts("0")
      @connections[key].flush
  end

  def send_toward(key, msg)
    if offline?(key)
      puts "\n= Send Push Notification ="
      yield
      puts " #{key} > #{msg}"
    else
      puts "\n= Send Towards ="
      msg.chomp!
      @connections[key].puts(msg)
      @connections[key].flush
      puts " #{key} > #{msg}"
    end
  end

  def offline?(key)
    return true if !@connections.has_key?(key)
    begin
      ping(key)
    rescue Errno::EPIPE  # Broken Pipe Error
      puts "= Broken Pipe Error ="
      @connections.delete(key)
      return true
    end
    return false
  end

  def save_tmp_image(uid, data)
    puts "= Save Temporary Image ="
    time = Time.now.strftime("%Y%m%d%H%M%S")
    #Dir::mkdir("#{ChatServer::IMG_PATH}/#{uid[0..1]}")
    #filepath = "#{uid[0..1]}/#{uid}_#{time}.png"
    filepath = "#{ChatServer::IMG_PATH}/#{uid}_#{time}.png"
    open(filepath, "w+b") do |fw|
      fw.write(Base64.decode64(data))
    end
    return filepath
  end

end


