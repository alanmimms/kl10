`timescale 1ns/1ns
`include "ebox.svh"

// M8544 MCL
module mcl(iEBUS EBUS);

  iMCL MCL();
  assign MCL.EBUSdriver.driving = '0; // XXX temporary
endmodule // mcl
