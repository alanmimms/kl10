`timescale 1ns / 1ps
// M8541 CRA
module cra(
   input clkForce1777,
   input [0:3] DRAMa,
   input [0:3] DRAMb,
   input [0:9] DRAMj,
   input [7:10] dispIn,
   input [8:0] condIn,
   input [5:0] AD,
   input [2:0] ada,
   input adaEn,
   input [1:0] adb,
   input [2:0] ar,
   input [2:0] arx,
   input br,
   input brx,
   input mq,
   input [2:0] fmadr,
   input [2:0] scad,
   input [1:0] scada,
   input [1:0] scadb,
   input sc,
   input fe,
   input [1:0] sh,
   input [1:0] armm,
   input [1:0] vmax,
   input [1:0] vma,
   input [1:0] time_,
   input [3:0] mem,
   input [5:0] skip,
   input [5:0] cond,
   input call,
   input [4:0] disp,
   input [4:0] spec,
   input mark,
   input [8:0] magic,

   output [11:0] CRADR
   );

endmodule // cra
