use std::fs::File;
use std::io::{BufRead, BufReader};
use bstr::io::BufReadExt;

fn main() {
    let filename = "Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa";

    // Open the file in read-only mode (ignoring errors).
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);

    let mut at = 0;
    let mut gc = 0;
    // Read the file line by line using the lines() iterator from std::io::BufRead.
    reader.for_byte_line( |line|  {
        if line.first() == Some(&b'>') {
            return Ok(true)
        }
        for c in line {
            match c {
                b'G' => gc += 1,
                b'C' => gc += 1,
                b'A' => at += 1,
                b'T' => at += 1,
                _ => (),
            }
        }
	Ok(true)
    });
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
