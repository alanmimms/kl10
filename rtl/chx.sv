`timescale 1ns/1ns
`include "ebox.svh"
module chx(iCSH CSH,
           iMBOX MBOX);

  // XXX temporary
  initial begin
    MBOX.CSH_WD_VAL[0] = '0;
    MBOX.CSH_WD_VAL[1] = '0;
    MBOX.CSH_WD_VAL[2] = '0;
    MBOX.CSH_WD_VAL[3] = '0;
  end

  // From M8549-YF-CHSX cache substitute
  always_comb begin
    CSH.VALID_MATCH[0] = '0;
    CSH.VALID_MATCH[1] = '0;
    CSH.VALID_MATCH[2] = '0;
    CSH.VALID_MATCH[3] = '0;
    MBOX.CSH_ADR_PAR_BAD = '0;
  end
endmodule // chx
