# encoding: utf-8

require 'mysql2'
require 'active_support/core_ext'

module Pipes
  module Model
    class Pipe
      class PipeNotFoundError < RuntimeError; end
      class InvalidUserError < RuntimeError; end
      class UserNotFoundError < RuntimeError; end
      
      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @conn = Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
        @pipe_hash = {}
      end

      def create (args)
        validate_uids(args[:subj], args[:obj])
        from, to, uids = escape_uids(args[:subj], args[:obj])

        result = @conn.query("INSERT INTO pipe (from_uid, to_uid, status, uids) VALUES ('#{from}', '#{to}', 0, '#{uids}')")
        return result 
      end

      def approve (args)
        validate_uids(args[:subj], args[:obj])
        from, to, uids = escape_uids(args[:obj], args[:subj])

        found_pipe = find_with_uids(uids)
        result = @conn.query("UPDATE pipe set status = 1 WHERE pipe_id = '#{found_pipe[:pipe_id]}}'")
        return result 
      end
      
      def break(args)
        validate_uids(args[:subj], args[:obj])
        from, to, uids = escape_uids(args[:subj], args[:obj])

        found_pipe = find_with_uids(uids)
        result = @conn.query("UPDATE pipe set status = 2 WHERE pipe_id = '#{found_pipe[:pipe_id]}}'")
        return result 
      end

      def validate_uids (subj, obj)
        raise InvalidUserError if subj == obj || subj.blank? || obj.blank?
        user = @conn.query("SELECT * FROM user WHERE uid IN ('#{subj}', '#{obj}')")
        raise UserNotFoundError if user.count != 2
      end

      def escape_uids(from, to) 
        from = @conn.escape(from)
        to = @conn.escape(to)
        uids = concat_uid(from, to)
        uids = @conn.escape(uids)
        return [from, to, uids]
      end

      def find_with_uid(uid)
        uid = @conn.escape(uid)
        results_from = @conn.query("SELECT * FROM pipe WHERE from_uid = '#{uid}' LIMIT 1")
        results_to = @conn.query("SELECT * FROM pipe WHERE to_uid = '#{uid}' LIMIT 1")
        if results_from.count  > 0
          return results_from.first
        elsif results_to.count > 0
          return results_to.first
        else
          raise PipeNotFoundError
        end
      end

      def find_approved_pipes(uid)
        uid = @conn.escape(uid)
        results = @conn.query("SELECT * FROM pipe WHERE (from_uid = '#{uid}' OR to_uid = '#{uid}') AND status = 1")
        if results.count  > 0
          return results
        else
          raise PipeNotFoundError
        end
      end

      def find_applying_pipes(from_uid)
        from_uid = @conn.escape(from_uid)
        results = @conn.query("SELECT * FROM pipe WHERE from_uid = '#{from_uid}' AND status = 0")
        if results.count  > 0
          return results
        else
          raise PipeNotFoundError
        end
      end

      def find_applied_pipes(to_uid)
        to_uid = @conn.escape(to_uid)
        results= @conn.query("SELECT * FROM pipe WHERE to_uid = '#{to_uid}' AND status = 0")
        if results.count  > 0
          return results
        else
          raise PipeNotFoundError
        end
      end


      def find_with_uids(uids)
        uids = @conn.escape(uids)
        results = @conn.query("SELECT * FROM pipe WHERE uids = '#{uids}' LIMIT 1")
        if results.count  > 0
          return results.first
        else
          raise PipeNotFoundError 
        end
      end

      def concat_uid (uid1, uid2)
        return  uid2 > uid1 ? uid1 + uid2 : uid2 + uid1 
      end
    end
  end
end
 
