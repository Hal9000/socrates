abort unless Socrates.is_a? Class

class Socrates::Session
  def initialize
    @store = Socrates::DataStore.new
  end

  def get_questions(*args)
    @store.get_questions(*args)
  end
  
  def select_topic
    # UI-dependent
  end

  def session_report
    # UI-dependent
  end
end
