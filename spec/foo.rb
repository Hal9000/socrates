require 'rubygems'
obj = eval("$SAFE = 2; " + File.read("../Socrates.gemspec"))

p obj.version.to_s
