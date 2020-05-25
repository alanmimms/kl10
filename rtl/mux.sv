`timescale 1ns/1ns

module mux
#(parameter N = 8)
  (input bit [0:$clog2(N)-1] sel,
   input bit en,
   input bit [0:N-1] d,
   output bit q);

  assign q = en ? d[sel] : '0;
endmodule
