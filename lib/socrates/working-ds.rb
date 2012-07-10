require './lib/socrates'
abort unless defined?(Socrates) and Socrates.is_a? Class

require 'rubygems'
require 'bundler/setup'
require 'sequel'

###

class TopicNode
  attr_accessor :topic, :parent, :children

  class << self
    attr_accessor :count, :tree
    TopicNode.count = 0
    TopicNode.tree = ::TopicNode.new # (nil, "", nil)
  end

  def initialize(topic=nil, parent=nil, children=[])
    @topic, @parent, @children = topic, parent, children
    @id = (TopicNode.count += 1)
  end
end

###

Topic = Socrates::Topic

class Socrates::Topic
  attr_accessor :children

  def initialize(name, desc, where=nil)   # Move to topics.rb?
    Socrates::Topic.current ||= TopicNode.tree
    where ||= Topic.current
    @name, @desc, @parent = name, desc, where
    @children = []
    @path = (where.path rescue "")  + "/#@name" # Some redundancy
  end

  def Topic.add(name, desc, where=nil)
    Topic.current ||= Topic.new("", "", nil)
    where ||= Topic.current
    puts "Add: #{[name, desc, where].inspect}"
    t = Topic.new(name, desc, where)
    where.children << t
    return t
  end

  def Topic.add!(name, desc, where=Topic.current)
    t = Topic.add(name, desc, where)
    Topic.current = t
  end

  def Topic.lookup(path)
  end

  def path2name(path)
    nums = path.split(".").map {|x| x.to_i }
    names = nums.map {|x| DB[:topics].find(x).next.name }
  end
end

###

class Socrates::DataStore
  def initialize
    @db = ::Sequel.connect("sqlite://socrates.db")
  end

  def method_missing(sym, *args, &block)
p [sym, args]
    @db.send(sym, *args, &block)
  end

  def add(table, obj)
    @db[table].insert(obj)
  end

  def lookup(table, id)
    @db[table][id]
  end
end

if $0 == __FILE__
require 'pp'
sci  = Topic.add("sci", "Science")
comp = Topic.add!("comp", "Computing")
  Topic.add!("ruby", "Ruby")
    Topic.add("basics", "Basics")
    Topic.add("core", "Core")
astro = Topic.add("astro", "Astronomy", sci)

puts "..."
pp comp  # BUG FIXME - computing has no children 
end
