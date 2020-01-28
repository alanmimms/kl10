`timescale 1ns/1ns
// M8526 CLK
module clk(input logic masterClk,
           input logic eboxReset,
           output logic mbXfer,
           output logic eboxClk,
           output logic fastMemClk
           );

  ebox_clocks clk0(.clk_in1(masterClk), .*);
  
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
