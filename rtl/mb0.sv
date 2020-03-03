`timescale 1ns/1ns
`include "ebox.svh"
// M8517 MB0 memory buffer board
// Note all three instances of MB0 are modeled in this module
module mb0(iCLK CLK,
           iCON CON,
           iCRC CRC,
           iEDP EDP,
           iMBOX MBOX
);

  bit clk;
  bit MEM_TO_C_EN, PT_IN_SEL_AR, CH_BUF_MB_SEL;
  bit [0:1] MEM_TO_C_SEL, MB_SEL;
  bit [0:35] CH_BUF, CH_BUF_IN, MB_IN_A, MB_IN, MB_CH_BUF, CH_REG;
  bit MB_CH_BUF_LOAD, CH_REG_HOLD, MB_IN_EN, CH_BUF_EN, MB_CH_LOAD;
  bit [0:6] CH_BUF_ADR;

  // This replaces [0:35] for MB0, MB1, MB2, and MB3 with an easy to
  // access array of registers. Similarly, MB_HOLD[mbNum] replaces
  // MB0_HOLD, MB1_HOLD, MB2_HOLD, and MB3_HOLD.
  bit [0:35] MBN[0:3];
  bit MB_HOLD[0:3];

  // MB01 p.74
  always_comb begin

    // e61, e55, e27, e50, e41, e22, e21, e16
    if (MEM_TO_C_EN) begin
      case (MEM_TO_C_SEL)
      2'b00: MBOX.MEM_TO_CACHE = EDP.AR;
      2'b01: MBOX.MEM_TO_CACHE = MBOX.MB;
      2'b10: MBOX.MEM_TO_CACHE = MBOX.MEM_DATA_IN;
      2'b11: MBOX.MEM_TO_CACHE = CH_REG;
      endcase
    end

    // e50, e16
    MBOX.MB_PAR_ODD = ^MBOX.MB;

    // e65, e40, e26
    PT_IN_SEL_AR = ~CON.KI10_PAGING_MODE;
    MBOX.PT_IN = PT_IN_SEL_AR ? EDP.AR : MBOX.MB;
  end

  genvar k;
  generate

    for (k = 0; k < 36; k += 4) begin: MB01
      USR4 chBufMux(.S0('0),
                    .D(CH_BUF[k+0:k+3]),
                    .S3('0),
                    .CLK(clk),
                    .Q(MBOX.CBUS_D_TE[k+0:k+3]),
                    .SEL({2{MBOX.CBUS_OUT_HOLD}}));
    end
  endgenerate


  // MB02 p.75
  genvar mbNum;
  generate

    for (mbNum = 0; mbNum < 4; ++mbNum) begin: mbArray

      for (k = 0; k < 36; k += 4) begin: mbMux
        USR4 m(.S0('0),
               .D(MB.MB[k+0:k+3]),
               .S3('0),
               .CLK(clk),
               .Q(MBN[mbNum][k+0:k+3]),
               .SEL({2{MB_HOLD[mbNum]}}));
      end
    end
  endgenerate

  always_ff @(posedge clk) begin
    if (MBOX.MB_SEL_HOLD) MB_SEL <= {MBOX.MB_SEL_2_EN, MBOX.MB_SEL_1_EN};
  end

  always_comb begin
    MB_HOLD[0] = MBOX.MB0_HOLD_IN;
    MB_HOLD[1] = MBOX.MB1_HOLD_IN;
    MB_HOLD[2] = MBOX.MB2_HOLD_IN;
    MB_HOLD[3] = MBOX.MB3_HOLD_IN;

    // e71, e52, e78, e8, e28, e3
    case (MB_SEL)
    2'b00: MBOX.MB = MBN[0];
    2'b01: MBOX.MB = MBN[1];
    2'b10: MBOX.MB = MBN[2];
    2'b11: MBOX.MB = MBN[3];
    endcase
  end


  // MB03 p.76
  always_comb begin
    // e51, e32, e17
    CH_BUF_IN = CH_BUF_MB_SEL ? MBOX.MB : CH_REG;
    CH_BUF_MB_SEL = ~CRC.BUF_MB_SEL;
  end

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
  always_comb begin
    clk = CLK.MB;
    MB_IN_EN = ~MBOX.NXM_ANY;
    MB_IN_A = MBOX.MB_IN_SEL[2] ? MB_CH_BUF : EDP.AR;
    MBOX.CCW_MIX = CCL.MIX_MB_SEL ? MBOX.MB : ccwBuf[MBOX.CCW_BUF_ADR];

    if (MB_IN_EN) begin
      case (MBOX.MB_IN_SEL[0:1])
      2'b00: MB_IN = MBOX.CACHE_DATA;
      2'b01: MB_IN = MB_IN_A;
      2'b10: MB_IN = MBOX.MEM_DATA_IN;
      2'b11: MB_IN = MBOX.CCW_MIX;
      endcase
    end
  end

  always_ff @(posedge MBOX.CCW_BUF_WR) begin
    ccwBuf[MBOX.CCW_BUF_ADR] = MBOX.CCW_BUF_IN;
  end


  // MB05 p.78
  always_latch begin

    if (CH_REG_HOLD) begin
      CH_REG <= MBOX.CH_REVERSE ?
                {MBOX.CBUS_D_RE[18:35], MBOX.CBUS_D_RE[0:17]} :
                {MBOX.CBUS_D_RE[0:17],  MBOX.CBUS_D_RE[18:35]};
    end
  end

  always_comb begin
    MB_CH_BUF_LOAD = MBOX.CH_T0;
  end

  always_ff @(posedge clk) begin
    CH_BUF_ADR <= CRC.CH_BUF_ADR;
    CH_BUF_EN <= CCL.CH_BUF_EN;
    CH_REG_HOLD <= ~MBOX.CH_T2;

    if (MB_CH_LOAD) begin
      MB_CH_BUF <= CH_BUF;
    end
  end
endmodule
