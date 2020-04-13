'use strict';
const fs = require('fs');

const fileName = process.argv[2];
const buf = fs.readFileSync(fileName);
const mem = [];

let minAddr = 0o777777n;
let maxAddr = 0n;
let startInsn, reenterInsn, programVersion;


// Read each IOWD in succession and store loaded data in mem[] as BigInt.
// The last one (with positive LH) is the entry vector:
// [0]: Instr to start
// [1]: Instr to reenter
// [2]: Program version number
for (let wn = 0; !startInsn; ) {
  const w = getW36(buf, wn++);         // Get IOWD header
  let addr = rh(w);
  const nww = lh(w);

  if (nww < 0o400000n) {
    console.log(`Entry vector: IOWD=${octW(w)}`);

    // We're done: This IOWD is the entry vector.
    if (false) {
      startInsn = getW36(buf, wn++);
      console.log(`startInsn: ${octW(startInsn)}`);
      reenterInsn = getW36(buf, wn++);
      console.log(`reenterInsn: ${octW(reenterInsn)}`);
      programVersion = getW36(buf, wn++);
      console.log(`programVersion: ${octW(programVersion)}`);
    } else {
      break;
    }
  } else {
    const nWords = 0o1000000n - nww;
    console.log(`nWords: ${oct6(nWords)}   addr: ${oct6(addr)}`);

    // Read another IOWD worth of load data.
    for (let nw = nWords; nw; --nw, ++addr) {
      mem[addr] = getW36(buf, wn++);
      if (addr < minAddr) minAddr = addr;
      if (addr > maxAddr) maxAddr = addr;
    }
  }
}

minAddr = Number(minAddr);
maxAddr = Number(maxAddr);

console.log(`First 20 words:
  ${mem.slice(minAddr, minAddr + 20)
.map((w, x) => oct6(x) + ": " + octW(w))
.join('\n  ')}`);


function oct6(w) {
  return w.toString(8).padStart(6, '0');
}


function octW(w) {
  return oct6(lh(w)) + ",," + oct6(rh(w));
}


// Get the left half of the BigInt w.
function lh(w) {
  return w >> 18n;
}


// Get the right half of the BigInt w.
function rh(w) {
  return w & 0o777777n;
}


function halves(w) {
  return [lh(w), rh(w)];
}


// Read the `n`th 32-bit word from buf, where words are stored in
// 32BE+4 contiguous bits with 4 bits of padding after. Returns the
// word as a BigInt.
function getW36(buf, n) {
  const byo = n * 5;
  return (BigInt(buf.readUInt32BE(byo)) << 4n) |
    (BigInt(buf.readUInt8(byo + 4)) >> 4n);
}
