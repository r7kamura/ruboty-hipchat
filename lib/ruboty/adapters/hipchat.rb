require "xrc"

module Ruboty
  module Adapters
    class Hipchat < Base
      include Mem

      env :HIPCHAT_JID, "Account's JID (e.g. 12345_67890@chat.hipchat.com)"
      env :HIPCHAT_NICKNAME, "Account's nickname, which must match the name on the HipChat account (e.g. ruboty)"
      env :HIPCHAT_PASSWORD, "Account's password (e.g. xxx)"
      env :HIPCHAT_ROOM_NAME, "Room name ruboty first logs in (e.g. 12345_room_a,12345_room_b)"

      def run
        bind
        connect
      rescue Interrupt
        exit
      end

      def say(message)
        client.say(
          body: message[:code] ? "/quote #{message[:body]}" : message[:body],
          from: message[:from],
          to: message[:original][:type] == "chat" ? message[:to] + "/resource" : message[:to],
          type: message[:original][:type],
        )
      end

      private

      def client
        @client ||= Xrc::Client.new(
          jid: jid,
          nickname: nickname,
          password: password,
          room_jid: room_jids.join(","),
        )
      end

      private

      def jid
        jid = Xrc::Jid.new(ENV["HIPCHAT_JID"])
        jid.resource = "bot"
        jid.to_s
      end

      def room_jids
        room_names.map do |room_name|
          "#{room_name}@conf.hipchat.com"
        end
      end

      def room_names
        ENV["HIPCHAT_ROOM_NAME"].split(",")
      end

      def password
        ENV["HIPCHAT_PASSWORD"]
      end

      def nickname
        ENV["HIPCHAT_NICKNAME"]
      end

      def bind
        client.on_private_message(&method(:on_message))
        client.on_room_message(&method(:on_message))
        client.on_invite(&method(:on_invite))
      end

      def connect
        client.connect
      end

      def on_message(message)
        robot.receive(
          body: message.body,
          from: message.from,
          from_name: username_of(message),
          to: message.to,
          type: message.type,
        )
      end

      def on_invite(message)
        client.join(message.from)
      end

      def username_of(message)
        case message.type
        when "groupchat"
          Xrc::Jid.new(message.from).resource
        else
          client.users[message.from].name
        end
      end
    end
  end
end
