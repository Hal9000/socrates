abort unless Socrates.is_a? Class

class Socrates::Session
  def initialize
    @store = Socrates::DataStore.new
  end
  
  def select_topic
    # UI-dependent
  end
end
