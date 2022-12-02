fn main() {
    let mut packs: Vec<u32> = vec![];
    let input = include_str!("input.txt");

    let mut sum: u32 = 0;
    for line in input.lines() {
        if line.is_empty() {
            packs.push(sum);
            sum = 0;
            continue
        } 

        sum += match line.parse::<u32>() {
            Ok(n) => n,
            Err(err) => {
                panic!("Invalid input line {:?}: {:?}", line, err)
            },
        };
    }
    packs.sort_by(|a, b| b.cmp(a));

    println!("Part 1: {}", packs[0]);
    println!("Part 2: {}", packs[0]+ packs[1] + packs[2]);
}