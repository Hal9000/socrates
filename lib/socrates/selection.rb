abort unless Socrates.is_a? Class

class Socrates::Selection
  def self.make(data)
    text, choices, correct = data.values_at(:text, :choices, :correct_answer)
#   correct = YAML.load(correct) if correct.is_a? String
#   choices = YAML.load(choices) if choices.is_a? String
    self.new(text, choices, correct)
  end

  def initialize(text, choices, answers)
    @text, @correct_answer = text, answers
#   correct = YAML.load(correct) if correct.is_a? String
#   choices = YAML.load(choices) if choices.is_a? String
    @choices = choices
    @choice_hash = {}
    @choices.each {|key| @choice_hash[key] = key.to_s }
  end

  def validate
    true  # for now
  end

  def right?
    @response.sort == @correct_answer.sort  # index list
  end

end
