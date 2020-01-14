'use strict';
const CRAM = require('./cram');

CRAM.forEach(w => console.log(w.toString(2).padStart(84, '0')));

