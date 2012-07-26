require 'rubygems'
require 'pp'
require 'bundler/setup'
require 'sequel'

Topic = Socrates::Topic

Yaml = "Yaml"

# data_dir = "#{Socrates::AppRoot}/data"
# Dir.chdir(data_dir)  # so that .db will be placed there

class Socrates::TopicStore
  class << self
    attr_accessor :store  # basically a hash; path=>topic
    attr_accessor :count
  end

  @count = 0

  # First time through, the file may be nonexistent
  @store = YAML.load(File.read(Socrates::AppRoot + "/data/topics.yaml")) rescue {}

  LowerAlphaNum = /[a-z][a-z0-9_]*/
  BadName = Exception.new("Invalid pathname")

  def self.make_root
    t = Topic.allocate
    t.name = "/"
    t.path = "/"
    t.parent = nil
    t.children = []
    t.id = Socrates::TopicStore.count += 1
    Topic.current = t
  end

  Root = (@store["/"] ||= Socrates::TopicStore.make_root)
  
  def self.add(name, desc, parent=Socrates::Topic.current)
    raise BadName unless name =~ LowerAlphaNum || parent.nil?
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

  def self.load(file="#{Socrates::AppRoot}/data/topics.yaml")
    @store = YAML.load(file)
  end

  def self.save(file="#{Socrates::AppRoot}/data/topics.yaml")
    File.open(file, "w") {|f| f.puts @store.to_yaml }
  end

  def to_s
    @desc
  end

  def inspect
    @desc
  end
end

###

class Socrates::DataStore
  def initialize
    if RUBY_PLATFORM == "java"
      prefix = "jdbc:sqlite:"
    else
      prefix = "sqlite://"
    end
    db_string = "#{prefix}data/socrates.db"
    @db = ::Sequel.connect(db_string)
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

# def make_child_table(child, parent, *args, others)
#   # Not implemented yet
# end

  def make_table(table, *args, others)
    unless others.is_a? Hash
      args << others
      others = {}
    end
    table = table.to_s       # probably already was
    table_sym = table.to_sym
    @fields[table_sym] = args + others.keys
    @xform[table_sym] = {:inspect => [], :yaml => []}
    xform, fields = @xform, @fields  # because of change in 'self'
    @db.create_table table_sym do
      primary_key table+"_id"
      args.each do |field| 
        if field.to_s =~ /_id$/
          Integer field 
        else
          String field
        end
      end
      others.each_pair do |field, klass|
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
            xform[table_sym][:yaml] << field
        end
      end
    end
    # Now save metadata...
    args_hash = {}
    args.each {|arg| args_hash.update(arg => :String) }
    args_hash.update(others)
    args_hash.each_pair {|k, v| args_hash[k] = v.to_s.to_sym }
    @db[:metadata].insert(:table => table, :transform => xform[table_sym].to_yaml, 
                          :fields => fields[table_sym].to_yaml)
  end

  def new_topic(name, desc)
    Socrates::Topic.add(name, desc)
  end

  def new_topic!(name, desc)
    Socrates::Topic.add!(name, desc)
  end

  def new_record(table, data)
    data.update(:topic_id => Socrates::Topic.current.id)  # hmm
    transform(table, data, :in)  # into db
    to_insert = {}
    @fields[table].each {|fld| to_insert[fld] = data[fld] }
    @db[table].insert(to_insert)
  end

  def new_question(text, correct)
    new_record(:question, :text => text, :correct_answer => correct)
  end

  def new_selection(text, choices, correct)
    ques = new_record(:question, :text => text, :correct_answer => correct, :child => "Selection")
    new_record(:selection, :question_id => ques, :choices => choices)
  end

  def new_mult_choice(text, choices, correct)
    ques = new_record(:question, :text => text, :correct_answer => correct, :child => "Selection")
    new_record(:selection, :question_id => ques, :choices => choices, :child => "MultipleChoice")
    new_record(:multiple_choice, :question_id => ques)  # redundant database access
  end

  def new_tf(text, correct)
    ques = new_record(:question, :text => text, :correct_answer => correct, :child => "Selection")
    new_record(:selection, :question_id => ques, :choices => [true, false], :child => "MultipleChoice")
    new_record(:multiple_choice, :question_id => ques, :child => "TrueFalse")  # redundant?
    new_record(:true_false, :question_id => ques)  # redundant?
  end

  def new_dynamic(source, correct)
    ques = new_record(:question, :text => source, :correct_answer => correct, :child => "DynamicQuestion")
    new_record(:dynamic_question, :question_id => ques)  # redundant database access
  end

  def transform(table, data, sym)
    @xform[table][:inspect].each do |fld|
      data[fld] = case sym
        when :in  then data[fld].inspect
        when :out then eval(data[fld])  # unsafe
      end
    end
    @xform[table][:yaml].each do |fld|
      data[fld] = case sym
        when :in  then data[fld].to_yaml
        when :out then YAML.load(data[fld])
      end
    end
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
      break if child.nil?
      class_name = child
      table = table_name(child)
      ds = @db[table]
      hash = ds.filter(parent_id => hash[parent_id]).first
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
    subs = topic.descendants
    target = subs.map {|t| t.id } if subs.any?
    ds = ds.filter(:topic_id => target)
    list = ds.to_a.sort_by { rand }
    list = list[0..num-1]

    list.map do |hash|
      get_inherited(hash, "Question")
    end
  end

  def update_stats(qid, outcome)
    stats = @db[:stats]
    stat = stats.filter(:question_id => qid).first
    if stat.nil?
      data = {:question_id => qid, :rights => 0, :wrongs => 0}
      stats.insert(:question_id => qid, :rights => 0, :wrongs => 0) 
      stat = data
    end
    now = Time.now
    which_count = outcome ? :rights : :wrongs
    count = stat[which_count]
    which_stamp = outcome ? :last_right : :last_wrong
    stats.where(:question_id => qid).update(which_count => count + 1, which_stamp => now)
  end

  private 

  def table_name(klass)
    words = klass.to_s.scan(/[A-Z][a-z0-9_]*/)
    words.map! {|w| w.downcase }
    words.join("_").to_sym
  end
end

