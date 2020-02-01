`timescale 1ns/1ns
// M8526 CLK
module clk(input clk,
           input eboxReset,
           input CON.MB_XFER,

           output logic eboxClk,
           output logic fastMemClk,
           output logic MR_RESET,

           iCLK CLK);

  assign eboxClk = clk;         // TEMPORARY XXX
  assign MR_RESET = eboxReset;  // TEMPORARY XXX (need to code CLK module)

  ebox_clocks ebox_clocks0();
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
