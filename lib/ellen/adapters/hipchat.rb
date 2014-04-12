require "xmpp4r"
require "xmpp4r/muc/helper/simplemucclient"

module Ellen
  module Adapters
    class Hipchat < Base
      include Mem

      EVENT_NAMES = [
        :join,
        :leave,
        :message,
        :private_message,
        :room_message,
        :self_leave,
        :subject,
      ]

      def run
        log
        debug
        bind
        join
        present
        sleep
      rescue Interrupt
        exit
      end

      def say(body, options = {})
        room.say(body)
      end

      private

      def client
        client = Jabber::Client.new(jid)
        client.connect
        client.auth(password)
        client
      end
      memoize :client

      def room
        Jabber::MUC::SimpleMUCClient.new(client)
      end
      memoize :room

      private

      def jid
        ENV["HIPCHAT_JID"] or Ellen.die("HIPCHAT_JID is missing")
      end

      def password
        ENV["HIPCHAT_PASSWORD"] or Ellen.die("HIPCHAT_PASSWORD is missing")
      end

      def room_id
        ENV["HIPCHAT_ROOM_ID"] or Ellen.die("HIPCHAT_ROOM_ID is missing")
      end

      def nickname
        ENV["HIPCHAT_NICKNAME"] or Ellen.die("HIPCHAT_NICKNAME is missing")
      end

      def room_key
        "#{room_id}/#{nickname}"
      end

      def log
        Jabber.logger = Ellen.logger
      end

      def debug
        Jabber.debug = true if ENV["HIPCHAT_DEBUG"]
      end

      def bind
        room.on_message do |time, nickname, body|
          robot.receive(body: body, source: nickname, command: body.start_with?(mention_name))
        end
      end

      def join
        room.join(room_key)
      end

      def present
        client.send(presence)
      end

      def presence
        Jabber::Presence.new.set_type(:available)
      end

      def mention_name
        "@#{nickname.split(" ").first}"
      end
      memoize :mention_name
    end
  end
end
