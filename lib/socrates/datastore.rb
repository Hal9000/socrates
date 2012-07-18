require './lib/socrates'
abort unless defined?(Socrates) and Socrates.is_a? Class

require 'rubygems'
require 'pp'
require 'bundler/setup'
require 'sequel'

Topic = Socrates::Topic

Yaml = "Yaml"

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
    @xform = {}
    @fields = {}
    metadata_found = nil
    begin
      array = @db[:metadata].all   # raises error if failure
      metadata_found = true
    rescue
      metadata_found = false
    end

    if metadata_found
      array.each do |hash| 
# puts "HASH = #{hash.inspect}"
        table = hash[:table]
        table_sym = table.to_sym
        @xform[table_sym]  = YAML.load(hash[:transform])
        @fields[table_sym] = YAML.load(hash[:fields])
      end
    else
      @db.create_table(:metadata) do
        primary_key :id
        String      :table
        String      :transform
        String      :fields
      end
    end
    @store = self
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

  ##  above largely unused?

  def make_table(*args, others)
# puts "=== make_table: args = #{args.inspect} others = #{others.inspect}"
    table = args.shift.to_s   # in case already sym
    table_sym = table.to_sym
    @fields[table_sym] = args + others.keys
    @xform[table_sym] = {inspect: [], yaml: []}
    xform, fields = @xform, @fields  # because of change in 'self'
    @db.create_table table do
      primary_key table+"_id"
      args.each do |field| 
        if field.to_s =~ /_id$/
          Integer field 
        else
          String field
        end
      end
      others.each_pair do |field, klass|
# puts ">>> others loop - #{[field, klass].inspect}"
        case klass.to_s.to_sym
          when :Integer;  Integer field
          when :String;   String field
          when :Float;    Float field
          when :DateTime; DateTime field
          when :Array, :Hash, :Symbol
            String field
            xform[table_sym][:inspect] << field
          when :Yaml
            String field
# puts "Got here: #{[table_sym, field].inspect}"
            xform[table_sym][:yaml] << field
        end
      end
    end
    # Now save metadata...
    args_hash = {}
    args.each {|arg| args_hash.update(arg => "String") }
    args = args_hash.update(others)
    args.each_pair {|k, v| args[k] = v.to_s }
# puts "SAVE table_sym = #{table.inspect}"
# puts "SAVE xform = "
# pp xform
# puts "SAVE xform[table_sym] = "
# pp xform[table_sym]
# puts "SAVE fields[table_sym] = "
# pp fields[table_sym]
    @db[:metadata].insert(table: table, transform: xform[table_sym].to_yaml, fields: fields[table_sym].to_yaml)
  end

  def new_topic(name, desc)
    Socrates::Topic.add(name, desc)
  end

  def new_topic!(name, desc)
    Socrates::Topic.add!(name, desc)
  end

  def new_record(table, data)
    data.update(:topic_id => Socrates::Topic.current.id)  # hmm
# puts "NEW REC = #{table} : #{data.inspect}"
# puts "before xform in: data = "
# pp data
# puts "---"
    transform(table, data, :in)  # into db
# puts "---"
# puts "after  xform in: data = "
# pp data
    to_insert = {}
# puts "@fields[table] = #{@fields[table]}"
    @fields[table].each {|fld| to_insert[fld] = data[fld] }
    val = @db[table].insert(to_insert)
puts "**** new_rec returns #{val.inspect}"
    val
  end

  def new_question(text, correct)
    new_record(:question, :text => text, :correct_answer => correct)
  end

  def new_selection(text, choices, correct)
#puts "---- xform = "
#pp @xform
#puts "---"
    ques = new_record(:question, :text => text, :correct_answer => correct, :child => "Selection")
puts "*** ques = #{ques.inspect}"
    new_record(:selection, :question_id => ques, :choices => choices)
  end

  def new_mult_choice(text, choices, correct)
    topic = Socrates::Topic.current
    ques = new_record(:question, :text => text, :correct_answer => correct, :child => "Selection")
    new_record(:selection, :question_id => ques, :choices => choices, :child => "MultipleChoice")
    new_record(:multiple_choice, :question_id => ques)  # redundant database access
  end

  def new_dynamic(source, correct)
    ques = new_record(:question, :text => source, :correct_answer => correct, :child => "DynamicQuestion")
    new_record(:dynamic_question, :question_id => ques)  # redundant database access
#puts "dynamic fields = "
#puts @fields[:dynamic_question]
  end

  def transform(table, data, sym)
# puts "TRANSFORM - #{[table, data.inspect, sym]}"
# puts "XFORM = "
# pp @xform
# puts "XFORM[table] = "
# pp @xform[table]
# x1 = @xform[table]
# puts "x1 = #{x1.inspect}"
# x2 = x1[:inspect]
# puts "x2 = #{x2.inspect}"
    @xform[table][:inspect].each do |fld|
      data[fld] = case sym
        when :in  then data[fld].inspect
        when :out then eval(data[fld])  # unsafe
      end
    end
# x2 = x1[:yaml]
# puts "x2 yaml = #{x2.inspect}"
# puts "*** data = #{data.inspect}"
    @xform[table][:yaml].each do |fld|
# puts "DATA [#{fld.inspect}] = #{data[fld].inspect}"
      data[fld] = case sym
        when :in  then data[fld].to_yaml
        when :out then YAML.load(data[fld])
      end
    end
# puts "*** data = #{data.inspect}"
  end

  def get_inherited(parent_hash, parent_class_name)
    data = parent_hash.dup  # result of lookup on parent table
    table = table_name(parent_class_name)
    parent_id = (table.to_s + "_id").to_sym

    class_name = parent_class_name  # will change in loop
    child = parent_hash[:child]     # will change in loop
    hash = parent_hash              # will change in loop
    transform(table, data, :out)
    loop do  # arbitrary levels of inheritance
puts "**** loop: hash1 = #{hash.inspect}"
      break if child.nil?
      class_name = child
      table = table_name(child)
puts "**** loop: table = #{table.inspect}"
      ds = @db[table]
puts "**** loop: query = #{{parent_id => hash[parent_id]}}"
      hash = ds.filter(parent_id => hash[parent_id]).first
puts "**** loop: hash2 = #{hash.inspect}"
      data.update(hash)
      transform(table, data, :out)  # out from db
      child = hash[:child]
    end
    final_class = Socrates.const_get(class_name)
    obj = final_class.make(data)
    obj
  end

  def get_questions(topic, num=10)
    ds = @db[:question]
    target = topic.id
    subs = topic.children
    target = subs.map {|t| t.id } if subs.any?
    ds = ds.filter(:topic_id => target)
    list = ds.to_a.sort_by { rand }
    list = list[0..num-1]

puts "LIST = "
pp list

    list.map do |hash|
      get_inherited(hash, "Question")
    end
  end

  private 

  def table_name(klass)
    words = klass.to_s.scan(/[A-Z][a-z0-9_]*/)
    words.map! {|w| w.downcase }
    words.join("_").to_sym
  end
end

