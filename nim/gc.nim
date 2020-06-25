import strutils

proc process(filename: string) =
  var
    input: File
    lineBuf = newString(100)
    gc = 0
    at = 0
    totalBaseCount = 0

  input = open(filename)
  defer: input.close()
  while input.readLine(lineBuf):
    if lineBuf[0] != '>':
      for letter in lineBuf:
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
  process("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")
