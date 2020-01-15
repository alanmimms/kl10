`timescale 1ns / 1ps
// M8541 CRA
module cra(
   input clkForce1777,
   input [0:3] DRAMa,
   input [0:3] DRAMb,
   input [0:9] DRAMj,
   input [7:10] dispIn,
   input [8:0] condIn,

   output [10:0] j,
   output [5:0] ad,
   output [2:0] ada,
   output adaEn,
   output [1:0] adb,
   output [2:0] ar,
   output [2:0] arx,
   output br,
   output brx,
   output mq,
   output [2:0] fmadr,
   output [2:0] scad,
   output [1:0] scada,
   output [1:0] scadb,
   output sc,
   output fe,
   output [1:0] sh,
   output [1:0] armm,
   output [1:0] vmax,
   output [1:0] vma,
   output [1:0] time_,
   output [3:0] mem,
   output [5:0] skip,
   output [5:0] cond,
   output call,
   output [4:0] disp,
   output [4:0] spec,
   output mark,
   output [8:0] magic
   );

reg [0:83] cram[0:2047];
endmodule // cra
