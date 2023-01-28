-- For each contiguous segment of the file, we construct a "summary
-- tuple" with the following components:
--
-- ...
--
-- The idea is that we can then process an entire file in a
-- divide-and-conquer fashion by splitting it into arbitrary
-- contiguous chunks, compute a summary for each, and then combine the
-- summaries, without worrying about splitting on line boundaries.
-- All we need in order to parallelise it is an associative function
-- for combining summaries.

type count = {gc:i32,total:i32}

def pct (c: count) = f64.i32 c.gc / f64.i32 c.total * 100

def count_add (x: count) (y: count) = {gc=x.gc+y.gc, total=x.total+y.total}

def count0 : count = {gc=0,total=0}

type summary = { befnl: count, aftnl: count, hasnl: bool, comment: bool }

def summary0 = {befnl=count0, aftnl=count0, hasnl=false, comment=false}

def mapop (b: u8) =
  {befnl = match b
           case 'G' -> {gc=1,total=1}
           case 'C' -> {gc=1,total=1}
           case 'A' -> {gc=0,total=1}
           case 'T' -> {gc=0,total=1}
           case _   -> count0,
   aftnl = count0,
   hasnl = b == '\n',
   comment = b == '>'
  }

def redop (x: summary) (y: summary) =
  let join = if x.comment then x.aftnl else x.aftnl `count_add` y.befnl
  in {befnl = if x.hasnl then x.befnl else x.befnl `count_add` join,
      aftnl = if x.hasnl then join `count_add` y.aftnl else y.aftnl,
      hasnl = x.hasnl || y.hasnl,
      comment = y.comment || x.comment && (!y.hasnl)}

def gc (str: []u8) = reduce redop summary0 (map mapop str)

entry init : summary = summary0

entry gc_chunk (s: summary) (str: []u8) : summary = s `redop` gc str

entry summary_res (s: summary) =
  pct (s.befnl `count_add` s.aftnl)
