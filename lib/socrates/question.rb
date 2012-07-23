class Socrates::Question
  attr_reader :question_id

  def self.make(data)
    qid, *args = data.values_at(:question_id, :text, :correct_answer)
    question = self.new(*args)
    question.instance_eval { @question_id = qid }
    question
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
end
