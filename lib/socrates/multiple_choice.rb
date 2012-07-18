abort unless Socrates.is_a? Class

class Socrates::MultipleChoice 
  def self.make(data)
    text, choices, correct = data.values_at(:text, :choices, :correct_answer)
#   correct = YAML.load(correct) if correct.is_a? String
#   choices = YAML.load(choices) if choices.is_a? String
    self.new(text, choices, correct)
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
