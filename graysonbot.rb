require 'openssl'
require 'socket'
$LOAD_PATH << 'lib'
require 'irc_message'

class GraysonBot
  def initialize
    tcp_socket = TCPSocket.new 'irc.greynoi.se', 6697
    @socket = OpenSSL::SSL::SSLSocket.new tcp_socket
  end

  def run
    @socket.connect
    @socket.puts "NICK GraysonBot"
    @socket.puts "USER GraysonBot GraysonBot GraysonBot :DavidEGrayson's bot"
    @socket.puts "JOIN #poundpub"

    while true
      line = @socket.readline("\r\n")
      puts "received: " + line.inspect
      msg = IrcMessage.decode(line)
      handle_message(msg)
    end
  end

  def handle_message(msg)
    if msg.command == 'PING'
      if msg.params.empty?
        # that's weird
      elsif msg.params.size > 1
        # forwarding a PING to another server is not implemented
      else
        send 'PONG', params[1]
      end
    end
  end

  def send(command, *params)
    message = IrcMessage.new(command, *params)
    @socket.puts message
  end
end

bot = GraysonBot.new
bot.run
