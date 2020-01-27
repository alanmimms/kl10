`timescale 1ns/1ns
// M8545 APR
module apr(input [0:35] FM,
           input [9:12] IRAC,
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

           output [0:2] APR_FMblk,
           output [0:3] APR_FMadr,

           output APRdrivingEBUS,
           output [0:35] APR_EBUS,
           input [0:35] EBUS,

           input [0:7] EBUS_DS,
           input ebusDSStrobe
           /*AUTOARG*/);

endmodule // apr
