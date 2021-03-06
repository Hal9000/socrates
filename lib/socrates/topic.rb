class Socrates::Topic
  class << self
    attr_accessor :current
  end

  attr_accessor :name, :path, :desc, :children, :parent, :id

  def initialize(name, desc, parent=Socrates::Topic.current)
    @name, @desc = name, desc
    @parent = parent
    @children = []
    if @name == "/"
      @path = "/"
    else
      @path = ""
      @path = (parent.path.dup rescue "") unless parent.path == "/"
      @path << "/" + @name
    end
  end

  def inspect
    @desc || "All topics" # "#@path [#{@children.size}]"
  end

  def to_s
    inspect
  end

  def topics
    @children.each {|child| child.parent = self } # dammit...
    @children
  end

  def descendants
    list = @children
    @children.each {|child| list += child.descendants }
    list
  end
end

