abort unless Socrates.is_a? Class

class Socrates::Question
  def self.make(data)
    text, correct = data.values_at(:text, :correct_answer)
    self.new(text, correct)
  end

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
    ! right?
  end

  def record_stats
    # Thru abstracted data store
  end
end
