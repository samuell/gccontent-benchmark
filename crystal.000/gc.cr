gcfile = File.new("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")

at = 0
gc = 0

gcfile.each_line() do |line|
    if !line.starts_with?('>')
        line.each_char() do |c|
            if c == 'A' || c == 'T'
                at += 1
            elsif c == 'G' || c == 'C'
                gc += 1
            end
        end
    end
end

gcfrac = gc / (gc + at) 

puts "GC fraction: "
puts gcfrac
