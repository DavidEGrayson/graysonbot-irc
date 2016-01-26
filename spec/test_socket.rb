class TestSocket
  attr_reader :prints

  def initialize
    @prints = []
  end

  def print(msg)
    @prints << msg.to_s
  end
end
