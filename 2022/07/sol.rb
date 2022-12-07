# https://adventofcode.com/2022/day/7
$data = File.read("input.txt").split("\n")

# represents a directory or file in a filesystem
class Node
  attr_accessor :name
  attr_accessor :parent
  attr_accessor :children

  def initialize(name, size: 0, parent: nil)
    @name = name
    @parent = parent
    @filesize = size
    @children = {}
  end 

  def size
    @size ||= @filesize + @children.map{|_,c| c.size}.sum
    return @size
  end

  def print(level)
    puts "#{"  " * level}#{@name} (#{size})"
    @children.each do |_, child|
      child.print(level + 1)
    end
  end

  def directory?
    @filesize == 0
  end

  def find(&block)
    results = []
    results << self if yield self
    results += @children.map { |_, child| child.find(&block) }.flatten
    results
  end
end

root = Node.new("/")
pwd = root
$data.each do |line|
  if line.start_with? "$ cd .."
    pwd = pwd.parent

  elsif line.start_with? "$ cd "
    name = line.split(" ")[2]
    pwd = pwd.children[name] unless name == "/"

  elsif line.start_with? "dir "
    dir = line.split(" ")[1]
    pwd.children[dir] = Node.new(dir, parent: pwd)

  elsif line.start_with? "$ ls"
    # don't care

  else # this is a file
    size, name = line.split(" ")
    pwd.children[name] = Node.new(name, size: size.to_i, parent: pwd)
  end
end

# part 1
puts root.find { |node|
    node.directory? && node.size < 100_000
}.map(&:size).sum

# part 2
AVAILABLE = 70000000
MIN = 30000000
unused = AVAILABLE - root.size

puts root.find { |node| 
    node.directory? && node.size + unused > MIN
}.map(&:size).min
