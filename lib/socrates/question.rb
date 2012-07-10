abort unless Socrates.is_a? Class

class Socrates::Question
  def initialize(text, correct_answer)
    @text, @correct_answer = text, correct_answer
  end

  def validate
    @response.strip != ""
  end

  def right?
    @response == @correct_answer
  end

  def wrong?
    @response != @correct_answer
  end

  def record_stats
    # Thru abstracted data store
  end
end
