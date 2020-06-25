gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

at = 0
gc = 0

a = 'A'.ord()
t = 'T'.ord()
g = 'G'.ord()
c = 'C'.ord()

gcfile.each_line() do |line|
  if line.starts_with?('>')
    next
  end
  line.each_byte() do |chr|
    case chr
    when a, t
      at += 1
      next
    when g, c
      gc += 1
      next
    end
  end
end

gcfile.close()

gcfrac = gc / (gc + at)
puts "GC fraction: #{gcfrac}"
