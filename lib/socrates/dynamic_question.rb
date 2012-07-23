class Socrates::DynamicQuestion
  def self.make(data)
    text, correct = data.values_at(:text, :correct_answer)
    source = <<-EOF
      text = (#{text})
      correct = (#{correct})
      [text, correct]
    EOF
    thread = Thread.new do
      $SAFE = 4  unless RUBY_PLATFORM == "java" # thread-local
      Thread.current[:return] = eval(source)
    end
    thread.join
    args = thread[:return]
    self.new(*args)
  end

  def initialize(text, correct)
    @text, @correct_answer = text, correct
  end
end
