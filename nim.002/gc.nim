import strutils
import memfiles

proc process(filename: string) =
  var
    input: MemFile
    totals = uint64(0) # represent A/T and C/G as 32 bit ints combined into a 64 bit int
    value: array[0..256, uint64] # adder look up table
  value['A'.int] = 1.uint64
  value['T'.int] = 1.uint64
  value['C'.int] = 1.uint64 shl 32 # add shifted 32 bits left
  value['G'.int] = 1.uint64 shl 32

  input = memfiles.open(filename)
  defer: input.close()
  for line in memfiles.lines(input):
    if line[0] != '>':
      for letter in line:
        totals += value[letter.int] # get appropriate adder bit

  let
    at = (totals and 0xFFFFFFFF'u).float # get the A/T 32 bits
    gc = (totals shr 32).float # right shift to get the C/G 32 bits
    gcFraction = gc / (gc + at)
  echo formatFloat(gcFraction * 100, ffDecimal, 4)


when isMainModule:
  process("chry_multiplied.fa")
