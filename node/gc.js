#!/usr/bin/env node
const fs = require('fs')
const readline = require('readline')

const rl = readline.createInterface({
  input: fs.createReadStream('chry_multiplied.fa')
})

// https://stackoverflow.com/a/60361745 - performance recommendation
function countCharacter (str, char) {
  var start = 0
  var count = 0
  while ((start = str.indexOf(char, start) + 1) !== 0) {
    count++
  }
  return count
}

var gc = 0
var total = 0

rl.on('line', (line) => {
  if (!(line.startsWith('>'))) {
    var countA = countCharacter(line, 'A')
    var countC = countCharacter(line, 'C')
    var countG = countCharacter(line, 'G')
    var countT = countCharacter(line, 'T')
    gc += countC + countG
    total += countA + countC + countG + countT
  }
})

rl.on('close', () => {
  var gcFraction = gc / total
  console.log(gcFraction * 100)
})
