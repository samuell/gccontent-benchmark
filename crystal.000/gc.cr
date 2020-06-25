gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

at = 0
gc = 0

a = 65_u8
t = 84_u8
g = 71_u8
c = 67_u8

gcfile.each_line() do |line|
  if line.starts_with?('>')
    next
  end
  line.each_byte() do |c|
    case c
    when a, t
      at += 1
      next
    when g, c
      gc += 1
      next
    end
  end
end

gcfrac = gc / (gc + at)

puts "GC fraction: "
puts gcfrac
