require 'pp'

class Socrates::Question
  def ask          # GUI would just grab @text...
    puts @text
    get_response
  end

  def get_response
    @response = gets.chomp
    raise unless validate
  rescue
    puts "Empty response!"
    retry
  end

  def report
    if right?
      puts "Right!"
    else
      puts "Wrong - answer was #@correct_answer"
    end
    puts
  end
end

############

class Socrates::Session
  def select_topic
    root = Socrates::TopicStore::Root
    node = root
    loop do
      list = node.topics
      puts "#{node.desc}  (#{node.path})\n "
      puts "    0. Previous level" unless node == root
      list.each_with_index do |topic, i|
        flag = topic.children.empty? ? " " : "*"
        puts "  #{flag} #{i+1}. #{topic.name}"
      end
      STDOUT.print "\n    Choice = "
      STDOUT.flush
      choice = gets.to_i - 1  # back to 0-based
      if choice == -1
        node = node.parent
      else
        node = list[choice]
      end
      break if node.children.empty?
    end
    Topic.current = node
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
