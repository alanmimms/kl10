`timescale 1ns/1ns

module decoder
  #(parameter N = 8)
  (input en,
   input [0:$clog2(N)-1] sel,
   output bit [0:N-1] q);

  always_comb begin
    q = '0;
    if (en) q[sel] = 1'b1;
  end
endmodule

