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

def count_add (x: count) (y: count) = {gc=x.gc+y.gc, total=x.total+y.total}

def count0 : count = {gc=0,total=0}

type summary = { befnl: count, aftnl: count, hasnl: bool, comment: bool }

def summary0 = {befnl=count0, aftnl=count0, hasnl=false, comment=false}

def mapop (c: u8) =
  let hasnl = c == '\n'
  let comment = c == '>'
  let (befnl,aftnl) =
  match c
     case '>' -> (count0,count0)
     case 'G' -> ({gc=1,total=1},count0)
     case 'C' -> ({gc=1,total=1},count0)
     case 'A' -> ({gc=0,total=1},count0)
     case 'T' -> ({gc=0,total=1},count0)
     case _   -> (count0,count0)
  in {befnl,aftnl,hasnl,comment}

def redop (x: summary) (y: summary) =
  let aftnl =
    if x.comment then count_add x.aftnl y.aftnl
    else x.aftnl `count_add ` y.befnl `count_add` y.aftnl
  in {hasnl=x.hasnl || y.hasnl,
      befnl=x.befnl,
      aftnl,
      comment=y.comment || x.comment && (!y.hasnl)}

def gc (str: []u8) = reduce redop summary0 (map mapop str)

entry init : summary = summary0

entry gc_chunk (s: summary) (str: []u8) : summary = s `redop` gc str

entry summary_res (s: summary) =
  let {gc,total} = s.befnl `count_add` s.aftnl
  in f64.i32 gc / f64.i32 total * 100

-- ==
-- input @ chry_multiplied.in
