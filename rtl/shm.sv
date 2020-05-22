`timescale 1ns/1ns
`include "ebox.svh"

// M8540 SHM
module shm(iCRAM CRAM,
           iCON CON,
           iEDP EDP,
           iSCD SCD,
           iSHM SHM
);

  //  CRAM   FUNC      SIGNALS
  //   00    SHIFT
  //   01     AR       SHIFT_INH
  //   10     ARX      SHIFT_INH,SHIFT_36
  //   11   AR SWAP    SHIFT_INH,SHIFT_50

  bit INSTR_FORMAT, SHIFT_INH, SHIFT_36, SHIFT_50;

  // XXX temporary
  initial begin
    SHM.SH = '0;
    SHM.EBUSdriver.driving = 0;
  end

  // SHM1 p.334
  assign SHM.AR_PAR_ODD = ^{EDP.AR, CON.AR_36};
  assign SHM.ARX_PAR_ODD = ^{EDP.ARX, CON.ARX_36};
  assign SHM.AR_EXTENDED = ~EDP.AR[0] & |EDP.AR[6:17];
  assign INSTR_FORMAT = ~CON.LONG_EN | EDP.ARX[0];
  assign SHM.XR = INSTR_FORMAT ? EDP.ARX[14:17] : EDP.ARX[2:5];
  assign SHM.INDEXED = |SHM.XR;

  assign SHIFT_INH = |CRAM.SH | SCD.SC_GE_36 | SCD.SC_36_TO_63;
  assign SHIFT_50 = &CRAM.SH;
  assign SHIFT_36 = ~CRAM.SH[1] & SHIFT_INH;

  bit [0:5] sc;
  assign sc = SCD.SC[4:9] & {6{SHIFT_INH}} |
              {SHIFT_36 | SHIFT_50, SHIFT_50, 1'b0, SHIFT_36, SHIFT_50, 1'b0};
  
  // SHM2 p.335
  always_comb case (CRAM.SH)
              2'b00: SHM.SH = ({EDP.AR, EDP.ARX} << sc) >> 36;
              2'b01: SHM.SH = EDP.AR;
              2'b10: SHM.SH = EDP.ARX;
              2'b11: SHM.SH = {EDP.AR[18:35], EDP.AR[0:17]};
              endcase
endmodule
