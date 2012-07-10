class Socrates
  VERSION = '0.0.1'

  class Session               # A drill or Q&A session
  end

  class Question              # Basically fill-in-blank
  end

  class Selection < Question  # select any number of responses
  end

  class SimpleMultipleChoice < Selection
  end

  class TrueFalse < SimpleMultipleChoice
  end

  class ComplexMultipleChoice < SimpleMultipleChoice
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
require 'socrates/simple_mc'
require 'socrates/tf'
require 'socrates/complex_mc'
require 'socrates/topic'
require 'socrates/datastore'

### Remainder of Socrates class

class Socrates

end

