// M8540 SHM
module shm(input eboxClk,
           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,
           input ARcarry36,
           input ARXcarry36,
           input longEnable,

           input [1:0] CRAM_SH,

           output logic [0:35] SHM_SH,
           output logic [3:0] SHM_XR,
           output indexed,
           output ARextended,
           output ARparityOdd
          /*AUTOARG*/);
  timeunit 1ns;
  timeprecision 1ps;
endmodule // shm
