// Create a SystemVerilog interface file `xxx.svh` from the module
// file `xxx.sv` by taking each symbol from the module interface and
// removing the `output` part of the declaration and remove the `XXX_`
// prefix from each symbol. Note that this presumes all module symbols
// we need to operate on are `output`s.
// 
// Then find symbols of the form `XXX_YYY` in every attached *.sv file
// and replace the symbol with `XXX.YYY`. While we're at it, change
// the *.sv file module interface to remove the `XXX_YYY` interfaces
// and replace the entire list with a single reference to `XXX XXX`.

const fs = require('fs');

if (process.argv.length <= 3) {
  console.error(`Usage: ${process.argv[0]} xxx xxx.sv a.sv b.sv ....`);
  process.exit(-1);
}

let [, , modName, sourceName, ...svNames] = process.argv;
modName = modName.toUpperCase();

// Read entire source module in so we can suck out the symbols and so
// we can replace its content with interface-relative references to
// those symbols.
var source = fs.readFileSync(sourceName, `utf-8`);

// Get definitions between `module xxx (` and `);`.
const [, defs] = source
      .replace(/\n\s*\/\/.*\n/g, '')    // Remove comments
      .replace(/#\s*\([^]*?\)/mg, '')   // Remove #() parameter lists
      .replace(/\s*\n+/mg, ' ')         // Replace all newlines with one blank
      .replace(/\s+/mg, ' ')            // Replace multiple space with one
      .match(/\bmodule\s+\w+\(([^]*?)\)\s*;/m);

//console.log(`${modName} defs:`, defs);

const lineRE = RegExp(`^(input|output)\\b(.*?)(\\b${modName}_\\B.*)$`);
//console.log(`lineRE:`, lineRE);

// Symbols that match our XXX_yyy pattern
const symsToChange = defs
      .split(/, /)
      .reduce((cur, line, x) => {
        const m = line.match(lineRE);

        if (m) {
          cur[m[3].trim()] = {
            io: m[1].trim(),
            def: m[2].replace(/\blogic\b/, '').trim()
          };
        }

        return cur;
      }, {});

//console.log(`${modName}: syms:`, symsToChange);

const newDefs = Object.entries(symsToChange)
      .map(([sym, props]) =>
           `  logic ${props.def ? props.def + ' ' : ''}${sym}`)
      .join(';\n');

const interface = `\
\`ifndef _${modName}_INTERFACE_
\`define _${modName}_INTERFACE_ 1

interface i${modName};
${newDefs};
endinterface

\`endif
`;

//console.log(interface);

fs.writeFileSync(`rtl/include/${modName.toLowerCase()}.svh`, interface);
