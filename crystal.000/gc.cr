gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

at = 0
gc = 0
misc = 0

cnts = Hash(Char, Pointer(Int32)).new

cnts['A'] = pointerof(at)
cnts['T'] = pointerof(at)
cnts['G'] = pointerof(gc)
cnts['C'] = pointerof(gc)
cnts['N'] = pointerof(misc)
cnts['\n'] = pointerof(misc)

gcfile.each_line() do |line|
    if line.starts_with?('>')
        next
    end
    line.each_char() do |c|
        cnts[c].value += 1
    end
end

at = cnts['A'].value + cnts['T'].value
gc = cnts['G'].value + cnts['C'].value

gcfrac = gc / (gc + at) 

puts "GC fraction: "
puts gcfrac
