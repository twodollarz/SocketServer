#!/usr/bin/ruby

# encoding: utf-8 -*-

require 'rubygems'
require 'socket'
require 'awesome_print'

class ChatServer
  def initialize (port)
    @connections = {}
    @server = TCPServer.new("", port)
    puts "Chat Server started on port" << port.to_s
  end

  def run
    loop do
      Thread.start(@server.accept) do |sock|
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
          when 'send'
            broadcast(key, "#{key}:#{data}")
          when 'sendimg'
            broadcast(key, "#{key}:#{data}")
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
        sock.puts("#{msg}\n")
      end
    end
    puts "= Broadcasting Done ="
  end
end

chat_server = ChatServer.new( 4980 ).run()

