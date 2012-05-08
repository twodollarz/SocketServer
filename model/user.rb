# encoding: utf-8

require 'mysql2'
require 'uuidtools'

module Pipes
  module Model
    class User

      class DuplicatedUserError < RuntimeError; end
    
      def initialize
        @conn = Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
      end

      def create(user)
        unless duplicated?(user) 
          uuid = @conn.escape(UUIDTools::UUID.random_create.to_s)
          udid = @conn.escape(user[:udid])
          @conn.query("INSERT INTO user (uuid, udid, userid) VALUES ('#{uuid}', '#{udid}', '#{uuid}')")
          return { :uuid => uuid, :udid => user[:udid] }
        else
          raise DuplicatedUserError
        end
      end

      def set( args = {} )
        key = @conn.escape(args[:key])
        if (%w(userid, nickname, tel, faceimage_path).include?(key))
          @conn.query("INSERT INTO user (uuid, udid, userid) VALUES ('#{uuid}', '#{udid}', '#{uuid}')")
        else
          raise UnknownColumnError 
        end
        value = @conn.escape(args[:value])
      end

      def duplicated?(user)
        udid = @conn.escape(user[:udid])
        results = @conn.query("SELECT * FROM user WHERE udid = '#{udid}'")
        return results.size > 0 ? true : false
      end
    end
  end
end

