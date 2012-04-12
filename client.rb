#!/home/desk001/.rvm/rubies/ruby-1.9.3-p0/bin/ruby

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

=begin
sock = TCPSocket.open('127.0.0.1', 4980)
key = OPTS[:u]
begin
  received_msg = sock.read_nonblock(1024)
  puts received_msg
rescue SystemCallError
end

loop do
  sent_message = STDIN.gets
  break if sent_message == 'quit'

  sock.puts("#{key}:#{sent_message}")
  sock.flush

  response = sock.readpartial(1024)
  puts(response)
end
=end
  
=begin
while true
  while line = sock.gets
#  puts sock.recv(100)
#  puts sock.gets
    puts line
    if line == "EOF\n" then
      break
    end
  end
  msg = gets
  sock.write("#{key}:#{msg}")
end
sock.close
=end

client.close
