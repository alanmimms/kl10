`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8532 PIC
module pic(input eboxClk,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver,

           output logic PI_EBUS_CP_GRANT,
           output logic PI_EXT_TRAN_REC,
           output logic PI_READY);
endmodule // pic
