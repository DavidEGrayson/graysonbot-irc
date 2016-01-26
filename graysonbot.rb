require 'openssl'
require 'socket'
$LOAD_PATH << 'lib'
require 'irc_message'

tcp_socket = TCPSocket.new('irc.greynoi.se', 6697)
socket = OpenSSL::SSL::SSLSocket.new(tcp_socket)
bot = GraysonBot.new(socket)
bot.run
