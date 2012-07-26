require 'pp'

if RUBY_PLATFORM == "java"
  class String
    def ord
      self[0]  # old Ruby 1.8 behavior
    end
  end
end

class Socrates::Question

  BadEntry = Exception.new("Invalid response")

  def ask          # GUI would just grab @text...
    puts @text
    get_response
    report
  end

  def get_response
    @response = gets.chomp
    raise BadEntry unless validate
  rescue BadEntry
    puts "Invalid response!"
    retry
  end

  def report(text_answer=@correct_answer)
    outcome = right?
    if outcome
      puts "Right!"
    else
      puts "Wrong. Correct answer is: #{text_answer}"
    end
    puts
    return outcome
  end

  def update_stats(qid, outcome)
    
  end
end

class Socrates::Selection
  def ask
# puts "Sel ask: @choices = #@choices"
    puts @text
    label = "  a"
    @choices.each do |choice| 
      puts "#{label}. #{choice}" 
      label = label.succ
    end
    print "Choices = "
    STDOUT.flush
    get_response
# puts "correct = #{@correct_answer.inspect}"
    report(@choices.values_at(*@correct_answer).inspect)
  end

  def get_response
    str = gets.chomp
    list = str.scan(/./)
    indices = []
    list.each do |char|
      offset = char[0..0].ord - "a".ord
      indices << offset
    end
    @response = indices
    raise unless validate
  end
end

class Socrates::MultipleChoice
  def ask
    puts @text
    label = "  a"
    @choices.each do |choice| 
      puts "#{label}. #{choice}" 
      label = label.succ
    end
    print "Choice = "
    STDOUT.flush
    get_response
    report(@choices[@correct_answer])
  rescue
    puts "Invalid response..."
    retry
  end

  def validate
    (0..@choices.size-1).include? @response
  end

  def get_response
    str = gets.chomp
    raise unless str.length == 1
    offset = str.ord - "a".ord
    @response = offset
    raise BadEntry unless validate
  end
end

class Socrates::TrueFalse
  def ask
    puts @text
    print "(T/F): "
    STDOUT.flush
    print "Choice = "
    get_response
    report
  rescue BadEntry
    puts "Invalid response..."
    retry
  end

  def validate
    %w[T t F f].include? @response
  end

  def get_response
    str = gets.chomp
    @response = str
    raise BadEntry unless validate
    @response = 
      case str
        when /t/i then true 
        when /f/i then false
      end
# puts "resp = #@response (#{@response.class})"
# puts "choices = #{@choices.inspect}"
  end
end

############

class Socrates::Session
  def select_topic
    root = Socrates::TopicStore::Root
    node = root
    puts "\n  Socrates top level:\n "
    loop do
      list = node.topics
      if node != root
        puts "\n-- #{node.desc}:  #{node.path}\n "
      end
      list.each_with_index do |topic, i|
        more = topic.children.empty? ? "   " : "[+]"
        puts "  #{i+1}  #{topic.desc}   #{more}"
      end
      puts
      puts "  *  All the above topics"
      puts "  b  Back one level" unless node == root
      puts "  q  Quit"

      STDOUT.print "\n    Choice  = "
      STDOUT.flush
      choice = gets.chomp
      case choice
        when /[0-9]+/
          node = list[choice.to_i - 1]
        when '*'
          break   # return node
        when "b"
          node = node.parent
        when "q"
          return nil
      else
        puts "Invalid choice '#{choice}'"
        redo
      end
      break if node.children.empty?
    end
    return node
  end

  def ask_questions(topic, max=10)
    list = get_questions(topic, max)
    @outcomes = {false => 0, true => 0}
    list.each do |question|
      outcome = question.ask
      @outcomes[outcome] += 1
      update_stats(question.question_id, outcome)
    end
  end

  def report
    rights, wrongs = @outcomes.values_at(true, false)
    puts "Session: #{rights} correct, #{wrongs} incorrect"
  end
end

############

# class TF < Question
# 
#   Chars = {"T" => true, "t" => true, "F" => false, "f" => false }
# 
#   def ask
#     puts "T/F: #@text"
#     get_response
#   end
# 
#   def get_response
#     @response = Chars[gets.chomp]
#     raise unless validate
#   rescue
#     puts "Please respond with T or F."
#     retry
#   end
# 
#   def validate
#     ! @response.nil?
#   end
# 
#   def report
#     if right?
#       puts "Right!"
#     else
#       puts "Wrong"
#     end
#     puts
#   end
# 
# end
# 
# 
# ############
# 
# class MultipleChoice < Question    
#   def ask
#     puts @text
#     label = "a"
#     @labels = {}
#     @choices.each do |c| 
#       @labels[label] = c
#       puts "  #{label}. #{c}"
#       label = label.succ
#     end
#     STDOUT.print "=> "
#     STDOUT.flush
#     get_response
#   end
# 
#   def get_response
#     char = gets.chomp
#     @response = @labels[char]
#     raise unless validate
#   rescue
#     puts "#{char} is not one of #{@labels.keys.join(' ')}"
#     retry
#   end
# 
#   def validate
#     ! @response.nil?
#   end
# end
# 
# ############
# 
# class PooledMultipleChoice < MultipleChoice
#   def ask
#     puts @text
#     label = "a"
#     @labels = {}
#     pool = YAML.load(File.read("#{$session.store.real_path(@topic)}/_mcpools/#@pool.yaml"))
#     @choices = pool.choices
#     @choices.each do |c| 
#       @labels[label] = c
#       puts "  #{label}. #{c}"
#       label = label.succ
#     end
#     STDOUT.print "=> "
#     STDOUT.flush
#     get_response
#   end
# 
# end
# 
# ############
# 
# class Computed
# 
#   def ask
#     @text, @correct_answer = eval("lambda { #@code }").call
#     super
#   end
# 
# end
