`timescale 1ns/1ns
`include "cram-defs.svh"

// M8540 SHM
module shm(input eboxClk,
           input [0:35] EDP.AR,
           input [0:35] EDP.ARX,
           input CON.LONG_EN,

           tCRAM CRAM,

           output indexed,
           output ARextended,
           output ARparityOdd,

           iSHM SHM
);

endmodule // shm
