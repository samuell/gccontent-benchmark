use std::fs::File;
use std::io::{BufRead, BufReader};

const AT: [u8; 256] = {
    let mut array = [0; 256];
    array[b'A' as usize] = 1;
    array[b'T' as usize] = 1;
    array
};
const GC: [u8; 256] = {
    let mut array = [0; 256];
    array[b'G' as usize] = 1;
    array[b'C' as usize] = 1;
    array
};
fn main() {
    let filename = "Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut at = 0;
    let mut gc = 0;
    let mut line = Vec::with_capacity(100);
    loop {
        match reader.read_until(b'\n', &mut line) {
            Ok(0) => break,
            Ok(_) => (),
            Err(e) => panic!("{:?}", e),
        }
        if line[0] == b'>' {
            line.clear();
            continue;
        }

        for c in line.iter() {
            at += AT[*c as usize] as usize;
            gc += GC[*c as usize] as usize;
        }
        line.clear();
    }
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
