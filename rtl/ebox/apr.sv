`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8545 APR
module apr(input [0:35] FM,
           input [9:12] IRAC,

           iAPR APR,
           iEDP EDP,
           
           iEBUS EBUS,
           tEBUSdriver EBUSdriver);

  assign EBUSdriver.driving = 0;       // XXX temporary
endmodule // apr
