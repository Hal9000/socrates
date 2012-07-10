class Socrates::Topic
  class << self
    attr_accessor :current
  end

  attr_accessor :name, :path, :desc, :children, :parent

  def initialize(name, desc, parent=Socrates::Topic.current)
    @name, @desc = name, desc
    @parent = parent
    @children = []
    if @name == "/"
      @path = "/"
    else
      @path = ""
      @path = parent.path.dup unless parent.path == "/"
      @path << "/" + @name
    end
  end

  def topics
    @children.each {|child| child.parent = self } # dammit...
    @children
  end
end

