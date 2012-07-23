class Socrates::Selection
  def self.make(data)
    args = data.values_at(:text, :choices, :correct_answer)
    self.new(*args)
  end

  def initialize(text, choices, answers)
    @text, @correct_answer = text, answers
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
