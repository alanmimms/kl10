`timescale 1ns/1ns
`include "ebox.svh"
// M8538 MTR
module mtr(iMTR MTR);

  // XXX temporary
  initial begin
    MTR.EBUSdriver.driving = '0;
    MTR.INTERRUPT_REQ = '0;
  end
endmodule // mtr
