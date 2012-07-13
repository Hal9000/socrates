require './lib/socrates'
abort unless defined?(Socrates) and Socrates.is_a? Class

require 'rubygems'
require 'pp'
require 'bundler/setup'
require 'sequel'

Topic = Socrates::Topic

class Socrates::TopicStore
# puts "--- Entering TopicStore class def"
  class << self
    attr_accessor :store  # basically a hash; path=>topic
    attr_accessor :count
  end

  @count = 0

# puts "--- Reading yaml"
  @store = YAML.load(File.read("topics.yaml")) rescue {}
# @store.each_pair {|path, topic| puts "#{path} is child of #{topic.parent.pathname rescue 'root'}" }

  LowerAlphaNum = /[a-z][a-z0-9_]*/
  BadName = Exception.new("Invalid pathname")

# puts "--- Read yaml..."
# puts "--- store ="
# pp @store
  
  def self.make_root
    t = Topic.allocate
    t.name = "/"
    t.path = "/"
    t.parent = nil
    t.children = []
    t.id = Socrates::TopicStore.count += 1
    Topic.current = t
  end

# Root = @store["/"] || Socrates::TopicStore.add!("/", "")
  Root = (@store["/"] ||= Socrates::TopicStore.make_root)
# puts "--- Defined Root..."
# puts "--- store ="
# pp @store
  
  def self.add(name, desc, parent=Socrates::Topic.current)
    raise BadName unless name =~ LowerAlphaNum || parent.nil?
# puts "Creating: #{[name, desc, (parent.name rescue 'Root')].inspect}"
    topic = Topic.new(name, desc, parent)
    topic.id = Socrates::TopicStore.count += 1
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
end

###

class Socrates::DataStore
  def initialize
    @db = ::Sequel.connect("sqlite://socrates.db")
  end

  def method_missing(sym, *args, &block)
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
    topic = Socrates::Topic.current
    @db[:question].insert(:topic_id => topic.id, :text => text, :correct_answer => correct)
    # child will be nil - no inheritance
  end

  def new_selection(text, choices, correct)
    topic = Socrates::Topic.current
    correct = correct.inspect unless correct.is_a? String
    choices = choices.inspect unless choices.is_a? String
    ques = @db[:question].insert(:topic_id => topic.id, :text => text, :correct_answer => correct,
                                  :child => "Selection")
    @db[:selection].insert("question_id" => ques, :choices => choices)
  end

  def new_dynamic(source)
    topic = Socrates::Topic.current
  end

  def get_inherited(parent_hash, parent_class_name)
    data = parent_hash.dup  # result of lookup on parent table
    sym = (table_name(parent_class_name).to_s + "_id").to_sym

    class_name = parent_class_name  # will change in loop
    child = parent_hash[:child]     # will change in loop
    hash = parent_hash              # will change in loop
    loop do  # arbitrary levels of inheritance
      break if child.nil? || child.empty?
      class_name = child
      table = table_name(child)
      ds = @db[table]
      hash = ds.filter(sym => hash[sym]).first
      data.update(hash)
      child = hash[:child]
    end
    final_class = Socrates.const_get(class_name)
    final_class.make(data)
  end

  def get_questions(topic, num=10)
    ds = @db[:question]
    target = topic.id
    subs = topic.children
    target = subs.map {|t| t.id } if subs.any?
    ds = ds.filter(:topic_id => target)
    list = ds.to_a.sort_by { rand }
    list = list[0..num-1]
    
    list.map do |hash|
      get_inherited(hash, "Question")
    end
  end

  private 

  def cjoin(array)
    array.join("|")
  end

  def csplit(string)
    sep = string[0]
    string[1..-1].split(sep)
  end

  def table_name(klass)
    words = klass.to_s.scan(/[A-Z][a-z0-9_]*/)
    words.map! {|w| w.downcase }
    words.join("_").to_sym
  end
end

