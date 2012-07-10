require './lib/socrates'
abort unless defined?(Socrates) and Socrates.is_a? Class

require 'rubygems'
require 'bundler/setup'
require 'sequel'

Topic = Socrates::Topic

class Socrates::TopicStore
  class << self
    attr_accessor :store  # basically a hash; path=>topic
  end

  @store = YAML.load(File.read("topics.yaml")) rescue {}
# @store.each_pair {|path, topic| puts "#{path} is child of #{topic.parent.pathname rescue 'root'}" }

  LowerAlphaNum = /[a-z][a-z0-9_]*/
  BadName = Exception.new("Invalid pathname")
  
  def self.add(name, desc, parent=Socrates::Topic.current)
    raise BadName unless name =~ LowerAlphaNum || parent.nil?
# puts "Creating: #{[name, desc, (parent.name rescue 'Root')].inspect}"
    topic = Topic.new(name, desc, parent)
    parent.children << topic unless parent.nil?
    @store[topic.path] = topic    
  end

  def self.add!(name, desc, parent=Socrates::Topic.current)
    topic = add(name, desc, parent)
    Topic.current = topic
  end

  def self.valid_path?(path)
    return true if path == "/" 
    return false if path[0] != "/"
    names = path[1..-1].split("/")
    return false if names.empty?
    names.each {|name| return false unless name =~ LowerAlphaNum }
    return true
  end

  def self.lookup(path)
    raise BadName unless valid_path?(path)
    @store[path]
  end

  def self.load(file="topics.yaml")
    @store = YAML.load(file)
  end

  def self.save(file="topics.yaml")
    File.open(file, "w") {|f| f.puts @store.to_yaml }
  end

  Root = @store["/"] || Socrates::TopicStore.add!("/", "")
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

  def new_topic(name, desc)
    Socrates::Topic.add(name, desc)
  end

  def new_topic!(name, desc)
    Socrates::Topic.add!(name, desc)
  end

  def new_question(text, correct)
    topic = Socrates::Topic.current.path
    @db[:questions].insert(topic: topic, text: text, correct_answer: correct)
    # child will be nil - no inheritance
  end
end

