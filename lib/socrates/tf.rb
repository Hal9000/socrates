class Socrates::TrueFalse
  def self.make(data)
    args = correct = data.values_at(:text, :correct_answer)
    self.new(*args)
  end

  def initialize(text, answer)
    @text, @correct_answer = text, answer
    @choices = [true, false]
  end

  def validate
    true  # for now
  end

  def right?
    @response == @correct_answer
  end
end

