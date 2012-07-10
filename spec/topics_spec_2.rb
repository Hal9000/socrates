require 'rubygems'
require 'spec_helper'

$: << "lib"
require 'socrates'

  T = Socrates::TopicStore
     Sci = T.add("sci", "Science")
     Comp = T.add("comp", "Computing")
       Lang = T.add("lang", "Languages", Comp)
     Popc = T.add("popc", "Pop Culture and Trivia")

describe Socrates::Topic do

  subject { Socrates::TopicStore::Root }
  
  it "should allow adding multiple toplevel topics"  do
    Comp.class.should == Socrates::Topic
    Comp.parent.should == subject
    Comp.name.should == "comp"
    Comp.desc.should == "Computing"
    subject.children.should include Comp
    T.lookup("/comp").should == Comp
    Comp.topics.size.should == 1
 
    Popc.class.should == Socrates::Topic
    Popc.parent.should == subject
    Popc.name.should == "popc"
    Popc.desc.should == "Pop Culture and Trivia"
    subject.children.should include Popc
    T.lookup("/popc").should == Popc
    Popc.topics.size.should == 0
  end
 
  it "should preserve ordering of toplevel topics"  do
    T::Root.children.should == [Sci, Comp, Popc] 
  end

  it "should normally leave 'current' at root"  do
    Socrates::Topic.current.should == T::Root
  end
end

