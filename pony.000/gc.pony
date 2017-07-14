use "files"

actor Main
  new create(env: Env) =>
    let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end

    var a: USize = 0
    var c: USize = 0
    var g: USize = 0
    var t: USize = 0
    var frac: F32 = 0
    try
      with file = OpenFile(
        FilePath(env.root as AmbientAuth, "Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa", caps)) as File
      do
        env.out.print(file.path.path)
        for line in file.lines() do
          a = a + line.count("A")
          c = c + line.count("C")
          g = g + line.count("G")
          t = t + line.count("T")
        end
        var at: USize = a + t
        var gc: USize = g + c
        frac = gc.f32() / (gc.f32() + at.f32())
      end
      env.out.print(frac.string())
    else
      try
        env.out.print("Couldn't open " + env.args(1))
      end
    end
