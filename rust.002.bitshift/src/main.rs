#![feature(core_intrinsics)]
use std::fs::File;
use std::io::{BufRead, BufReader};

use std::intrinsics::unlikely;

fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut line = Vec::with_capacity(100);
    let mut at = 0;
    let mut gc = 0;
    loop {
        if unlikely(reader.read_until(b'\n', &mut line).expect("error reading") == 0) {
            break;
        }

        if unlikely(line[0] == b'>') {
            line.clear();
            continue;
        }

        // G/C & 10 == 2
        // A/T & 10 == 0
        // N & 10 == 10
        for c in line.iter() {
            gc += (*c & 10 == 2) as u32;
            at += (*c & 10 == 0) as u32;
        }
        line.clear();
    }

    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
