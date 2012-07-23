class Socrates
  Version = '0.0.1'

  class Session               # A drill or Q&A session
  end

  class Question              # Basically fill-in-blank
  end

  class Selection < Question  # select any number of responses
  end

  class MultipleChoice < Selection
  end

  class TrueFalse < MultipleChoice
  end

  class ComplexMultipleChoice < MultipleChoice
  end

  class DynamicQuestion < Question
  end

  class Topic 
  end

  class DataStore  # agnostic of both ORM and database
  end
end

$: << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'socrates/session'
require 'socrates/question'
require 'socrates/selection'
require 'socrates/multiple_choice'
require 'socrates/tf'
require 'socrates/complex_mc'
require 'socrates/dynamic_question'
require 'socrates/topic'
require 'socrates/datastore'

