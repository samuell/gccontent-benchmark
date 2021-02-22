#![feature(slice_internals)]
#[cfg(target_arch = "x86")]
use std::arch::x86::*;
#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;
use std::fs::File;
use std::io::{BufReader, Read};

use core::slice::memchr;

const BUFSIZE: usize = 32768;
const CHUNKSIZE: usize = 32;

/// Sum each adjacent 8bit lane into u64 x 4
#[inline]
unsafe fn hsum_epu8_epu64(v: __m256i) -> __m256i {
    _mm256_sad_epu8(v, _mm256_setzero_si256())
}

/// Sum u64 x 4 -> i64
#[inline]
unsafe fn hsum_epu64_scalar(v: __m256i) -> i64 {
    let lo = _mm256_castsi256_si128(v); // get the lower 8 u16s
    let hi = _mm256_extracti128_si256(v, 1); // get the upper 8 u16
    let sum2x64 = _mm_add_epi64(lo, hi); // narrow to 128

    let hi = _mm_unpackhi_epi64(sum2x64, sum2x64);
    let sum = _mm_add_epi64(hi, sum2x64); // narrow to 64
    _mm_cvtsi128_si64(sum)
}

/// Count AT / GT occurances in buffer.
/// Relies on the fact that `G|C` & 10 == 2, `A|T` & 10 == 0, and `N` & 10 == 10.
/// Ideally the buffershould be a multiple of CHUNKSIZE
#[inline]
fn count_gc_at(buffer: &[u8]) -> (i64, i64) {
    let mut gc = 0;
    let mut at = 0;
    unsafe {
        // Initialize counters
        let mut gc_sums_64 = _mm256_setzero_si256();
        let mut at_sums_64 = _mm256_setzero_si256();
        let mut gc_sums_8 = _mm256_setzero_si256();
        let mut at_sums_8 = _mm256_setzero_si256();
        let zeros = _mm256_setzero_si256();
        let twos = _mm256_set1_epi8(2);
        let tens = _mm256_set1_epi8(10);

        // Create a super chunker of known size so that inner loop can unroll
        let mut superchunker = buffer.chunks_exact(CHUNKSIZE * 16);
        let mut counter = 0;
        while let Some(superchunk) = &superchunker.next() {
            let chunker = superchunk.chunks_exact(CHUNKSIZE);
            for chunk in chunker {
                let v = _mm256_loadu_si256(chunk as *const _ as *const __m256i);
                let bit_and = _mm256_and_si256(v, tens);
                gc_sums_8 = _mm256_sub_epi8(gc_sums_8, _mm256_cmpeq_epi8(bit_and, twos));
                at_sums_8 = _mm256_sub_epi8(at_sums_8, _mm256_cmpeq_epi8(bit_and, zeros));
                // Only sum when we get close to overflowing
                counter += 1;
                if counter == 255 {
                    gc_sums_64 = _mm256_add_epi64(gc_sums_64, hsum_epu8_epu64(gc_sums_8));
                    at_sums_64 = _mm256_add_epi64(at_sums_64, hsum_epu8_epu64(at_sums_8));
                    gc_sums_8 = _mm256_setzero_si256();
                    at_sums_8 = _mm256_setzero_si256();
                    counter = 0;
                }
            }
        }

        // Work out the reminder post super chunking
        let mut chunker = superchunker.remainder().chunks_exact(CHUNKSIZE);
        // let mut chunker = buffer.chunks_exact(CHUNKSIZE);
        let mut counter = 0;
        while let Some(chunk) = chunker.next() {
            let v = _mm256_loadu_si256(chunk as *const _ as *const __m256i);
            let bit_and = _mm256_and_si256(v, tens);
            gc_sums_8 = _mm256_sub_epi8(gc_sums_8, _mm256_cmpeq_epi8(bit_and, twos));
            at_sums_8 = _mm256_sub_epi8(at_sums_8, _mm256_cmpeq_epi8(bit_and, zeros));
            // Only sum when we get close to overflowing
            counter += 1;
            if counter == 255 {
                gc_sums_64 = _mm256_add_epi64(gc_sums_64, hsum_epu8_epu64(gc_sums_8));
                at_sums_64 = _mm256_add_epi64(at_sums_64, hsum_epu8_epu64(at_sums_8));
                gc_sums_8 = _mm256_setzero_si256();
                at_sums_8 = _mm256_setzero_si256();
                counter = 0;
            }
        }

        // horizontal sum the counts
        gc_sums_64 = _mm256_add_epi64(gc_sums_64, hsum_epu8_epu64(gc_sums_8));
        at_sums_64 = _mm256_add_epi64(at_sums_64, hsum_epu8_epu64(at_sums_8));
        gc += hsum_epu64_scalar(gc_sums_64);
        at += hsum_epu64_scalar(at_sums_64);

        // Finally sum up an remaining bytes
        for c in chunker.remainder() {
            gc += (*c & 10 == 2) as i64;
            at += (*c & 10 == 0) as i64;
        }
    }

    (gc, at)
}

fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut at = 0;
    let mut gc = 0;

    let mut buffer = [0u8; BUFSIZE];

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

            let (gc_buf, at_buf) = count_gc_at(&buffer[offset..stop]);
            gc += gc_buf;
            at += at_buf;

            if stop == buffer.len() {
                break;
            }
            inheader = true;
        }
    }

    let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
    println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
}
