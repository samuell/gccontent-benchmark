gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

at = 0
gc = 0

gcfile.each_line() do |line|
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

gcfile.close()

gcfrac = gc / (gc + at)
puts "GC fraction: #{gcfrac}"
