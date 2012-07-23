require 'rubygems'
require 'spec_helper'

$: << "lib"
require 'socrates'

describe Socrates do
	subject { Socrates.new }

	it "should have a version" do
		subject.class::Version.should_not be_nil
	end

	it "should have a version matching the gemspec" do
    safety = RUBY_PLATFORM == "java" ? "" : "$SAFE = 2; "
    gemspec = eval(safety + File.read("../Socrates.gemspec"))
		subject.class::Version.should == gemspec.version.to_s
	end

end
