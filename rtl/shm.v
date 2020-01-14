`timescale 1ns / 1ps
// M8540 SHM
module SHM(input clk,
           input [0:35] AR,
           input [0:35] ARX,
           input AR36,
           input ARX36,
           input longEnable,

           input [1:0] CRAM_SH,

           output [3:0] XR,
           output indexed,
           output ARextended,
           output ARparityOdd
          );
endmodule // SHM
