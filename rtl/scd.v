`timescale 1ns / 1ps
// M8524 SCD
module scd(input clk,
           input [2:0] CRAM_SCAD,
           input [1:0] CRAM_SCADA,
           input [1:0] CRAM_SCADB,
           input [0:35] AR,
           input [0:8] CRAM_MAGIC,
           input [4:6] DIAG,
           input DIAG_READ_FUNC_13X,

           output drivingEBUS,
           output [0:35] ebusOut,
           output [0:35] ARMM,
           output [0:9] FE,
           output [0:9] SC,
           output [0:35] SCADA,
           output [0:35] SCADB,
           output SC_GE_36,

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
          );
endmodule // scd
