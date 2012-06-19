# encoding: utf-8

require 'active_support/core_ext'
require 'mysql2'
require 'connection_pool'

module Pipes
  module Model
    class Message

      class MessageNotFoundError < RuntimeError; end
      class InvalidUserError < RuntimeError; end
      class InvalidTimestampError < RuntimeError; end
      class UserNotFoundError < RuntimeError; end

      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @@pool = ConnectionPool.new(size: ChatServer::DB_CONNECTIONS, timeout: ChatServer::DB_TIMEOUT) {
          Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
        }
      end

      def send_text (args)
        @@pool.with_connection do | conn |
          escape_args(args)
          validate_uids(args[:from_uid], args[:to_uid])
          pipe_dbh = Pipe.new()
          pipe = pipe_dbh.find_with_uids(pipe_dbh.concat_uid(args[:from_uid], args[:to_uid]))
          result = conn.query("INSERT INTO message (pipe_id, from_uid, to_uid, timestamp, message) VALUES ('#{pipe[:pipe_id]}', '#{args[:from_uid]}', '#{args[:to_uid]}', '#{args[:timestamp]}', '#{args[:message]}')")

          return result
        end
      end

      def send_img(args)
        @@pool.with_connection do | conn |
          escape_args(args)
          validate_uids(args[:from_uid], args[:to_uid])
          pipe_dbh = Pipe.new()
          pipe = pipe_dbh.find_with_uids(pipe_dbh.concat_uid(args[:from_uid], args[:to_uid]))
          result = conn.query("INSERT INTO message (pipe_id, from_uid, to_uid, timestamp, image_path) VALUES ('#{pipe[:pipe_id]}', '#{args[:from_uid]}', '#{args[:to_uid]}', '#{args[:timestamp]}', '#{args[:image_path]}')")

          return result
        end
      end

      def find_with_pipe_id(pipe_id)
        @@pool.with_connection do | conn |
          results = conn.query("SELECT * FROM message WHERE pipe_id = '#{pipe_id}'")
          return results
        end
      end

      def get_log(args)
        @@pool.with_connection do | conn |
          escape_args(args)
          validate_uids(args[:from_uid], args[:to_uid])
          validate_timestamps(args[:from_timestamp], args[:to_timestamp])
          pipe_dbh = Pipe.new()
          pipe = pipe_dbh.find_with_uids(pipe_dbh.concat_uid(args[:from_uid], args[:to_uid]))
          pipe_id = pipe[:pipe_id]
          results = conn.query("SELECT * FROM message WHERE pipe_id = '#{pipe_id}' AND timestamp > '#{args[:from_timestamp]}' AND timestamp <= '#{args[:to_timestamp]}'")

          if results.count > 0
            return results
          else
            return nil
          end
        end
      end

      def validate_uids (subj, obj)
        @@pool.with_connection do | conn |
          raise InvalidUserError if subj == obj || subj.blank? || obj.blank?
          user = conn.query("SELECT * FROM user WHERE uid IN ('#{subj}', '#{obj}')")
          raise UserNotFoundError if user.count != 2
        end
      end

      def validate_timestamps (timestamp1, timestamp2)
        raise InvalidTimestampError if timestamp1 == timestamp2 || timestamp1.blank? || timestamp2.blank?
        raise InvalidTimestampError unless /^\d{17}$/ =~ timestamp1 && /^\d{17}$/ =~ timestamp2
      end

      def escape_args(args)
        @@pool.with_connection do | conn |
          args.each do |key, value|
            args[key] = conn.escape(value)
          end
        end
      end
    end
  end
end
