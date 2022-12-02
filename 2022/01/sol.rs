use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    let mut packs: Vec<i32> = vec![];
    if let Ok(lines) = read_lines("input.txt") {
        let mut sum: i32 = 0;
        for line in lines {
            let sline: String = line.unwrap();
            if sline.is_empty() {
                packs.push(sum);
                sum = 0;
                continue
            } 

            sum += sline.parse::<i32>().unwrap();
        }
    }

    // sort in reverse
    packs.sort_by(|a, b| b.cmp(a));

    println!("Part 1: {}", packs[0]);
    println!("Part 2: {}", packs[0]+ packs[1] + packs[2]);
}

// shamelessly yoinked from Rust By Example (https://doc.rust-lang.org/rust-by-example/std_misc/file/read_lines.html)
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
