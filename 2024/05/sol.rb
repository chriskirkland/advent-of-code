# https://adventofcode.com/2024/day/5
input = ARGV.include?('-s') ?  "sample.txt" : "input.txt"
$rules, $print_data = File.read(input).split("\n\n")

def debug(msg)
    puts msg if ARGV.include?('-v')
end

require 'matrix'
require 'set'

$prints = $print_data.split("\n").map do |instr|
    instr.scan(/\d+/).map(&:to_i).to_a
end

# initialize graph, as adjacency list
V = $prints.flatten.uniq.sort.each.with_index.to_h # vertex --> index
M = Matrix.identity(V.size) # adjacency matrix
$rules.split("\n").each do |rule|
    before, after = rule.split("|").map(&:to_i)
    M[V[before],V[after]] = 1
end.to_s

# get distance weighted adjacency matrix by repeated multiplication...
# how don't we need to do this for part 1? 😅
# M = M ** V.size

$requires = {}
V.keys.product(V.keys).map do |from, to|
    next if to == from || M[V[from], V[to]] == 0
    $requires[to] = Set.new if $requires[to].nil?
    debug "adding requirement for #{from} -> #{to}"
    $requires[to].add(from)
    debug "updated reqs for #{to}: #{$requires[to]}"
end
debug "requires: #{$requires}"
$requires.default = Set.new

# assumes no page is is repeated twice
# something like "A|B" and "B,A,B" would make this return false and is
# (IMO) poorly defined in the problem statement.
def valid?(pages)
    prereqs = Set.new
    pages.reverse.each do |page|
        prereqs.delete(page)
        prereqs |= $requires[page]
        debug "page: #{page}, prereqs: #{prereqs}"
    end
    # do any unsatisfied prereqs appear in list of pages?
    debug "prereqs: #{prereqs}"
    debug "pages: #{pages.to_set}"
    debug "intersection: #{(pages.to_set & prereqs)}"
    (pages.to_set & prereqs).empty?
end

p1 = $prints.map do |pages|
    debug "checking #{pages}"
    unless valid?(pages)
        debug "--- INVALID"
        next 0
    end
    debug "--- VALID"
    pages[pages.size/2]
end.sum
puts p1

p2 = $prints.map do |pages|
    next 0 if valid?(pages)
    spages = pages.sort { |a,b| $requires[a].include?(b) ? 1 : -1 }
    debug "original: #{pages}"
    debug "sorted: #{spages}"
    spages[pages.size/2]
end.sum
puts p2