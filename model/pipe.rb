# encoding: utf-8

require 'mysql2'

module Pipes
  module Model
    class Pipe
      class PipeNotFoundError < RuntimeError; end
      
      def initialize
        Mysql2::Client.default_query_options.merge!(:symbolize_keys => true)
        @conn = Mysql2::Client.new(:database => "pipes", :host => "localhost", :username => "root")
        @pipe_hash = {}
      end

      def create (args)
        from = args[:from_uid]
        to = args[:to_uid]
        from = @conn.escape(from)
        uids = concat_uid(from, to)
        to = @conn.escape(to)
        uids = @conn.escape(uids)
        result = @conn.query("INSERT INTO pipe (from_uid, to_uid, status, uids) values ('#{from}', '#{to}', 0, '#{uids}')")
        return result 
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
          raise PipeNotFound 
        end
         
      end
      def concat_uid (uid1, uid2)
        return  uid1 > uid2 ? uid1 + uid2 : uid2 + uid1 
      end
    end
  end
end
 
