#include "libgc.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <assert.h>
#include <sys/time.h>

// The BUFSIZE can be set to whatever will fit in memory.  You will
// get the right result for any nonzero value.
#define BUFSIZE 1048576

int main() {
  FILE *f = fopen("chry_multiplied.fa","r");
  assert(f != NULL);

  // Create Futhark context.  The cache file is to store compiled GPU
  // kernels and such - all it does is speed up the startup.
  struct futhark_context_config *cfg = futhark_context_config_new();
  futhark_context_config_set_cache_file(cfg, "futhark/cache.bin");
  struct futhark_context *ctx = futhark_context_new(cfg);

  // Find the file size.
  fseek(f, 0, SEEK_END);
  ssize_t n = ftell(f);
  rewind(f);

  // Memory-map the file.  This hopefully allows the creation of the
  // Futhark array to happen with only one copy from disk, instead of
  // two.
  char *data = mmap(NULL, n, PROT_READ, MAP_SHARED, fileno(f), 0);
  assert(data != MAP_FAILED);

  fclose(f); // Not needed anymore.

  struct futhark_opaque_summary *state;
  futhark_entry_init(ctx, &state);

  // Iterate through the memory-mapped file in BUFSIZE chunks.
  size_t i = 0;
  while (n > 0) {
    // Make a Futhark array for the chunk.
    int chunksize = n > BUFSIZE ? BUFSIZE : n;
    struct futhark_u8_1d *str = futhark_new_u8_1d(ctx, data+i, chunksize);
    i += chunksize;
    n -= chunksize;

    // Process it.
    struct futhark_opaque_summary *new_state;
    futhark_entry_gc_chunk(ctx, &new_state, state, str);
    futhark_free_opaque_summary(ctx, state);
    state = new_state;
    futhark_free_u8_1d(ctx, str);
  }

  double res;
  futhark_entry_summary_res(ctx, &res, state);
  futhark_context_sync(ctx);
  printf("%.10f\n", res);

  futhark_free_opaque_summary(ctx, state);
  futhark_context_free(ctx);
  futhark_context_config_free(cfg);

  return 0;
}
