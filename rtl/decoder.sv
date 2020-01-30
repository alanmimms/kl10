`timescale 1ns/1ns

module decoder
  #(parameter N = 8)
  (input en,
   input [0:$clog2(N)-1] sel,
   output logic [0:N-1] q);

  always_comb begin
    if (en) begin
      q[sel] = '1;
    end else
      q = '0;
  end
endmodule

