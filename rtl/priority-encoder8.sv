`timescale 1ns/1ns

module priority_encoder8
  (input bit [0:7] d,
   output bit [0:2] q,
   output bit any);

  bit found;
  always_comb case (d) inside
              8'b1xxxxxxx: {any, q} = 4'b1000;
              8'b01xxxxxx: {any, q} = 4'b1001;
              8'b001xxxxx: {any, q} = 4'b1010;
              8'b0001xxxx: {any, q} = 4'b1011;
              8'b00001xxx: {any, q} = 4'b1100;
              8'b000001xx: {any, q} = 4'b1101;
              8'b0000001x: {any, q} = 4'b1110;
              8'b00000001: {any, q} = 4'b1111;
              default:     {any, q} = 4'b0000;
              endcase
endmodule
