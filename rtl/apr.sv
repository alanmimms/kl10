`timescale 1ns/1ns
`include "ebus-defs.svh"
// M8545 APR
module apr(input [0:35] FM,
           input [9:12] IRAC,
           input [-2:35] EDP_AD,

           output [0:2] APR_FMblk,
           output [0:3] APR_FMadr,

           output logic APR_CLK,
           output logic APR_CONO_OR_DATAO,
           output logic APR_CONI_OR_DATAI,
           output logic APR_EBUS_RETURN,

           iEBUS EBUS,
           tEBUSdriver EBUSdriver);

endmodule // apr
