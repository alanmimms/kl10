`timescale 1ns/1ns
// M8526 CLK
module clk(input clk,
           input eboxReset,
           input CON_MB_XFER,

           output logic eboxClk,
           output logic fastMemClk,
           output logic MR_RESET,

           output logic CLK_EBOX_SYNC,
           output logic CLK_SBR_CALL,
           output logic CLK_RESP_MBOX,
           output logic CLK_RESP_SIM,
           output logic CLK_PAGE_ERROR);

  assign eboxClk = clk;         // TEMPORARY XXX
  assign MR_RESET = eboxReset;  // TEMPORARY XXX (need to code CLK module)
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
