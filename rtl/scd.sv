`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"
// M8524 SCD
module scd(input eboxClk,
           input [0:35] EDP_AR,
           input DIAG_READ_FUNC_13X,

           tuCRAM CRAM,
           tEBUS EBUS,
           output [0:35] SCD_EBUS,
           output [0:8] SCD_ARMMupper,
           output [13:17] SCD_ARMMlower,
           output [0:9] SCD_FE,
           output [0:9] SCD_SC,
           output [0:35] SCD_SCADA,
           output [0:35] SCD_SCADB,
           output SC_GE_36,
           output SCADeq0,
           output SCADsign,
           output SCsign,
           output FEsign,

           output OV,
           output CRY0,
           output CRY1,
           output FOV,
           output FXU,
           output FPD,
           output PCP,
           output DIV_CHK,
           output TRAP_REQ1,
           output TRAP_REQ2,
           output TRAP_CYC1,
           output TRAP_CYC2,

           output USER,
           output USER_IOT,
           output PUBLIC,
           output PRIVATE,
           output ADR_BRK_PREVENT
          /*AUTOARG*/);
endmodule // scd