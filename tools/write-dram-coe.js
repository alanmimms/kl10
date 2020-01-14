'use strict';
const DRAM = require('./dram');

DRAM.forEach(w => console.log(w.toString(2).padStart(24, '0')));

