#![feature(slice_internals)]
use std::fs::File;
use std::io::{BufReader, Read};

use core::slice::memchr;

const VALUE: [u64; 256] = {
    let mut array = [0u64; 256];
    array[b'A' as usize] = 1;
    array[b'T' as usize] = 1;
    array[b'G' as usize] = 1 << 32;
    array[b'C' as usize] = 1 << 32;
    array
};

const CHUNKSIZE: usize = 16;

fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut totals = 0u64;

    let mut buffer = [0; 32768];
    let mut inheader = true;

    'reader: loop {
        if reader.read(&mut buffer).expect("Read error") == 0 {
            break;
        }

        let mut stop = 0;
        loop {
            let offset = if inheader {
                match memchr::memchr(b'\n', &buffer[stop..buffer.len()]) {
                    Some(pos) => {
                        inheader = false;
                        stop + pos + 1
                    }
                    None => continue 'reader,
                }
            } else {
                0
            };

            stop = match memchr::memchr(b'>', &buffer[offset..buffer.len()]) {
                Some(pos) => offset + pos,
                None => buffer.len(),
            };

            // Loop unroll
            let mut chunker = buffer[offset..stop].chunks_exact(CHUNKSIZE);
            while let Some(chars) = chunker.next() {
                totals += chars.iter().map(|b| VALUE[*b as usize]).sum::<u64>();
            }

            for c in chunker.remainder() {
                totals += VALUE[*c as usize];
            }

            if stop == buffer.len() {
                break;
            }
            inheader = true;
        }
    }

    let at = totals & 0xFFFFFFFF;
    let gc = totals >> 32;
    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
