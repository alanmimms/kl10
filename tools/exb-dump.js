'use strict';
const fs = require('fs');


/*
    PROCESS THE KL BOOTSTRAP FILE (.EXB)
    THIS ROUTINE READS IN A FILE OF BINARY RECORDS.
    *DATA RECORDS:
            .WORD	4+<5*N>		; BYTE COUNT.
            .BLKW	2		; KL ADDRESS.
            .BLKB	5*N		; KL WORDS.
    THE KL WORDS WHICH ARE PLACED IN THE FIRST 36 BITS OF 5 -11 BYTES
    ARE STORED SEQUENTIALLY STARTING AT THE GIVEN ADDRESS.
    *END OF FILE:
            .WORD	4		; BYTE COUNT.
            .BLKW	2		; KL ADDRESS.
    THE ADDRESS IS THE START ADDRESS OF THE BOOTSTRAP PROGRAM.
    THE DATA RECORDS ARE ASSUMED TO BE SORTED BY ADDRESS,
    SO THAT PAGE CLEARING IS DONE PROPERLY.

    THE PAGE CLEARING FEATURE REQUIRES THAT ANY PAGES WHICH RECIEVE
    DATA SHOULD BE CLEARED BEFORE ANY DATA IS STORED. THE PRESENT
    ALGORITHM AVOIDS WRITING TWICE TO ANY LOCATION (CLEAR & DEPOSIT).
    A POINTER IS KEPT OF WHERE THE NEXT KL WORD WOULD BE DEPOSITED,
    AND IS USED TO DETECT GAPS IN DATA/INSTRUCTION STORAGE SO THAT
    INTERVENING WORDS MAY BE CLEARED.
*/

const fileName = process.argv[2];
const fileStats = fs.lstatSync(fileName);
const fileSize = fileStats.size;
const buf = fs.readFileSync(fileName);

const byteCount = buf.readUInt16LE(0);
const nKLWords = Math.floor(byteCount/5);
const klAddress = buf.readUInt32LE(2);

console.log(`byteCount = 0o${oct6(byteCount)}`);
console.log(`klAddress = 0o${oct6(klAddress)}`);

const klWords = [];

for (let o = 6; o < fileSize; o += 5) {
  const w = (BigInt(buf.readUInt32LE(o)) << 8n) + BigInt(buf.readUInt8(o+4));
  klWords.push(w);
}


console.log(`First 100 words:
${klWords
.slice(0, 100)
.map((w, x) => oct6(x) + ": " + oct6(w >> 18n) + ",," + oct6(w & 0o777777n))
.join('\n  ')}`);


function oct6(w) {
  return w.toString(8).padStart(6, '0');
}

