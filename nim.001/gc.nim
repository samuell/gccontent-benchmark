import strutils
import memfiles

proc process(filename: string) =
  var
    input: MemFile
    gc = 0
    at = 0

  input = memfiles.open(filename)
  defer: input.close()
  for line in memfiles.lines(input):
    if line[0] != '>':
      for letter in line:
        case letter
        of 'A':
            at += 1
        of 'T':
            at += 1
        of 'C':
          gc += 1
        of 'G':
          gc += 1
        else:
          discard()

  let gcFraction = gc / (gc + at)
  echo formatFloat(gcFraction * 100, ffDecimal, 4)


when isMainModule:
  process("chry_multiplied.fa")
