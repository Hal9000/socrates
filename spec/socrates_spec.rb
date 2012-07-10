require 'rubygems'
require 'spec_helper'

$: << "lib"
require 'socrates'

describe Socrates do
	subject { Socrates.new }

	it "should have a version" do
		subject.class::VERSION.should_not be_nil
	end

	it "should have a version matching the gemspec" do
    gemspec = eval("$SAFE = 2; " + File.read("../Socrates.gemspec"))
		subject.class::VERSION.should == gemspec.version.to_s
	end

end
