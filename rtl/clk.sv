`timescale 1ns / 1ps
// M8526 CLK
module clk(output mbXfer,
           output eboxClk,
           output fastMemClk
           );

  ebox_clocks clk0(.eboxClk(eboxClk),
                   .fastMemClk(fastMemClk));
  
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
