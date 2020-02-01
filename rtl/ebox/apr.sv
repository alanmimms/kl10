`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8545 APR
module apr(input [0:35] FM,
           input [9:12] IRAC,
           input [-2:35] EDP.AD,

           output [0:2] APR.FMblk,
           output [0:3] APR.FMadr,

           iAPR APR,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver);

  assign EBUSdriver.driving = 0;       // XXX temporary
endmodule // apr
