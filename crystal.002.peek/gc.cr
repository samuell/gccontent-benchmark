gcfile = File.new("chry_multiplied.fa")

at = 0
gc = 0

while true
  # Peek the IO's buffer
  peek = gcfile.peek

  # If there's nothing else, we reached the end
  break if peek.empty?

  # If the line starts with '>' it's a comment
  if peek[0] === '>'
    while true
      # See where the line ends
      newline_index = peek.index('\n'.ord)

      # If we find an end, skip until past the newline and continue analyzing
      if newline_index
        gcfile.skip(newline_index + 1)
        break
      end

      # Otherwise we must continue looking for that newline,
      # so we skip the entire peek buffer and read more
      gcfile.skip(peek.size)
      peek = gcfile.peek

      # Maybe we reached the end?
      break if peek.empty?
    end

    # Here we found the newline, so we analyze the next line
    next
  end

  # This is not a comment line so we read until the next line
  while true
    # See where the line ends
    newline_index = peek.index('\n'.ord)

    # How many bytes we need to analyze: either until the newline or the entire buffer
    analyze_size = newline_index || peek.size

    # Analyze the bytes
    peek[0, analyze_size].each do |byte|
      case byte
      when 'A', 'T'
        at += 1
      when 'G', 'C'
        gc += 1
      end
    end

    # If we found a newline, we are done
    if newline_index
      gcfile.skip(newline_index + 1)
      break
    end

    # Otherwise we are still in a non-comment line
    gcfile.skip(peek.size)
    peek = gcfile.peek

    # Maybe we reached the end?
    break if peek.empty?
  end
end

gcfile.close

gcfrac = gc / (gc + at)
puts "GC fraction: #{gcfrac}"
