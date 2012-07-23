require 'rubygems'
require 'spec_helper'

$: << "lib"
require 'socrates'

describe Socrates::Topic do

  subject { Socrates::TopicStore::Root }
  
  T = Socrates::TopicStore
  Sci = T.add("sci", "Science")

  it "should allow adding a toplevel topic via add"  do
    Sci.class.should == Socrates::Topic
    Sci.parent.should == subject
    Sci.name.should == "sci"
    Sci.desc.should == "Science"
    subject.children.should == [Sci]
    T.lookup("/sci").should == Sci
    T::Root.topics.size.should == 1
    Sci.topics.size.should == 0
  end

end

