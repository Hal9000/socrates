class Socrates::Session
  def initialize
    @store = Socrates::DataStore.new
  end

  def get_questions(*args)
    @store.get_questions(*args)
  end
 
  def update_stats(qid, outcome)
    @store.update_stats(qid, outcome)
  end
  
  def select_topic
    # UI-dependent
  end

  def session_report
    # UI-dependent
  end
end
