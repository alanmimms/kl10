`timescale 1ns / 1ps
// M8540 SHM
module shm(input eboxClk,
           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,
           input ARcarry36,
           input ARXcarry36,
           input longEnable,

           input [1:0] CRAM_SH,

           output reg [0:35] SHM_SH,
           output reg [3:0] SHM_XR,
           output indexed,
           output ARextended,
           output ARparityOdd
          /*AUTOARG*/);
endmodule // shm
