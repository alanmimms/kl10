`timescale 1ns/1ns
`include "ebox.svh"
// M8545 APR
module apr(iAPR APR,
           iEDP EDP,
           iEBUS EBUS
);

  assign APR.EBUSdriver.driving = '0;       // XXX temporary
endmodule // apr
