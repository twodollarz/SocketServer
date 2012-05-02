#!/usr/bin/ruby

# encoding: utf-8 -*-

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'base64'

class ChatServer
  def initialize (port)
    @connections = {}
    @server = TCPServer.new("", port)
    puts "Chat Server started on port" << port.to_s
  end

  def run
    loop do
      Thread.start(@server.accept) do |sock|
       #save_image("append", sock.read_nonblock(1024))
       #save_image("whole", data)
       while sock.gets
          puts("= Accept =")
          (key, cmd, data) = $_.split(":")
          puts("key: #{key}")
          puts("cmd: #{cmd}")
          puts("data: #{data}")
          data.chomp!
          unpackdata = data.unpack("n*").inspect
          puts("unpack data: #{unpackdata}")
          case cmd
          when 'reg'
            @connections[data] = sock
            send_back(key, "#{key}:#{cmd}:#{data}")
          when 'send'
            broadcast(key, "#{key}:#{cmd}:#{data}")
          when 'sendimg'
            save_image(key, data)
            broadcast(key, "#{key}:#{cmd}:#{data}")
          when 'quit'
          when 'system'
          end
          puts "= Connections ="
          ap @connections
        end
      end
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

chat_server = ChatServer.new( 4980 ).run()

