#!usr/bin/ruby

# encoding: utf-8

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'base64'
require 'user'
require 'pipe'
require 'message'

class ChatServer

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
          (timestamp, id, cmd, obj1, obj2) = $_.split(":")
          puts ""
          puts "= Accept ="
          puts ":timestamp => #{timestamp}, :id => #{id}, :cmd => #{cmd}, :obj1 => #{obj1}, :obj2 => #{obj2} "
          self.send(cmd, sock, timestamp, id, obj1, obj2)
          puts ""
          puts "= Connections ="
          ap @connections
        end
      end
    end
  end

  def add_socket(key, sock) 
    @connections[key] = sock
  end

  def reg(sock, timestamp, id, obj1, obj2)
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

  ## TODO Faceimage: decode base64 string and store as file and update db 
  def set(sock, timestamp, id, obj1, obj2)
    uid = id
    begin 
      user_dbh = Pipes::Model::User.new
      user_dbh.set(uid, {:key => obj1, :value => obj2})
      send_toward(uid, "#{timestamp}:#{uid}:set:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:set:error:#{$!}")
    end
  end

  def apply(sock, timestamp, id, obj1, obj2)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.create({:subj => uid, :obj => obj1})
      send_toward(obj1, "#{timestamp}:#{uid}:apply")
      send_toward(uid, "#{timestamp}:#{uid}:apply:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:apply:error:#{$!}")
    end
  end

  def approve(sock, timestamp, id, obj1, obj2)
    uid = id
    begin
      pipe_dbh = Pipes::Model::Pipe.new
      pipe_dbh.approve({:subj => uid, :obj => obj1})
      send_toward(obj1, "#{timestamp}:#{uid}:approve")
      send_toward(uid, "#{timestamp}:#{uid}:approve:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:approve:error:#{$!}")
    end
  end

  def break(sock, timestamp, id, obj1, obj2)
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

  def sendtext(sock, timestamp, id, obj1, obj2)
    uid = id
    begin
      msg_dbh = Pipes::Model::Message.new
      msg_dbh.send_text({:from_uid => uid, :to_uid => obj1, :timestamp => timestamp, :message => obj2})
      send_toward(obj1, "#{timestamp}:#{uid}:sendtext:#{obj1}:#{obj2}")
      send_toward(uid, "#{timestamp}:#{uid}:sendtext:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:sendtext:error:#{$!}")
    end
  end

  # TODO save binary
  def sendimg(sock, timestamp, id, obj1, obj2)
    uid = id
    begin
      msg_dbh = Pipes::Model::Message.new
      msg_dbh.send_img({:from_uid => uid, :to_uid => obj1, :timestamp => timestamp, :image_path=> obj2})
      send_toward(obj1, "#{timestamp}:#{uid}:sendimg:#{obj1}:#{obj2}")
      send_toward(uid, "#{timestamp}:#{uid}:sendimg:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:sendiimg:error:#{$!}")
    end
  end

  def online(sock, timestamp, id, obj1, obj2)
    uid = id
    add_socket(uid, sock)
    begin 
      send_toward(uid, "#{timestamp}:#{uid}:online:success")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:online:error:#{$!}")
    end
  end

  def couplelist(sock, timestamp, id, obj1, obj2)
    uid = id
    begin 
      pipe_dbh = Pipes::Model::Pipe.new
      @pipes = pipe_dbh.find_approved_pipes(uid)
      partners = []
      @pipes.each do |pipe|
        theother = (id == pipe[:to_uid]) ? pipe[:from_uid] : pipe[:to_uid]
        partners.push(theother)
      end
      couplelist = partners.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:couplelist:success:#{couplelist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:couplelist:error:#{$!}")
    end
  end

  def applylist(sock, timestamp, id, obj1, obj2)
    uid = id
    begin 
      pipe_dbh = Pipes::Model::Pipe.new
      @pipes = pipe_dbh.find_applying_pipes(uid)
      applylist = @pipes.map { |pipe| pipe[:to_uid] }.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:applylist:success:#{applylist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:applylist:error:#{$!}")
    end
  end
  def approvelist(sock, timestamp, id, obj1, obj2)
    uid = id
    begin 
      pipe_dbh = Pipes::Model::Pipe.new
      @pipes = pipe_dbh.find_applied_pipes(uid)
      approvelist = @pipes.map { |pipe| pipe[:from_uid] }.join(',')
      send_toward(uid, "#{timestamp}:#{uid}:approvelist:success:#{approvelist}")
    rescue
      send_toward(uid, "#{timestamp}:#{uid}:approvelist:error:#{$!}")
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

  def send_toward(key, msg)
    raise UserIsNotOnlineError unless @connections.has_key?(key)
    puts ""
    puts "= Send Towards ="
    msg.chomp!
    @connections[key].puts(msg)
    puts " #{key} > #{msg}"
  end

  def save_image(key, data)
    puts "save_image"
    #fw = open("#{key}_copy.png", "a+b")
    time = Time.now.strftime("%Y%m%d%H%M%S")
    fw = open("tmp/#{key}_#{time}.png", "w+b")
    #data.chomp!
    fw.write(Base64.decode64(data))
    fw.close
  end

end


