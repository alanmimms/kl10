`timescale 1ns/1ns
// Quad 1-of-2 mux
module mux4x2
  (input SEL,
   input [0:3] D0,
   input [0:3] D1,
   output bit [0:3] B);

  assign B = SEL ? D1 : D0;
endmodule
