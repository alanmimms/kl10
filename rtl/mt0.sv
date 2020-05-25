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
module mt0(input bit CROBAR,
           iCLK CLK,
           iMBOX MBOX,
           iMBX MBX,
           iSBUS.mbox SBUS);

  bit DATA_TO_MEM_EN;


  // MT01 p.96
  assign SBUS.CROBAR = CROBAR;

  assign MBOX.MEM_ACKN_A = SBUS.ACKN_A;
  assign MBOX.MEM_ACKN_B = SBUS.ACKN_B;
  assign MBOX.MEM_ERROR = SBUS.ERROR;
  assign MBOX.MEM_ADR_PAR_ERR = SBUS.ADR_PAR_ERR;
  assign SBUS.CLK_INT = CLK.SBUS_CLK;
  assign SBUS.CLK_EXT = CLK.SBUS_CLK;
  assign MBOX.MEM_DATA_VALID_A = SBUS.DATA_VALID_A;
  assign MBOX.MEM_DATA_VALID_B = SBUS.DATA_VALID_B;

  always_comb if (DATA_TO_MEM_EN) begin
    SBUS.DATA_VALID_A = MBOX.DATA_VALID_A_OUT;
    SBUS.DATA_VALID_B = MBOX.DATA_VALID_B_OUT;
  end else begin
    MBOX.DATA_VALID_A_OUT = SBUS.DATA_VALID_A;
    MBOX.DATA_VALID_B_OUT = SBUS.DATA_VALID_B;
  end
  
  assign SBUS.START_A = MBOX.MEM_START_A;
  assign SBUS.START_B = MBOX.MEM_START_B;
  assign SBUS.RQ = MBOX.MEM_RQ;
  assign SBUS.RD_RQ = MBOX.MEM_RD_RQ;
  assign SBUS.WR_RQ = MBOX.MEM_WR_RQ;
  assign SBUS.DIAG = MBOX.MEM_DIAG;
  assign SBUS.ADR_PAR = MBOX.MEM_ADR_PAR;


  // MT02 p.97
  always_comb if (DATA_TO_MEM_EN) SBUS.D = MBOX.MB;
              else MBOX.MEM_DATA_IN = SBUS.D;


  // MT03-MT04 p.98-99
  always_latch if (MBOX.SBUS_ADR_HOLD) SBUS.ADR <= MBOX.PMA;


  // MT05 p.100
  assign SBUS.MEM_RESET = MBOX.DIAG_MEM_RESET;
  assign DATA_TO_MEM_EN = MBOX.MEM_DATA_TO_MEM;

  always_comb if (DATA_TO_MEM_EN) SBUS.DATA_PAR = MBOX.MEM_PAR; // XXX MEM_PAR is not driven anywhere
              else MBOX.MEM_PAR_IN = SBUS.DATA_PAR;

endmodule
