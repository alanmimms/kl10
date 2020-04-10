'use strict';
const fs = require('fs');

const fName = process.argv[2];

if (!fName) {
  console.error(`Usage: ${process.argv[0]} ${process.argv[1]} xxx.sv`);
  process.exit(-1);
}


const lines = fs.readFileSync(fName).toString();
const uniqueMatches = [... new Set(lines.match(/[A-Z]+\./g))];
const sv = uniqueMatches
      .map(m => m.replace(/\./, ''))
      .sort()
      .map(m => `i${m} ${m}`);
console.log(sv.join(',\n'));
