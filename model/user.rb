# encoding: utf-8

require 'mysql2'
require 'uuidtools'

module Pipes
  module Model
    class User

      class DuplicatedUserError < RuntimeError; end
      class UnknownColumnError < RuntimeError; end
      class UserNotFoundError < RuntimeError; end
    
      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @conn = Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
        @user_hash = {}
      end

      def create(user)
        unless duplicated_udid?(user[:udid]) 
          uuid = @conn.escape(UUIDTools::UUID.random_create.to_s)
          udid = @conn.escape(user[:udid])
          @conn.query("INSERT INTO user (uuid, udid, userid) VALUES ('#{uuid}', '#{udid}', '#{uuid}')")
          @user_hash =  { :uuid => uuid, :udid => user[:udid] }
          return @user_hash 
        else
          raise DuplicatedUserError
        end
      end

      def set( uuid, args )
        key = @conn.escape(args[:key])
        value = @conn.escape(args[:value])
        raise UserNotFoundError unless exists?(uuid)
        if %w(userid nickname tel faceimage_path).include?(key)
          raise DuplicatedUserError if key == 'userid' && duplicated_userid?(value)
          @conn.query("UPDATE user set #{key} = '#{value}' WHERE uuid = '#{uuid}'")
        else
          raise UnknownColumnError 
        end
        value = @conn.escape(args[:value])
      end

      def duplicated_udid?(udid)
        udid = @conn.escape(udid)
        results = @conn.query("SELECT * FROM user WHERE udid = '#{udid}'")
        return results.count > 0 ? true : false
      end
      def duplicated_userid?(userid)
        userid = @conn.escape(userid)
        results = @conn.query("SELECT * FROM user WHERE userid = '#{userid}'")
        return results.count > 0 ? true : false
      end

      def exists?(uuid)
        uuid = @conn.escape(uuid)
        results = @conn.query("SELECT * FROM user WHERE uuid = '#{uuid}'")
        return results.count > 0 ? true : false
      end

      def find(uuid)
        uuid = @conn.escape(uuid)
        results = @conn.query("SELECT * FROM user WHERE uuid = '#{uuid}' LIMIT 1")
        if results.count > 0
          return results.first
        else
          raise UserNotFoundError 
        end
      end

      def find_with_userid (nickname)
      end
    end
  end
end

