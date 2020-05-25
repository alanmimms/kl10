`timescale 1ns/1ns
// This is like MC10141 ECL universal shift register
module USR4(input bit S0,
            input bit [0:3] D,
            input bit S3,
            input bit [0:1] SEL,
            input bit CLK,
            output bit [0:3] Q);

  always_ff @(posedge CLK) unique case (SEL)
                           2'b00: Q <= D;              // LOAD
                           2'b01: Q <= {S0, Q[0:2]};   // SHIFT S0 in
                           2'b10: Q <= {Q[1:3], S3};   // SHIFT S3 in
                           2'b11:;                     // HOLD
                           endcase
endmodule
