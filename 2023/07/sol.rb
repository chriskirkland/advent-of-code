# https://adventofcode.com/2022/day/7
$data = File.read("input.txt").split("\n")

$type_ranks = [[5], [4, 1], [3, 2], [3, 1, 1], [2, 2, 1], [2, 1, 1, 1], [1, 1, 1, 1, 1]]
$p1_card_ranks = ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
$p2_card_ranks = ["A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J"]

class Hand
    attr_reader :signature
    def initialize(cards, wilds: false)
        card_ranks = wilds ? $p2_card_ranks : $p1_card_ranks

        @cards = cards
        freq = cards.chars.uniq.map { |c| [c, cards.count(c)] }.to_h
        type = freq.values.sort.reverse

        wild_count = freq.fetch("J", 0)
        if wilds && wild_count > 0 && wild_count < 5
            type.delete_at(type.find_index(wild_count))
            type[0] += wild_count
        end

        # calculate signature for each comparison (smaller signature = better hand)
        @signature = $type_ranks.find_index type
        cards.chars.each do |c|
            @signature *= card_ranks.size
            @signature += card_ranks.find_index(c)
        end
    end

    def to_s
        @cards
    end
end

def score(game)
    game = game.sort_by { |h| h[0].signature }.reverse
    game.map.with_index { |h, i| h[1] * (i+1) }.sum
end

p1_game = $data.map do |line| 
    [Hand.new(line[0..4]), line[6..line.size-1].to_i]
end
puts "p1: #{score(p1_game)}"

p2_game = $data.map do |line| 
    [Hand.new(line[0..4], wilds: true), line[6..line.size-1].to_i]
end
puts "p2: #{score(p2_game)}"