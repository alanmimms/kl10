`timescale 1ns/1ns
`include "ebox.svh"

// M8540 SHM
module shm(iCRAM CRAM,
           iCON CON,
           iEDP EDP,
           iSHM SHM
);

  // XXX temporary
  initial begin
    SHM.AR_PAR_ODD = '0;
    SHM.ARX_PAR_ODD = '0;
    SHM.AR_EXTENDED = '0;
    SHM.SH = '0;
    SHM.INDEXED = '0;
    SHM.EBUSdriver.driving = '0;
  end

endmodule // shm
