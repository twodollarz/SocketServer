#!/usr/bin/ruby

# encoding: utf-8

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "model"))

require 'server'

chat_server = ChatServer.new( 4980 ).run()
