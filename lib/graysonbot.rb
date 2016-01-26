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
        send 'PONG', msg.params[1]
      end
    end
  end

  def send(command, *params)
    message = IrcMessage.new(command, *params)
    @socket.print message
  end
end
