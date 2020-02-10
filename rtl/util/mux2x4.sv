`timescale 1ns/1ns
// Dual 1-of-4 mux
module mux2x4
  (input SEL,
   input EN,
   input [0:3] D0,
   input [0:3] D1,
   output logic B0,
   output logic B1);

  always_comb begin

    if (EN) begin
      B0 = D0[SEL];
      B1 = D1[SEL];
    end
  end
endmodule
