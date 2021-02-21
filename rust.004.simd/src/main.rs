#![feature(core_intrinsics)]
use std::fs::File;
use std::io::{BufRead, BufReader};

use std::intrinsics::unlikely;

#[cfg(target_arch = "x86")]
use std::arch::x86::*;
#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;

fn main() {
    let filename = "chry_multiplied.fa";

    let file = File::open(filename).unwrap();
    let mut reader = BufReader::new(file);

    let mut line = Vec::with_capacity(100);

    unsafe {
        let mut at = 0;
        let mut gc = 0;
        let mut vec_at = _mm256_setzero_si256();
        let mut vec_gc = _mm256_setzero_si256();
        let lut = {
            let mut a = 0u64;
            a |= 0b0000_0001u64 << (((b'A' & 0x0F) as u64) * 8);
            a |= 0b0000_0001u64 << (((b'T' & 0x0F) as u64) * 8);
            a |= 0b0001_0000u64 << (((b'C' & 0x0F) as u64) * 8);
            a |= 0b0001_0000u64 << (((b'G' & 0x0F) as u64) * 8);
            _mm256_set_epi64x(0, a as i64, 0, a as i64)
        };
        let lo_mask = _mm256_set1_epi8(0x0Fu8 as i8);
        let hi_mask = _mm256_set1_epi8(0xF0u8 as i8);

        loop {
            if unlikely(reader.read_until(b'\n', &mut line).expect("error reading") == 0) {
                break;
            }

            if unlikely(line[0] == b'>') {
                line.clear();
                continue;
            }

            // only accurately handles lines with length <= 15 * 32
            // can be easily fixed, but may be slower
            debug_assert!(line.len() <= 15 * 32);

            let mut acc = _mm256_setzero_si256();
            let line_ptr = line.as_ptr() as *const __m256i;
            let mut idx = 0;

            while idx < line.len() {
                let mut v = _mm256_loadu_si256(line_ptr.add(idx / 32));
                // a/t increments the low 4 bit int, c/g increments the high 4 bit int
                v = _mm256_shuffle_epi8(lut, v);
                acc = _mm256_add_epi8(acc, v);
                idx += 32;
            }

            vec_at = _mm256_add_epi64(vec_at, _mm256_sad_epu8(_mm256_and_si256(acc, lo_mask), _mm256_setzero_si256()));
            vec_gc = _mm256_add_epi64(vec_gc, _mm256_sad_epu8(_mm256_and_si256(acc, hi_mask), _mm256_setzero_si256()));

            // G/C & 10 == 2
            // A/T & 10 == 0
            // N & 10 == 10
            while idx < line.len() {
                gc += (*line.get_unchecked(idx) & 10 == 2) as u32;
                at += (*line.get_unchecked(idx) & 10 == 0) as u32;
                idx += 1;
            }

            line.clear();
        }

        #[repr(align(32))]
        struct A([u64; 4]);

        let mut at_arr = A([0u64; 4]);
        _mm256_store_si256(at_arr.0.as_mut_ptr() as *mut __m256i, vec_at);

        // c/g count was in the high 4 bit int, so shift them down
        vec_gc = _mm256_srli_epi64(vec_gc, 4);
        let mut gc_arr = A([0u64; 4]);
        _mm256_store_si256(gc_arr.0.as_mut_ptr() as *mut __m256i, vec_gc);

        at += ((at_arr.0[0] + at_arr.0[1]) + (at_arr.0[2] + at_arr.0[3])) as u32;
        gc += ((gc_arr.0[0] + gc_arr.0[1]) + (gc_arr.0[2] + gc_arr.0[3])) as u32;

        let gc_ratio: f64 = gc as f64 / (gc as f64 + at as f64);
        println!("GC ratio (gc/(gc+at)): {}", gc_ratio);
    }
}
