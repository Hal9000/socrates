class Socrates::MultipleChoice 
  def self.make(data)
    *args = data.values_at(:text, :choices, :correct_answer)
    self.new(*args)
  end

  def initialize(text, choices, correct)
    @text, @correct_answer, @choices = text, correct, choices
  end

  def validate
    true  # for now
  end

  def right?
    @response == @correct_answer  # index
  end
end
