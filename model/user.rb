# encoding: utf-8

require 'mysql2'
require 'connection_pool'

module Pipes
  module Model
    class User

      class DuplicatedUserError < RuntimeError; end
      class UnknownColumnError < RuntimeError; end
      class UserNotFoundError < RuntimeError; end

      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @@pool = ConnectionPool.new(size: ChatServer::DB_CONNECTIONS, timeout: ChatServer::DB_TIMEOUT) {
          Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
        }
      end

      def create(user)
        @@pool.with_connection do | conn |
          raise DuplicatedUserError if exists?({:column => 'uid', :value => user[:uid]})
          raise DuplicatedUserError if exists?({:column => 'udid', :value => user[:udid]})
          uid = conn.escape(user[:uid])
          udid = conn.escape(user[:udid])
          conn.query("INSERT INTO user (uid, udid) VALUES ('#{uid}', '#{udid}')")
          return { :uid => user[:uid], :udid => user[:udid] }
        end
      end

      def set( uid, args )
        @@pool.with_connection do | conn |
          uid = conn.escape(uid)
          key = conn.escape(args[:key])
          value = conn.escape(args[:value])
          raise UserNotFoundError unless exists?({:column => 'uid', :value => uid})
          if %w(nickname tel faceimage_path device_token).include?(key)
            conn.query("UPDATE user set #{key} = '#{value}' WHERE uid = '#{uid}'")
          else
            raise UnknownColumnError
          end
        end
      end

      def exists?(args)
        @@pool.with_connection do | conn |
          column = conn.escape(args[:column])
          value = conn.escape(args[:value])
          results = conn.query("SELECT * FROM user WHERE #{column} = '#{value}'")
          return results.count > 0 ? true : false
        end
      end

      def find(uid)
        @@pool.with_connection do | conn |
          uid = conn.escape(uid)
          results = conn.query("SELECT * FROM user WHERE uid = '#{uid}' LIMIT 1")
          if results.count > 0
            return results.first
          else
            raise UserNotFoundError
          end
        end
      end
    end
  end
end

