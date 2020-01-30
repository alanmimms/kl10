`timescale 1ns/1ns
`include "cram-defs.h"

// M8540 SHM
module shm(input eboxClk,
           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,
           input CON_LONG_ENABLE,

           tCRAM CRAM,

           output logic [0:35] SHM_SH,
           output logic [3:0] SHM_XR,
           output logic SHM_AR_PAR_ODD,
           output indexed,
           output ARextended,
           output ARparityOdd);

endmodule // shm
