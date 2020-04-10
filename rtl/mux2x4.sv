`timescale 1ns/1ns
// Dual 1-of-4 mux
module mux2x4
  (input [0:1] SEL,
   input EN,
   input [0:3] D0,
   input [0:3] D1,
   output bit B0,
   output bit B1);

  always_comb begin

    if (EN) begin
      case (SEL)
      2'b00: begin B0 = D0[0]; B1 = D1[0]; end
      2'b01: begin B0 = D0[1]; B1 = D1[1]; end
      2'b10: begin B0 = D0[2]; B1 = D1[2]; end
      2'b11: begin B0 = D0[3]; B1 = D1[3]; end
      default: begin B0 = '0; B1 = '0; end
      endcase
    end
  end
endmodule
