# https://adventofcode.com/2022/day/20
$data = File.read("sample.txt").split("\n").map(&:to_i)
DEBUG = true

def debug(s = "")
    puts s if DEBUG
end

class EncryptedFile
    def initialize(ordered_nodes)
        # retain the original ordering
        @ordered = ordered_nodes

        # build the circular linked list
        copy = ordered_nodes.dup
        @head = copy.shift
        puts "adding #{@head.value}"
        prev = @head
        while copy.length > 0
            this = copy.shift
            puts "adding #{this.value}"
            prev.next, this.prev = this, prev
            prev = this
        end
        @head.prev, prev.next = prev, @head
        puts
    end

    def mix
        @ordered.each do |node|
            nval = node.value
            debug "=== working on #{nval}"
            if nval < 0
                # swap left nval times
                debug "swapping '#{node.value}' left #{nval.abs} time(s)"
                to = node
                nval.abs.times { to = to.prev }

                debug "swapping #{node.value} with #{to.value}"
                node.next, node.prev, to.next, to.prev, to.prev.next, node.next.prev = to, to.prev, node.next, node, node, to
            else
                # swap right nval times
                debug "swapping '#{node.value}' right #{nval.abs} time(s)"
                to = node
                nval.abs.times { to = to.next }

                debug "before swap:"
                debug "swapping #{node.value} with #{to.value}"
                debug "setting #{node.value}.next = #{to.next.value}"
                debug "setting #{node.value}.prev = #{to.value}"
                debug "setting #{to.value}.next = #{node.value}"
                debug "setting #{to.value}.prev = #{node.prev.value}"
                debug "setting #{node.prev.value}.next = #{to.value}"
                debug "setting #{to.next.value}.prev = #{node.value}"
                n, t, np, tn = node.dup, to.dup, node.prev.dup, to.next.dup
                node.prev.next, to.next.prev = t, n
                node.next, node.prev, to.next, to.prev = tn, t, n, np
                #to.next, to, node, node.prev, to, node
                debug "after swap:"
                debug "#{node.value}.next = #{node.next.value}"
                debug "#{node.value}.prev = #{node.prev.value}"
                debug "#{to.value}.next = #{to.next.value}"
                debug "#{to.value}.prev = #{to.prev.value}"
                debug "#{to.prev.value}.next = #{to.prev.next.value}"
                debug "#{node.next.value}.prev = #{node.next.prev.value}"
            end
            print_state
            debug
        end
    end

    def print_state
        vals = [@head.value]
        curr = @head.next
        while curr != @head
            raise "self loop at #{curr.value}" if curr == curr.next
            raise "curr is nil" unless curr
            vals << curr.value
            curr = curr.next
        end
        debug vals.join(", ")
    end
end

class Node
    attr_accessor :value, :next, :prev
    def initialize(value, nxt: nil, prev: nil)
        @value = value
        @next = nxt
        @prev = prev
    end
end

nodes = $data.map { |v| Node.new(v) }
file = EncryptedFile.new(nodes)
file.print_state
puts

file.mix
