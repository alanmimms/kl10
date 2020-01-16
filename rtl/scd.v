`timescale 1ns / 1ps
// M8524 SCD
module scd(input eboxClk,
           input [2:0] CRAM_SCAD,
           input [1:0] CRAM_SCADA,
           input [1:0] CRAM_SCADB,
           input [0:35] EDP_AR,
           input [0:8] CRAM_MAGIC,
           input [0:8] CRAM_DIAG_FUNC,
           input DIAG_READ_FUNC_13X,

           output SCDdrivingEBUS,
           output [0:35] SCD_EBUS,
           output [0:8] SCD_ARMM,
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
