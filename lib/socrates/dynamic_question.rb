abort unless Socrates.is_a? Class

class Socrates::DynamicQuestion
  def initialize(source)
    @text, @correct_answer = eval(source) 
  end
end
