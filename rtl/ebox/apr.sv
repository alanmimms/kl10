`timescale 1ns/1ns
`include "ebox.svh"
// M8545 APR
module apr(iEDP EDP,
           iEBUS EBUS
);

  iAPR APR();

  assign APR.EBUSdriver.driving = '0;       // XXX temporary
endmodule // apr
