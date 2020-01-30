`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"
// M8524 SCD
module scd(input eboxClk,
           input [0:35] EDP_AR,
           input CTL_DIAG_READ_FUNC_13x,

           iCRAM CRAM,

           output [0:8] SCD_ARMM_UPPER,
           output [13:17] SCD_ARMM_LOWER,
           output [0:9] SCD_FE,
           output [0:9] SCD_SC,
           output [0:35] SCD_SCADA,
           output [0:35] SCD_SCADB,
           output SCD_SC_GE_36,
           output SCD_SCADeq0,
           output SCD_SCAD_SIGN,
           output SCD_SC_SIGN,
           output SCD_FE_SIGN,

           output SCD_OV,
           output SCD_CRY0,
           output SCD_CRY1,
           output SCD_FOV,
           output SCD_FXU,
           output SCD_FPD,
           output SCD_PCP,
           output SCD_DIV_CHK,
           output SCD_TRAP_REQ1,
           output SCD_TRAP_REQ2,
           output SCD_TRAP_CYC1,
           output SCD_TRAP_CYC2,

           output SCD_USER,
           output SCD_USER_IOT,
           output SCD_PUBLIC,
           output SCD_PRIVATE,
           output SCD_ADR_BRK_PREVENT);

endmodule // scd
