class IrcMessage
  attr_accessor :prefix
  attr_accessor :command
  attr_accessor :params

  def self.decode(str)
    message = new
    message.initialize_from_str(str)
    message
  end

  def initialize(command = nil, *params)
    @command = command
    @params = params
  end

  def initialize_from_str(str)
    str = str.chomp  # remove line ending

    pos = 0

    # Check for a prefix
    if str[pos] == ':'
      pos += 1
      md = str.match(/([^ ]+)/, pos) or fail "Could not parse message prefix."
      @prefix = md[1].freeze
      pos = md.offset(0)[1]
    end

    # Get the command
    md = str.match(/([^ ]+)/, pos) or fail "Could not parse message command."
    @command = md[1].freeze
    pos = md.offset(0)[1]

    # Get the params
    @params = []
    while md = str.match(/([^ ]+)/, pos)
      param = md[1].freeze
      if param[0] == ':'
        # the rest of the string is a trailing parameter
        @params << str[(md.offset(1)[0] + 1)..-1]
        break
      else
        # get a normal parameter
        @params << md[1].freeze
        pos = md.offset(0)[1]
      end
    end
    @params.freeze
  end

  def to_s
    validate_contents!

    str = "".force_encoding("ASCII-8BIT")
    str << ":#{prefix} " if prefix
    str << "#{command} "

    if !params.empty?
      if params.last == nil
        raise 'wtf ' + params.inspect
      end
      if params.last.include?(' ') || params.last[0] == ':'
        *normal_params, trailing_param = params
      else
        normal_params = params
      end

      str << normal_params.join(' ')

      str << ' :' + trailing_param if trailing_param
    end

    str << "\r\n"

    if str.bytesize > 512
      raise "IRC message was too long (513 bytes, limit is 512)."
    end

    str
  end

  private

  def validate_contents!
    if prefix
      # TODO: validate prefix
    end

    if !command.is_a?(String)
      raise "IRC message command must be a string, got a #{command.class}."
    end

    if command.include?("\x00") || command.include?(" ") ||
       command.include?(":") || command.include?("\r") || command.include?("\n")
      raise "Invalid character in IRC message command."
    end

    params.each do |param|
      if !param.is_a?(String)
        raise "IRC message parameters must be strings, got a #{param.class}."
      end

      # IRC spec says only certain characters are allowed; I am not
      # sure how people use Unicode in practice.

      if param.include?("\x00") || param.include?("\r") || param.include?("\n")
        raise "Invalid character in IRC message parameter."
      end
    end

    params[0..-2].each do |param|
      if param.include?(' ')
        raise "IRC message parameters that are not the last parameter " \
              "cannot have spaces."
      end

      if param[0] == ':'
        raise "IRC message parameters that are not the last parameter " \
              "cannot start with colons."
      end
    end
  end
end
