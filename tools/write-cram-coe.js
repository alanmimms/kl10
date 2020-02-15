'use strict';
const CRAM = require('./cram');

const bits = CRAM.map(w => w.toString(2).padStart(84, '0'));
console.log(`memory_initialization_radix = 1;
memory_initialization_vector =
${bits}
`);


