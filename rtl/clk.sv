`timescale 1ns/1ns
// M8526 CLK
module clk(input logic masterClk,
           input logic eboxReset,
           output logic mbXfer,
           output logic eboxClk,
           output logic fastMemClk,
           output logic CLK_SBR_CALL,
           output logic CLK_RESP_MBOX,
           output logic CLK_RESP_SIM,
           output logic MR_RESET
           );

`ifndef KL10PV_TB
  ebox_clocks clk0(.clk_in1(masterClk), .*);
`endif

  assign mbXfer = 0;            // TEMPORARY XXX
  assign MR_RESET = eboxReset;  // TEMPORARY XXX (need to code CLK module)
endmodule // clk
// Local Variables:
// verilog-library-files:("../ip/ebox_clocks/ebox_clocks_stub.v")
// End:
