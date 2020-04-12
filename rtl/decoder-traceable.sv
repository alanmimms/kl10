`timescale 1ns/1ns
`include "ebox.svh"

module decoderTraceable
  (input en,
   input trace = '0,
   input string traceName = "",
   input [0:2] sel,
   output bit [0:7] q,
   iEBUS EBUS);

  always_comb begin
    q = '0;
    if (en) q[sel] = 1'b1;

    if (trace) begin
      $display($time, " ===DECODER TRACE=== %s en=1'b%01b sel=3'b%03b q=8'b%08b EBUS.ds=3'o%03o",
               traceName, en, sel, q, EBUS.ds);
    end
  end
endmodule

