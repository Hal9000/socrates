abort unless Socrates.is_a? Class

class Socrates::Selection
  def self.make(data)
    text, choices, correct = data.values_at(:text, :choices, :correct_answer)
    self.new(text, choices, correct)
  end

  def initialize(text, choices, answers)
    @text, @correct_answer = text, eval(answers)
    choices = choices.dup
    sep = choices.slice!(0)
    @choices = choices.split(sep)
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
