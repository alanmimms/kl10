`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"
// M8524 SCD
module scd(input eboxClk,
           input [0:35] EDP.AR,
           input CTL.DIAG_READ_FUNC_13x,

           iCRAM CRAM,
           iSCD SCD);

endmodule // scd
