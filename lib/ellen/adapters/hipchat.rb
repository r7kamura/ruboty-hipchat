require "timeout"
require "xmpp4r"
require "xmpp4r/muc/helper/simplemucclient"
require "xmpp4r/roster/helper/roster"

module Ellen
  module Adapters
    class Hipchat < Base
      include Mem

      env :HIPCHAT_DEBUG, "Pass `1` to show debug information on stdout (optional)", optional: true
      env :HIPCHAT_JID, "Account's JID (e.g. 12345_67890@chat.hipchat.com)"
      env :HIPCHAT_NICKNAME, "Account's nickname (e.g. Ellen)"
      env :HIPCHAT_PASSWORD, "Account's password (e.g. xxx)"
      env :HIPCHAT_ROOM_ID, "Room ID the robot first logs in (e.g. 12345_room-name@conf.hipchat.com)"

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
        ENV["HIPCHAT_JID"]
      end

      def password
        ENV["HIPCHAT_PASSWORD"]
      end

      def room_id
        ENV["HIPCHAT_ROOM_ID"]
      end

      def nickname
        ENV["HIPCHAT_NICKNAME"]
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
          robot.receive(body: body, source: nickname, command: body.start_with?(prefixed_mention_name))
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

      def prefixed_mention_name
        "@#{mention_name}"
      end

      def mention_name
        Timeout.timeout(3) { roster[jid].attributes["mention_name"] }
      rescue Timeout::Error
        nickname.split(" ").first
      end
      memoize :mention_name

      def roster
        roster = Jabber::Roster::Helper.new(client, false)
        roster.get_roster
        roster.wait_for_roster
        roster
      end
    end
  end
end
