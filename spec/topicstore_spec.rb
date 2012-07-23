require 'spec_helper'

describe Socrates::TopicStore do
  context "when no topics have been added" do
    subject { Socrates::TopicStore }

    it "should have a predefined root" do
      subject::Root.should_not be_nil
    end

    it "should start with an empty root" do
      subject::Root.children.should == []
    end

    it "should have 'current' (topic) defined" do
      Socrates::Topic.current.should == subject::Root
    end

    it "should fail to find anything except / in empty tree" do
      subject.lookup("/").should == subject::Root
      expect { subject.lookup("") }.to raise_error subject::BadName
      expect { subject.lookup("abc") }.to raise_error subject::BadName
      expect { subject.lookup("//") }.to raise_error subject::BadName
      subject.lookup("/abc").should be_nil
      subject.lookup("/abc/def").should be_nil
    end
  end

  describe "#add" do
    let!(:t) { t = Socrates::TopicStore }
    let!(:sci) { sci = t.add("sci", "Science") }

    subject { Socrates::TopicStore::Root }
    
    it "should allow adding a toplevel topic via add"  do
      sci.class.should == Socrates::Topic
      sci.parent.should == subject
      sci.name.should == "sci"
      sci.desc.should == "Science"
      subject.children.should == [sci]
      t.lookup("/sci").should == sci
      t::Root.topics.size.should == 1
      sci.topics.size.should == 0
    end
  end

  describe "Root" do
    describe "when adding multiple toplevel topics" do
      let!(:t) { Socrates::TopicStore }
      let!(:sci) { t.add("sci", "Science") }
      let!(:comp) { t.add("comp", "Computing") }
      let!(:lang) { t.add("lang", "Languages", comp) }
      let!(:popc) { t.add("popc", "Pop Culture and Trivia") }

      subject { Socrates::TopicStore::Root }

    
      it "the root should contain multiple topics"  do
        comp.class.should == Socrates::Topic
        comp.parent.should == subject
        comp.name.should == "comp"
        comp.desc.should == "Computing"
        subject.children.should include comp
        t.lookup("/comp").should == comp
        puts comp.inspect
        comp.topics.size.should == 1
     
        popc.class.should == Socrates::Topic
        popc.parent.should == subject::Root
        popc.name.should == "popc"
        popc.desc.should == "Pop Culture and Trivia"
        subject.children.should include popc
        t.lookup("/popc").should == popc
        popc.topics.size.should == 0
      end
   
      it "should preserve ordering of toplevel topics"  do
        #t::Root.children.should == [sci, comp, popc] 
        subject::Root.children.should == [sci, comp, popc] 
      end

      it "should normally leave 'current' at root"  do
        Socrates::Topic.current.should == t::Root
      end
    end
  end
end

