# https://adventofcode.com/2024/day/2
$data = File.read("input.txt").split("\n")
reports = $data.map do |line|
    line.scan(/\d+/).map(&:to_i)
end

def gen_diffs(report)
    report.each_cons(2).map { |a, b| b - a }
end

def safe?(diffs)
    (diffs.min > 0 || diffs.max < 0) && diffs.map(&:abs).max <= 3
end

rdiff = reports.map { |r| gen_diffs(r) }
p1 = rdiff.count { |r| safe?(r) }
puts p1

mdiffs = reports.map do |r| 
    0.upto(r.size-1).map do |i|
        nr = r.dup
        nr.delete_at(i)
        gen_diffs(nr)
    end
end
p2 = mdiffs.count do |md|
    md.any? { |r| safe?(r) }
end
puts p2