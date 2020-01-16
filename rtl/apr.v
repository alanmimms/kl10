`timescale 1ns / 1ps
// M8545 APR
module apr(output [0:35] fmOut,
           input [0:35] fmIn,
           input [9:12] irAC,
           input [0:35] EDP_AD,

           output ebusReturn,
           output ebusReq,
           output ebusDemand,
           output disableCS,
           output ebusF01,
           output CONIorDATAI,
           output sendF02,
           
           input cshAdrParErr,
           input mbParErr,
           input sbusErr,
           input nxmErr,
           input mboxCDirParErr,
           output aprPhysNum,

           output APRdrivingEBUS,
           output [0:35] APR_EBUS,
           input [0:35] EBUS,

           input [0:7] ds,
           input ebusDSStrobe
           /*AUTOARG*/);
endmodule // apr
