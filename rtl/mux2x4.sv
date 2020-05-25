`timescale 1ns/1ns
// Dual 1-of-4 mux
module mux2x4
  (input bit [0:1] SEL,
   input bit EN,
   input bit [0:3] D0,
   input bit [0:3] D1,
   output bit B0,
   output bit B1);

  always_comb if (EN) unique case (SEL)
                      2'b00: {B0, B1} = {D0[0], D1[0]};
                      2'b01: {B0, B1} = {D0[1], D1[1]};
                      2'b10: {B0, B1} = {D0[2], D1[2]};
                      2'b11: {B0, B1} = {D0[3], D1[3]};
                      endcase
endmodule
