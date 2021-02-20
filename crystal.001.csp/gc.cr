lines_chan = Channel(String).new(16)

# ------------------------------------------------------------------------------
# Loop over the input file in a separate fiber (and thread, if you set the
# CRYSTAL_WORKERS count to something larger than 1), and send its output on a
# channel
# ------------------------------------------------------------------------------
spawn do
  gcfile = File.new("chry_multiplied.fa")
  gcfile.each_line() do |line|
    lines_chan.send(line)
  end
  lines_chan.close
  gcfile.close
end

# ------------------------------------------------------------------------------
# Loop over the lines on the channel in the main thread, and count GC fraction.
# ------------------------------------------------------------------------------
at = 0
gc = 0
while line = lines_chan.receive?
  if line.starts_with?('>')
    next
  end
  line.each_byte() do |chr|
    case chr
    when 'A', 'T'
      at += 1
      next
    when 'G', 'C'
      gc += 1
      next
    end
  end
end

# ------------------------------------------------------------------------------
# Output results
# ------------------------------------------------------------------------------
gcfrac = gc / (gc + at)
puts "GC fraction: #{gcfrac}"
