`timescale 1ns/1ns
`include "ebox.svh"

module decoder
  (input en,
   input [0:2] sel,
   output bit [0:7] q);

  always_comb begin
    q = '0;
    if (en) q[sel] = 1'b1;
  end
endmodule

