`timescale 1ns/1ns

module decoder
  (input en,
   input trace = '0,
   input string traceName = "",
   input [0:2] sel,
   output bit [0:7] q);

  always_comb begin
    q = '0;
    if (en) q[sel] = 1'b1;

    if (trace) begin
      $display($time, " ===DECODER TRACE=== %s en=%01b sel=%03b q=%08b",
               traceName, en, sel, q);
    end
  end
endmodule

