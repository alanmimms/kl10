`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8532 PI
module pi(input eboxClk,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver,

           iPI PI);

  assign EBUSdriver.driving = 0;       // XXX temporary
endmodule
