`timescale 1ns/1ns
`include "ebox.svh"
module chx(iCSH CSH,
           iMBOX MBOX);

  // XXX temporary
  initial begin
    CSH._0_WD_VAL = '0;
    CSH._1_WD_VAL = '0;
    CSH._2_WD_VAL = '0;
    CSH._3_WD_VAL = '0;
  end

  // From M8549-YF-CHSX cache substitute
  always_comb begin
    CSH._0_VALID_MATCH = '0;
    CSH._1_VALID_MATCH = '0;
    CSH._2_VALID_MATCH = '0;
    CSH._3_VALID_MATCH = '0;
    CSH.ADR_PAR_BAD = '0;
  end
endmodule // chx
