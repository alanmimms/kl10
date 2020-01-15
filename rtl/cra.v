`timescale 1ns / 1ps
// M8541 CRA
module cra(
           input clkForce1777,
           input MULdone,
           input [0:3] DRAM_A,
           input [0:3] DRAM_B,
           input [0:9] DRAM_J,
           input [10:0] J,
           input [7:10] dispIn,
           input [8:0] condIn,
           input [5:0] AD,
           input [2:0] ADA,
           input ADAEN,
           input [1:0] ADB,
           input [2:0] AR,
           input [2:0] ARX,
           input BR,
           input BRX,
           input MQ,
           input [2:0] FMADR,
           input [2:0] SCAD,
           input [1:0] SCADA,
           input [1:0] SCADB,
           input SC,
           input FE,
           input [1:0] SH,
           input [1:0] ARMM,
           input [1:0] VMAX,
           input [1:0] VMA,
           input [1:0] TIME,
           input [3:0] MEM,
           input [5:0] SKIP,
           input [5:0] COND,
           input CALL,
           input [4:0] DISP,
           input [4:0] SPEC,
           input MARK,
           input [8:0] magic,

           output [11:0] CRADR
           /*AUTOARG*/);

endmodule // cra
