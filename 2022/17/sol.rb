# https://adventofcode.com/2022/day/17
DEBUG = true

def debug(s)
    puts s if DEBUG
end

"""
[round 2021] height 2800
[round 2022] height 2803
2802
"""

$moves = File.read("sample.txt").strip.chars

MAX = 10_000
WIDTH = 7
LEFT, RIGHT = "<", ">"

# board is upside down so we flip the pieces
PIECES = [
    [15],
    [2, 7, 2],
    [1, 1, 7],
    [1, 1, 1, 1],
    [3, 3],
].map do |piece|
    width = Math.log2(piece.max).floor + 1
    piece.reverse.map do |row|
        row << (WIDTH-2-width)
    end
end

class Board
    def initialize
        @width = 7
        @grid = Array.new(MAX) { 0 }
        @grid[0] = 127 # 2^7-1
        @npix = 0
        @min_height = 1
    end

    def height
        @min_height = @min_height.upto(MAX).find { |i| @grid[i] == 0 } 
    end

    def next_piece
        n = PIECES[@npix]
        @npix = (@npix + 1) % PIECES.size
        n.dup
    end

    def can_move_left?(piece, pv)
        #debug "can_move_left? #{piece}"
        piece.each_with_index do |row, ix|
            #debug "checking border"
            return false if row & (1 << @width-1) > 0 # hits the boundary
            #debug "checking pieces"
            return false if (row << 1) & @grid[pv+ix] > 0 # impacts an existing piece
        end
        true
    end

    def can_move_right?(piece, pv)
        #debug "can_move_left? #{piece}"
        piece.each_with_index do |row, ix|
            #debug "checking border"
            return false if row & 1 > 0 # hits the boundary
            #debug "checking pieces"
            return false if (row >> 1) & @grid[pv+ix] > 0 # impacts an existing piece
        end
        true
    end

    def can_fall?(piece, pv)
        piece.each_with_index do |row, ix|
            return false if row & @grid[pv-1] > 0 # impacts the piece below
        end
        true
    end

    def do_piece(moves)
        bh = height
        piece, pv = next_piece, bh+3
        debug "adding piece #{piece} (pv=#{pv})"
        #print_rows(*piece)
        print_state(piece: piece, pv: pv)

        while true
            #print_state(piece: piece, pv: pv)

            move = moves.shift
            moves.push move
            debug "  adjusting piece '#{move}' (pv=#{pv})"

            # move because of jet, if possible
            if move == LEFT
                #debug "checking move left"
                if can_move_left?(piece, pv)
                    piece.each_with_index do |row, ix|
                        piece[ix] = row << 1
                    end
                    #debug "moved left #{piece}"
                end
            else
                #debug "checking move right"
                if can_move_right?(piece, pv)
                    piece.each_with_index do |row, ix|
                        piece[ix] = row >> 1
                    end
                    #debug "moved right #{piece}"
                end
            end

            # fall, if possible
            unless can_fall?(piece, pv)
                # place the piece
                debug "placing piece"
                piece.each_with_index do |row, ix|
                    @grid[pv+ix] |= row
                end
                break
            end
            #debug "falling"
            pv -= 1
        end
    end

    def print_rows(*rows)
        rows.each do |row|
            debug "|" + row.to_s(2).rjust(@width, "0").gsub(/0/,".").gsub(/1/,"#") + "|"
        end
    end

    def print_state(piece: [], pv: 0)
        top = [height, pv+piece.size-1].max
        debug "top=#{top}, height=#{height}, pv=#{pv}, piece_height=#{piece.size}"
        pr = Range.new(pv, pv+piece.size-1)
        top.downto(1) do |y|
            if pr.include? y
                print_rows @grid[y] | piece[y-pv] if pr.include? y
            else
                print_rows @grid[y]
            end
        end
        debug "|-------|"
    end
end

board = Board.new

#5.times do |i|
#    debug "=== piece #{i+1} ==="
#    np = board.next_piece
#    board.print_rows(*np)
#    debug
#end

board.print_state
20.times do |i|
    debug "=== round #{i+1}"
    board.do_piece($moves)
    #board.print_state
    puts "[round #{i+1}] height #{board.height}"
end
puts board.height - 1
