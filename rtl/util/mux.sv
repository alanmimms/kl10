`timescale 1ns/1ns

module mux
#(parameter N = 8)
  (input [0:$clog2(N)-1] sel,
   input en,
   input [0:N-1] d,
   output bit q);

  always_comb q = en ? d[sel] : '0;
endmodule
