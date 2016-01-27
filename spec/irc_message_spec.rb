require 'spec_helper'

describe IrcMessage do
  describe ".encode" do
    it "can parse a message with a prefix and command" do
      str = ":prefix command\r\n"
      msg = IrcMessage.decode(str)
      expect(msg.prefix).to eq 'prefix'
      expect(msg.command).to eq 'command'
      expect(msg.params).to eq []
    end

    it "can parse a message with just command" do
      str = "command\r\n"
      msg = IrcMessage.decode(str)
      expect(msg.prefix).to eq nil
      expect(msg.command).to eq 'command'
      expect(msg.params).to eq []
    end

    it "can parse a command with simple params" do
      str = "cmd foo bar\r\n"
      msg = IrcMessage.decode(str)
      expect(msg.prefix).to eq nil
      expect(msg.command).to eq 'cmd'
      expect(msg.params).to eq ['foo', 'bar']
    end

    it "will not be screwed up by a space at the end" do
      str = "cmd foo bar \r\n"
      msg = IrcMessage.decode(str)
      expect(msg.params).to eq ['foo', 'bar']
    end

    it "can parse a command with a command with a trailing (colon) parameter" do
      str = "cmd foo bar :banana apple \r\n"
      msg = IrcMessage.decode(str)
      expect(msg.params).to eq ['foo', 'bar', 'banana apple ']
    end
  end

  describe "to_s" do
    it "can assemble a simple command" do
      msg = IrcMessage.new('PONG', 'abc.foo')
      expect(msg.to_s).to eq "PONG abc.foo\r\n"
    end

    it "returns an ASCII 8-BIT string" do
      msg = IrcMessage.new('PONG', 'abc.foo')
      expect(msg.to_s.encoding.to_s).to eq 'ASCII-8BIT'
    end

    it "can assemble a command with a prefix" do
      msg = IrcMessage.new('PONG', 'what')
      msg.prefix = '123'
      expect(msg.to_s).to eq ":123 PONG what\r\n"
    end

    it "can assemble a command with a trailing parameter with spaces" do
      msg = IrcMessage.new('you', 'can', 'have some spaces')
      expect(msg.to_s).to eq "you can :have some spaces\r\n"
    end

    it "can assemble a command with a trailing parameter with a colon" do
      msg = IrcMessage.new('you', 'can', ':startwithcolon')
      expect(msg.to_s).to eq "you can ::startwithcolon\r\n"
    end

    it "complains if the message is longer than 512 bytes" do
      # 512 is the maximum allowed by the spec
      expect { IrcMessage.new('hey', 'a' * 506).to_s }.to_not raise_error
      expect { IrcMessage.new('hey', 'a' * 507).to_s }
        .to raise_error "IRC message was too long (513 bytes, limit is 512)."
    end

    it "complains if a parameter before the last one has spaces" do
      expect { IrcMessage.new('hey', 'no spaces', 'allowed there').to_s }
        .to raise_error "IRC message parameters that are not the last parameter " \
                        "cannot have spaces."
    end

    it "complains if a parameter before the last one starts with colons" do
      expect { IrcMessage.new('hey', ':startwithcolon', 'not allowed there').to_s }
        .to raise_error "IRC message parameters that are not the last parameter " \
                        "cannot start with colons."
    end

    it "complains if a parameter has non-allowed characters" do
      expect { IrcMessage.new('a', "\x00").to_s }
        .to raise_error "Invalid character in IRC message parameter."
      expect { IrcMessage.new('b', "\r").to_s }
        .to raise_error "Invalid character in IRC message parameter."
      expect { IrcMessage.new('c', "\n").to_s }
        .to raise_error "Invalid character in IRC message parameter."
    end

    it "complains if a command has non-allowed characters" do
      expect { IrcMessage.new("\x00").to_s }
        .to raise_error "Invalid character in IRC message command."
      expect { IrcMessage.new(" ").to_s }
        .to raise_error "Invalid character in IRC message command."
      expect { IrcMessage.new(":").to_s }
        .to raise_error "Invalid character in IRC message command."
      expect { IrcMessage.new("\r").to_s }
        .to raise_error "Invalid character in IRC message command."
      expect { IrcMessage.new("\n").to_s }
        .to raise_error "Invalid character in IRC message command."
    end
  end

end
