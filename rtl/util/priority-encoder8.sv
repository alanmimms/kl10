`timescale 1ns/1ns

module priority_encoder8
  (input [0:7] d,
   output logic any,
   output logic [0:2] q);

  logic found;
  always_comb begin

    priority case (d)
    default: {any, q} = 4'b0000;
    8'b???????1: {any, q} = 4'b1000;
    8'b??????10: {any, q} = 4'b1001;
    8'b?????100: {any, q} = 4'b1010;
    8'b????1000: {any, q} = 4'b1011;
    8'b???10000: {any, q} = 4'b1100;
    8'b??100000: {any, q} = 4'b1101;
    8'b?1000000: {any, q} = 4'b1110;
    8'b10000000: {any, q} = 4'b1111;
    endcase
  end
endmodule