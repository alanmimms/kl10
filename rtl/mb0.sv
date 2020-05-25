// Schematic review: MB01, MB02, MB03, MB04, MB05
`timescale 1ns/1ns
`include "ebox.svh"
// M8517 MB0 memory buffer board
// Note all three instances of MB0 are modeled in this module
module mb0(iCCL CCL,
           iCLK CLK,
           iCON CON,
           iCRC CRC,
           iEDP EDP,
           iMBOX MBOX,
           iMBX MBX,
           iPAG PAG
           );

  bit clk;
  bit PT_IN_SEL_AR, CH_BUF_MB_SEL;
  bit [2:1] MB_SEL;
  bit [0:35] CH_BUF, CH_BUF_IN, MB_IN_A, MB_IN, MB_CH_BUF, CH_REG;
  bit MB_CH_BUF_LOAD, CH_REG_HOLD, MB_IN_EN, CH_BUF_EN;
  bit [0:6] CH_BUF_ADR;

  // This replaces [0:35] for MB0, MB1, MB2, and MB3 with an easy to
  // access array of registers. Similarly, MB_HOLD[mbNum] replaces
  // MB0_HOLD, MB1_HOLD, MB2_HOLD, and MB3_HOLD.
  bit [0:35] MBN[0:3];
  bit MB_HOLD[0:3];

  // MB01 p.74
  // e61, e55, e27, e50, e41, e22, e21, e16
  always_comb if (MBOX.MEM_TO_C_EN) unique case (MBOX.MEM_TO_C_SEL)
                                    2'b00: MBOX.MEM_TO_CACHE = EDP.AR;
                                    2'b01: MBOX.MEM_TO_CACHE = MBOX.MB;
                                    2'b10: MBOX.MEM_TO_CACHE = MBOX.MEM_DATA_IN;
                                    2'b11: MBOX.MEM_TO_CACHE = CH_REG;
                                    endcase

  // e50, e16
  assign MBOX.MB_PAR_ODD = ^MBOX.MB;

  assign PT_IN_SEL_AR = ~CON.KI10_PAGING_MODE;

  // e65, e40, e26
  assign PAG.PT_IN = PT_IN_SEL_AR ? EDP.AR : MBOX.MB;

  genvar k;
  generate

    for (k = 0; k < 36; k += 4) begin: mb1
      USR4 chBuf(.S0(1'b0),
                 .D(CH_BUF[k+0:k+3]),
                 .S3(1'b0),
                 .CLK(clk),
                 .Q(MBOX.CBUS_D_TE[k+0:k+3]),
                 .SEL({2{MBOX.CBUS_OUT_HOLD}}));
    end
  endgenerate


  // MB02 p.75
  //
  // Instead of building three instances of boards each with 1/3 of
  // the logic and storage, we just do all four MBs at full 36-bit
  // width, building them up out of USR4 instances.
  genvar mbNum;
  generate

    for (mbNum = 0; mbNum < 4; ++mbNum) begin: mb2

      for (k = 0; k < 36; k += 4) begin: mbMux
        USR4 r(.S0(1'b0),
               .D(MBOX.MB[k+0:k+3]),
               .S3(1'b0),
               .CLK(clk),
               .Q(MBN[mbNum][k+0:k+3]),
               .SEL({2{MB_HOLD[mbNum]}}));
      end
    end
  endgenerate

  // e76
  bit [2:3] mbSelUnused;
  USR4 mbSel(.S0(1'b0),
             .D({MBOX.MB_SEL_2_EN, MBOX.MB_SEL_1_EN, 2'b00}),
             .S3(1'b0),
             .SEL({2{MBOX.MB_SEL_HOLD}}),
             .CLK(clk),
             .Q({MB_SEL, mbSelUnused}));

  assign MB_HOLD[0] = MBOX.MB0_HOLD_IN;
  assign MB_HOLD[1] = MBOX.MB1_HOLD_IN;
  assign MB_HOLD[2] = MBOX.MB2_HOLD_IN;
  assign MB_HOLD[3] = MBOX.MB3_HOLD_IN;

    // e71, e52, e78, e8, e28, e3
  always_comb unique case (MB_SEL)
              2'b00: MBOX.MB = MBN[0];
              2'b01: MBOX.MB = MBN[1];
              2'b10: MBOX.MB = MBN[2];
              2'b11: MBOX.MB = MBN[3];
              endcase


  // MB03 p.76
  // e51, e32, e17
  assign CH_BUF_IN = CH_BUF_MB_SEL ? MBOX.MB : CH_REG;
  assign CH_BUF_MB_SEL = ~CRC.BUF_MB_SEL;

  // e69, e59, e49, e44, e64, e54,
  // e39, e35, e25, e15, e30, e20
`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(128), .WIDTH(36), .NBYTES(1))
  chBuf
    (.clk(MBOX.CH_BUF_WR),
     .din(CH_BUF_IN),
     .dout(CH_BUF),
     .addr(CH_BUF_ADR),
     .oe(CH_BUF_EN),
     .wea(MBOX.CH_BUF_WR));
`else
  chBuf_mem chBuf(.addra(CH_BUF_ADR),
                  .clka(MBOX.CH_BUF_WR),
                  .dina(CH_BUF_IN),
                  .douta(CH_BUF),
                  .wea(MBOX.CH_BUF_WR)
                  );
`endif


  // MB04 p.77
  bit [0:35] ccwBuf[0:3];
  assign clk = CLK.MB;
  assign MB_IN_EN = ~MBOX.NXM_ANY;

  // e57, e38, e19
  assign MB_IN_A = MBOX.MB_IN_SEL[2] ? MB_CH_BUF : EDP.AR;

  // e66, e37, e12, e70, e31, e11
  assign MBOX.CCW_MIX = CCL.MIX_MB_SEL ? MBOX.MB : ccwBuf[MBOX.CCW_BUF_ADR];

    // e62 e67, e36, e45, e13, e18
  always_comb if (MB_IN_EN) unique case (MBOX.MB_IN_SEL[0:1])
                            2'b00: MB_IN = MBOX.CACHE_DATA;
                            2'b01: MB_IN = MB_IN_A;
                            2'b10: MB_IN = MBOX.MEM_DATA_IN;
                            2'b11: MB_IN = MBOX.CCW_MIX;
                            endcase

  // e70, e31, e11
  always_ff @(posedge MBOX.CCW_BUF_WR) ccwBuf[MBOX.CCW_BUF_ADR] = MBOX.CCW_BUF_IN;


  // MB05 p.78
  // e24, e29, e23
  always_latch if (CH_REG_HOLD) CH_REG <= MBOX.CH_REVERSE ?
                                          {MBOX.CBUS_D_RE[18:35], MBOX.CBUS_D_RE[0:17]} :
                                          {MBOX.CBUS_D_RE[0:17],  MBOX.CBUS_D_RE[18:35]};

  assign MB_CH_BUF_LOAD = MBOX.CH_T0;

  // e74, e48, e10
  always_ff @(posedge clk) CH_BUF_ADR <= CRC.CH_BUF_ADR;
  always_ff @(posedge clk) CH_BUF_EN <= CCL.CH_BUF_EN;
  always_ff @(posedge clk) CH_REG_HOLD <= ~MBOX.CH_T2;

  // e58, e43, e14
  always_ff @(posedge clk) if (MB_CH_BUF_LOAD) MB_CH_BUF <= CH_BUF;
endmodule
