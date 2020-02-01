`timescale 1ns/1ns
`include "cram-defs.svh"

// M8540 SHM
module shm(input eboxClk,
           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,
           input CON_LONG_EN,

           tCRAM CRAM,

           output indexed,
           output ARextended,
           output ARparityOdd,

           iSHM SHM
);

endmodule // shm
