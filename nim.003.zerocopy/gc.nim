when true:
  import std/[strutils, memfiles]
  proc process(filename: string) =
    var
      input: MemFile
      totals = 0'u64 # represent A/T and C/G as 32 bit ints combined into a 64 bit int
      value: array[low(char)..high(char), uint64] # adder look up table
    value['A'] = 1
    value['T'] = 1
    value['C'] = 1 shl 32 # add shifted 32 bits left
    value['G'] = 1 shl 32

    input = memfiles.open(filename)
    defer: input.close()
    for slice in memSlices(input):
      let str = cast[cstring](slice.data)
      if slice.size > 0 and str[0] != '>':
        for i in 0..<slice.size:
          totals += value[str[i]]

    let
      at = (totals and 0xFFFFFFFF'u).float # get the A/T 32 bits
      gc = (totals shr 32).float # right shift to get the C/G 32 bits
      gcFraction = gc / (gc + at)
    echo formatFloat(gcFraction * 100, ffDecimal, 4)

  when isMainModule:
    process("chry_multiplied.fa")
