abort unless Socrates.is_a? Class

class Socrates::DynamicQuestion
  def self.make(data)
    text = data[:text]
    correct = data[:correct_answer]
    source = <<-EOF
      text = (#{text})
      correct = (#{correct})
      [text, correct]
    EOF
    thread = Thread.new do
      $SAFE = 4  # thread-local
      Thread.current[:return] = eval(source)
    end
    thread.join
    text, correct = thread[:return]
    self.new(text, correct)
  end

  def initialize(text, correct)
    @text, @correct_answer = text, correct
  end
end
