#![feature(slice_internals)]
use std::io::{BufReader, Read};
use std::{fs::File, io::IoSliceMut};

use core::slice::memchr;

const BUFSIZE: usize = 32768;
fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut at = 0;
    let mut gc = 0;

    let mut buf1 = [0u8; BUFSIZE];
    let mut buf2 = [0u8; BUFSIZE];
    let mut buf3 = [0u8; BUFSIZE];
    let mut buf4 = [0u8; BUFSIZE];
    let mut buf5 = [0u8; BUFSIZE];
    let mut buf6 = [0u8; BUFSIZE];
    let mut buf7 = [0u8; BUFSIZE];
    let mut buf8 = [0u8; BUFSIZE];
    let mut bufs = [
        IoSliceMut::new(&mut buf1),
        IoSliceMut::new(&mut buf2),
        IoSliceMut::new(&mut buf3),
        IoSliceMut::new(&mut buf4),
        IoSliceMut::new(&mut buf5),
        IoSliceMut::new(&mut buf6),
        IoSliceMut::new(&mut buf7),
        IoSliceMut::new(&mut buf8),
    ];
    let mut inheader = true;

    'reader: loop {
        if reader.read_vectored(&mut bufs).expect("Read error") == 0 {
            break;
        }

        for buffer in bufs.iter() {
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
                // Count records
                for c in buffer[offset..stop].iter() {
                    gc += (*c & 10 == 2) as u32;
                    at += (*c & 10 == 0) as u32;
                }

                if stop == buffer.len() {
                    break;
                }
                inheader = true;
            }
        }
    }

    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
