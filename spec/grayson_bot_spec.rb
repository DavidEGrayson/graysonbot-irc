require 'spec_helper'

describe GraysonBot do
  let (:socket) { TestSocket.new }

  it 'responds to PING commands' do
    bot = described_class.new(socket)
    bot.handle_line("PING :irc.greynoi.se\r\n")
    expect(socket.prints).to eq ["PONG irc.greynoi.se\r\n"]
  end
end
