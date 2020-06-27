ch1 = Channel(String).new(16)

gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

spawn do
  gcfile.each_line() do |line|
    ch1.send(line)
  end
  ch1.close
end

at = 0
gc = 0

while line = ch1.receive
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

gcfrac = gc / (gc + at)
puts "GC fraction: #{gcfrac}"

gcfile.close
