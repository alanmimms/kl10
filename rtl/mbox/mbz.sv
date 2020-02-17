`timescale 1ns/1ns
`include "mbox.svh"

// M8537 MBZ
module mbz(iMBZ MBZ);

  // XXX temporary
  initial begin
    MBZ.RD_PSE_WR = '0;
  end
  
endmodule // mbz
