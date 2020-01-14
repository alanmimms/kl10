`timescale 1ns / 1ps
// M8545 APR
module APR(output [0:35] fmOut,
           input [0:35] fmIn,
           input [9:12] irAC,
           input [0:35] ad,

           output ebusReturn,
           output ebusReq,
           output ebusDemand,
           output disableCS,
           output ebusF01,
           output coniOrDATAI,
           output sendF02,
           
           input cshAdrParErr,
           input mbParErr,
           input sbusErr,
           input nxmErr,
           input mboxCDirParErr,
           output aprPhysNum,
           inout [0:35] ebusD,
           input [0:7] ds,
           input ebusDSStrobe
           );
endmodule // APR
