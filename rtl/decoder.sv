`timescale 1ns/1ns
`include "ebox.svh"

module decoder
  (input bit en,
   input bit [0:2] sel,
   output bit [0:7] q);

  always_comb unique case({en, sel})
              4'b1000: q = 8'b1000_0000;
              4'b1001: q = 8'b0100_0000;
              4'b1010: q = 8'b0010_0000;
              4'b1011: q = 8'b0001_0000;
              4'b1100: q = 8'b0000_1000;
              4'b1101: q = 8'b0000_0100;
              4'b1110: q = 8'b0000_0010;
              4'b1111: q = 8'b0000_0001;
              default: q = '0;
              endcase
endmodule

