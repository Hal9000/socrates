require 'rubygems'
require 'spec_helper'

$: << "lib"
require 'socrates'

describe Socrates::TopicStore do
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

