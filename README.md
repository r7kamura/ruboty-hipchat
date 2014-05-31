# Ruboty::Hipchat
Hipchat adapter for [Ruboty](https://github.com/r7kamura/ruboty).

## Usage
```ruby
# Gemfile
gem "ruboty-hipchat"
```

## ENV
```
HIPCHAT_DEBUG        - Pass `1` to show debug information on stdout (optional)
HIPCHAT_JID          - Account's JID (e.g. 12345_67890@chat.hipchat.com)
HIPCHAT_NICKNAME     - Account's nickname, which must match the name on the HipChat account (e.g. Ruboty)
HIPCHAT_PASSWORD     - Account's password (e.g. xxx)
HIPCHAT_ROOM_ID      - Room ID the robot first logs in (e.g. 12345_room-name@conf.hipchat.com)
```
