`timescale 1ns/1ns
`include "ebox.svh"

// M8519 MT0 INT MEM BUS TRANSLATOR
//
// This is basically a signal transformation between MBOX and the
// memory on SBUS. It original signal conditioning is not needed in
// this implementation, but signal name transitioning is.
//
// One side of this transformation is MBOX.xxx signals. The other side
// is SBUS.xxx signals.
//
// This module would be instantiated twice in a real KL to provide two
// cable interfaces to the memory. In this implementation we unify
// this into a single module.
module mt0(iCLK CLK,
           iMBOX MBOX,
           iSBUS SBUS);

  bit DATA_TO_MEM_EN;


  // MT01 p.96
  always_comb begin
    MBOX.MEM_ACKN_A = SBUS.ACKN_A;
    MBOX.MEM_ERROR = SBUS.ERROR;
    MBOX.ADR_PAR_ERR = SBUS.ADR_PAR_ERR;
    SBUS.CLK_INT = CLK.SBUS_CLK;
    SBUS.CLK_EXT = CLK.SBUS_CLK;
    MBOX.MEM_DATA_VALID_A = SBUS.DATA_VALID_A;
    MBOX.MEM_DATA_VALID_B = SBUS.DATA_VALID_B;

    if (DATA_TO_MEM_EN) begin
      SBUS.DATA_VALID_A = MBOX.DATA_VALID_A_OUT;
      SBUS.DATA_VALID_B = MBOX.DATA_VALID_B_OUT;
    end else begin
      MBOX.DATA_VALID_A_OUT = SBUS.DATA_VALID_A;
      MBOX.DATA_VALID_B_OUT = SBUS.DATA_VALID_B;
    end
      
    SBUS.START_A = MBOX.MEM_START_A;
    SBUS.START_B = MBOX.MEM_START_B;
    SBUS.RQ = MBOX.MEM_RQ;
    SBUS.RD_RQ = MBX.MEM_RD_RQ;
    SBUS.WR_RQ = MBX.MEM_WR_RQ;
    SBUS.DIAG = MBOX.MEM_DIAG;
    SBUS.ADR_PAR = MBOX.MEM_ADR_PAR;
  end


  // MT02 p.97
  always_comb begin
    if (DATA_TO_MEM_EN)
      MBOX.MEM_DATA_IN = SBUS.D;
    else
      SBUS.D = MBOX.MB;
  end


  // MT03-MT04 p.98-99
  always_latch begin

    if (MBOX.SBUS_ADR_HOLD) begin
      SBUS.ADR = MBOX.PMA;
    end
  end


  // MT05 p.100
  always_comb begin
    SBUS.MEM_RESET = MBOX.DIAG_MEM_RESET;
    DATA_TO_MEM_EN = MBOX.MEM_DATA_TO_MEM;

    if (DATA_TO_MEM_EN) begin
      SBUS.DATA_PAR = MBOX.MEM_PAR; // XXX MEM_PAR is not driven anywhere
    end else begin
      MBOX.MEM_PAR_IN = SBUS.DATA_PAR;
    end
  end

endmodule
