import strutils

proc process(filename: string) =
  var
    input: File
    lineBuf = newString(100)
    gcCount = 0
    totalBaseCount = 0

  input = open(filename)
  defer: input.close()
  while input.readLine(lineBuf):
    if lineBuf[0] != '>':
      for letter in lineBuf:
        case letter
        of 'A':
          totalBaseCount += 1
        of 'C':
          gcCount += 1
          totalBaseCount += 1
        of 'G':
          gcCount += 1
          totalBaseCount += 1
        of 'T':
          totalBaseCount += 1
        else:
          discard()

  let gcFraction = gcCount / totalBaseCount
  echo formatFloat(gcFraction * 100, ffDecimal, 4)


when isMainModule:
  process("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")
