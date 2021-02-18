use std::fs::File;
use std::io::{BufReader};
use bstr::io::BufReadExt;

fn main() {
    let filename = "Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa";
    
    let mut cc: [u32; 256] = [0; 256];
    // Open the file in read-only mode (ignoring errors).
    let file = File::open(filename).unwrap();
    let reader = BufReader::new(file);

    // Read the file line by line using the lines() iterator from std::io::BufRead.
    reader.for_byte_line( |line|  {
        if line.first() == Some(&b'>') {
            return Ok(true)
        }
        for c in line { cc[*c as usize] += 1; }
	Ok(true)
    }).unwrap();
    let gc = cc[b'G' as usize] + cc[b'C' as usize];
    let at = cc[b'A' as usize] + cc[b'T' as usize];
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
