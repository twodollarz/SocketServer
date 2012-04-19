#!/usr/bin/ruby

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'optparse'

opt = OptionParser.new

OPTS = {}
opt.on('-u VA') {|v| OPTS[:u] = v}
opt.parse!(ARGV)

if OPTS[:u] == nil then
  puts "Usage: ./client -u [user]"
  exit
end

client = TCPSocket.open('127.0.0.1', 4980)
key = OPTS[:u]

loop do
  sockets = IO.select([client, STDIN])[0]
  sockets.each do |socket|
    case socket
    when STDIN
      sent_message = STDIN.gets
      break if sent_message == 'quit'
      client.puts("#{key}:#{sent_message}")
      client.flush
    when TCPSocket
      received_msg = client.read_nonblock(1024)
      puts "= Received ="
      puts received_msg
    end
  end
end

client.close
