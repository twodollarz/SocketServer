#!/usr/bin/ruby

require 'rubygems'
require 'socket'
require 'awesome_print'
require 'optparse'

opt = OptionParser.new

OPTS = {}
opt.on('-v') {|v| OPTS[:v] = v}
opt.parse!(ARGV)

client = TCPSocket.open('127.0.0.1', 4980)
puts "Examples)"
puts "20111231235959999:9999-9999-9999-9999:reg:f-kid"

=begin
puts "Format)"
puts "[timestamp]:[uid / udid]:[cmd]:[obj1]:[obj2]"
puts "  cmd => reg / set / apply / approve / break / sendtext / sendimg / online"
puts ""
puts "[timestamp]:[uid / udid]:[cmd]:[obj1]:[obj2]"
puts "Examples)"
puts "20111231235959999:9999-9999-9999-9999:reg:f-kid"
puts "20111231235959999:f-kid:set:tel:09012345678"
puts "20111231235959999:f-kid:apply:foobar"
puts "20111231235959999:f-kid:sendtext:foobar:Hello, Foobar!"
puts "20111231235959999:f-kid:sendimg:foobar:QUJDREVGRw=="
puts "20111231235959999:f-kid:online:foobar:20111201000000000"
puts ""
=end

loop do
  sockets = IO.select([client, STDIN])[0]
  sockets.each do |socket|
    case socket
    when STDIN
      cmd = STDIN.gets
      break if cmd == 'quit'
      
      client.puts("#{cmd}")
      client.flush
    when TCPSocket
      received_msg = client.read_nonblock(1024)
      if OPTS[:v]
        puts " > #{received_msg}"
      end
    end
  end
end

client.close
