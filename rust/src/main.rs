use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let filename = "Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa";

    // Open the file in read-only mode (ignoring errors).
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);

    let mut at = 0;
    let mut gc = 0;
    // Read the file line by line using the lines() iterator from std::io::BufRead.
    for line in reader.lines() {
        let line = line.unwrap(); // Ignore errors.
        if line.starts_with(">") {
            continue;
        }
        for c in line.chars() {
            match c {
                'G' => gc += 1,
                'C' => gc += 1,
                'A' => at += 1,
                'T' => at += 1,
                _ => (),
            }
        }
    }
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
