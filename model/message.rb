# encoding: utf-8

require 'active_support/core_ext'

module Pipes 
  module Model
    class Message

      class MessageNotFoundError < RuntimeError; end
      class InvalidUserError < RuntimeError; end
      class UserNotFoundError < RuntimeError; end

      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @conn = Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
      end

      def send_text (args)
        escape_args(args)
        validate_uids(args[:from_uid], args[:to_uid])
        pipe_dbh = Pipe.new()
        pipe = pipe_dbh.find_with_uids(pipe_dbh.concat_uid(args[:from_uid], args[:to_uid]))
        result = @conn.query("INSERT INTO message (pipe_id, from_uid, to_uid, timestamp, message) VALUES ('#{pipe[:pipe_id]}', '#{args[:from_uid]}', '#{args[:to_uid]}', '#{args[:timestamp]}', '#{args[:message]}')")

        return result 
      end

      def find_with_pipe_id(pipe_id)
        results = @conn.query("SELECT * FROM message WHERE pipe_id = '#{pipe_id}' LIMIT 1")
        if results.count  > 0
          return results.first
        else
          raise MessageNotFoundError 
        end
      end

      def validate_uids (subj, obj)
        raise InvalidUserError if subj == obj || subj.blank? || obj.blank?
        user = @conn.query("SELECT * FROM user WHERE uid IN ('#{subj}', '#{obj}')")
        raise UserNotFoundError if user.count == 0
      end

      def escape_args(args)
        args.each do |key, value|
          args[key] = @conn.escape(value)
        end
      end

    end
  end
end
