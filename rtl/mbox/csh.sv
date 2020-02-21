`timescale 1ns/1ns
module csh(iCSH CSH);

  // XXX temporary
  initial begin
    CSH.EBOX_RETRY_REQ = '0;
    CSH.EBOX_T0_IN = '0;
    CSH.MBOX_RESP_IN = '0;
    CSH.PAGE_FAIL_HOLD = '0;
    CSH.GATE_VMA_27_33 = '0;

    CSH.PAR_BIT_A = '0;
    CSH.PAR_BIT_B = '0;
  end
  
endmodule // csh
