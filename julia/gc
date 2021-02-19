#!/usr/bin/env julia

function main()
    values = zeros(UInt64, 256)
    values[UInt8('A')+1] = values[UInt8('T')+1] = 1
    values[UInt8('G')+1] = values[UInt8('C')+1] = 1 << 32
    
    input = open("chry_multiplied.fa")
    buflen = 4096
    buf = zeros(UInt8, buflen)

    n = readbytes!(input, buf, buflen)

    count = UInt64(0)
    mask = UInt64(0)
    while n > 0
        if n < buflen
            resize!(buf, n)
        end

        for c in buf
            if c == UInt8('\n')
                mask = ~UInt64(0)
            elseif c == UInt8('>')
                mask = UInt64(0)
            else
                count += mask & @inbounds values[c+1]
            end
        end

        n = readbytes!(input, buf, buflen)
    end

    at_count = count & 0xffffffff
    gc_count = count >> 32

    gc = gc_count / (gc_count + at_count)
    println(gc)
end

main()

