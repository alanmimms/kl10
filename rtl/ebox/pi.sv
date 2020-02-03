`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8532 PI
module pi(iPI PI,
          iEBUS EBUS,
          tEBUSdriver EBUSdriver
);

  assign EBUSdriver.driving = 0;       // XXX temporary
endmodule
