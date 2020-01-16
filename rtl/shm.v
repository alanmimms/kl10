`timescale 1ns / 1ps
// M8540 SHM
module shm(input clk,
           input [0:35] AR,
           input [0:35] ARX,
           input ARcarry36,
           input ARXcarry36,
           input longEnable,

           input [1:0] CRAM_SH,

           output reg [0:35] SH,
           output reg [3:0] XR,
           output indexed,
           output ARextended,
           output ARparityOdd
          /*AUTOARG*/);
endmodule // shm
