// Read the specified xxx.svh file containing an interface iXXX and
//  load each definition of the form YYY from it. Then open each *.sv
//  file specified on the command line and replace XXX_YYY with
//  XXX.YYY. This allows the interface to act as a prefix for the
//  symbols. Since file names do not necessarily match the module
//  names, use the name of the interface to properly determine XXX.

const fs = require('fs');

if (process.argv.length <= 3) {
  console.error(`Usage: ${process.argv[0]} xxx.svh a.sv b.sv ....`);
  process.exit(-1);
}

let [, , interfaceFileName, ...svNames] = process.argv;

// Read entire interface file in so we can suck out the symbols and so
// we can replace its content with interface-relative references to
// those symbols.
var interface = fs.readFileSync(interfaceFileName, `utf-8`);

// Extract the interface name and all definitions within.
const [, interfaceName, defsString] = interface
      .replace(/\n\s*\/\/.*\n/g, '')    // Remove comments
      .replace(/\s*\n+/mg, ' ')         // Replace all newlines with one blank
      .replace(/\s+/mg, ' ')            // Replace multiple space with one
      .match(/\binterface\s+(\w+)\s*;\s*([^]*?)[^]\s*endinterface/m);

const prefix = interfaceName.slice(1).toUpperCase() + '.';

const defs = defsString
      .split(/;\s*/)
      .reduce((cur, line) => {
        const [, vector, sym] = line.match(/logic\s*(\[[^\]]+\])?\s*(\w+)/);
        const localSym = prefix + sym.slice(prefix.length);
        cur[sym] = {localSym, vector};
        return cur;        
      }, {});

console.log(`${interfaceName} defs:`, defs);
process.exit();

// Process each *.sv file and replace symbols of the old form with the
// new one.
svNames.forEach(sv => {
  const src = fs.readFileSync(sv, 'utf-8').split(/\n/);

  // This is simple-minded, it ignores strings and other complex
  // lexical entities. I think it will work for my limited set of
  // symbols. We will see...
  const newSrc = src.map(line => {
    // Get a version without comments
    const cleaned = line.replace(/\/\/.*/g, '');

  });
});

