#!/usr/bin/ruby

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

          case cmd
          when 'reg'
            @connections[key] = sock
          when 'send'
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
      sock.puts(msg) unless key == id 
    end
  end
end

chat_server = ChatServer.new( 4980 ).run()

