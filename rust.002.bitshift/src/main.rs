#![feature(core_intrinsics)]
use std::fs::File;
use std::io::{BufRead, BufReader};

use std::intrinsics::unlikely;

const VALUE: [u64; 256] = {
    let mut array = [0u64; 256];
    array[b'A' as usize] = 1;
    array[b'T' as usize] = 1;
    array[b'G' as usize] = 1 << 32;
    array[b'C' as usize] = 1 << 32;
    array
};

fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut totals = 0u64;
    let mut line = Vec::with_capacity(100);
    loop {
        if unlikely(reader.read_until(b'\n', &mut line).expect("error reading") == 0) {
            break;
        }

        if unlikely(line[0] == b'>') {
            line.clear();
            continue;
        }

        for c in line.iter() {
            totals += VALUE[*c as usize];
        }
        line.clear();
    }
    let at = totals & 0xFFFFFFFF;
    let gc = totals >> 32;
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
