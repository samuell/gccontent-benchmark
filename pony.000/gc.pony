use "files"

actor Main
  new create(env: Env) =>
    let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end

    var a: USize = 0
    var c: USize = 0
    var g: USize = 0
    var t: USize = 0
    try
      with file = OpenFile(
        FilePath(env.root as AmbientAuth, env.args(1), caps)) as File
      do
        env.out.print(file.path.path)
        for line in file.lines() do
          a = line.count("A")
          c = line.count("C")
          g = line.count("G")
          t = line.count("T")
          var gc: USize = (g + c) / (a + g + c + t)
          if gc > 0 then
              env.out.print(gc.string())
          end
        end
      end
    else
      try
        env.out.print("Couldn't open " + env.args(1))
      end
    end
