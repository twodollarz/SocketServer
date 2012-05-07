#!/usr/bin/ruby

# encoding: utf-8 -*-

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'base64'

class ChatServer
  def initialize (port)
    @connections = {}
    @sequence = 0
    @thread = nil
    @server = TCPServer.new("", port)
    puts "Chat Server started on port" << port.to_s
  end

  def run
    loop do
      @thread = Thread.start(@server.accept) do |sock|
       while sock.gets
          puts("= Accept =")
          (key, cmd, obj1, obj2) = $_.split(":")
          puts("key: #{key}")
          puts("cmd: #{cmd}")
          puts("obj1: #{obj1}")
          puts("obj2: #{obj2}")
          obj2.chomp!
          
          case cmd
          # first access ( udid:reg:profiles[]=> udid:reg:profiles[]:true:uid )
          when 'reg'
            udid = key
            nickname = obj1
            @connections[data] = sock
            send_back(key, "#{key}:#{cmd}:#{data}")
          # app launch ( uid:conn => uid:conn:true:messages[] )
          when 'conn'
          # sendmsg ( uid:sendmsg:o-uid:message => uid:sendmsg:o-uid:message:true ) 
          when 'send'
            broadcast(key, "#{key}:#{cmd}:#{data}")
          # sendimage ( uid:sendimg:o-uid:BASE64(imagebin) => uid:sendimg:o-uid:BASE64(imagebin):true ) 
          when 'sendimg'
            save_image(key, data)
            broadcast(key, "#{key}:#{cmd}:#{data}")
          # disconn ( uid:disconn => uid:disconn:true )
          when 'quit'
          # apply ( uid:apply:o-uid => uid:apply:o-uid:true )
          when 'pipe'
          # approve( uid:approve:o-uid => uid:approve:o-uid:true )
          when 'system'
          end
          puts "= Connections ="
          ap @connections
        end
      end
    end
  end

  def generate_uid
    @sequence += 1
    return @sequence
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
    puts "= Broadcasting Done ="
  end

  def send_back(key, msg)
    puts "= Send Back ="
    @connections.each do |id, sock|
      if key == id then
        puts "* Send back to #{id}"
        msg.chomp!
        sock.puts("#{msg}")
      end
    end
    puts "= Send Back Done ="
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

#chat_server = ChatServer.new( 4980 ).run()

