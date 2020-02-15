'use strict';
const CRAM = require('./cram');

const bits = CRAM.map(w => w.toString(16).padStart(84/4, '0'));
console.log(`memory_initialization_radix = 16;
memory_initialization_vector = ${bits.join('\n')};`);


