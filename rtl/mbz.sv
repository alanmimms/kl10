`timescale 1ns/1ns
`include "ebox.svh"

// M8537 MBZ
module mbz(iCCL CCL,
           iCLK CLK,
           iCTL CTL,
           iMBZ MBZ,
           iMTR MTR,
           iPMA PMA,
           iEBUS EBUS,
           iMBOX MBOX
);

  bit clk, RESET;
  bit CHAN_CORE_BUSY_IN, CHAN_CORE_BUSY, CSH_CHAN_CYC, EBOX_DIAG_CYC, CHAN_TO_MEM;
  bit MEM_RD_RQ, MEM_WR_RQ, CORE_BUSY_IN, CORE_RD_IN_PROG;
  bit CHAN_STATUS_TO_MB, CHAN_BUF_TO_MB, CHAN_EPT, AR_TO_MB_SEL, MEM_START_C;
  bit NXM_FLG, NXM_CLR_T0, NXM_CLR_DONE, A_CHANGE_COMING, MBOX_NXM_ERR_CLR;
  bit SEQUENTIAL_RQ, RQ_HOLD_DLY, NXM_CRY_A, NXM_CRY_B, CORE_BUSY;
  bit [0:1] MB_DATA_SOURCE, MB_WD_SEL;
  bit LOAD_MB_MAGIC, MB_TEST_PAR_A_IN, MB_TEST_PAR_B_IN, HOLD_ERR_REG;
  bit ERR_HOLD, NXM_T6comma7, SBUS_ERR_FLG, MB_PAR_ERR, ADR_PAR_ERR_FLG;
  bit CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, MB_CH_BUF_00to17_PAR, MB_CH_BUF_18to35_PAR;
  bit CH_BUF_MB_SEL, CH_BUF_IN_00to17_PAR, CH_BUF_IN_18to35_PAR;
  bit CH_REG_00to17_PAR, CH_REG_18to35_PAR, CSH_PAR_BIT, CH_BUF_PAR_BIT, CCW_PAR_BIT;
  bit [0:6] CH_BUF_ADR;
  bit [0:7] EBUS_REG_IN;
  bit [0:1] chBufParRAM[0:127];
  bit [0:35] EBUS_REG;
  bit NXM_T2, NXM_T3, NXM_T4, NXM_T5, NXM_T6, MEM_WRITE, CHAN_REF, CCA_REF, CHAN_WR_MEM;
  bit CHAN_MEM_REF, ERA_SEL, CH_REG_HOLD;

  // MBZ1 p.303
  always_comb begin
    clk = CLK.MBZ;
    CHAN_CORE_BUSY_IN = MBOX.CCL_HOLD_MEM & CHAN_CORE_BUSY | CSH_CHAN_CYC;
    MBOX.MEM_BUSY = MEM_START_C | CORE_BUSY_IN | CORE_RD_IN_PROG | MBOX.MB_REQ_HOLD;
    MBOX.CSH_EN_CSH_DATA = ~(~EBUS.data[34] & CTL.DIAG_LOAD_FUNC_071 |
                             ~EBUS.data[35] & CTL.DIAG_LOAD_FUNC_071 &
                             MBOX.CSH_EN_CSH_DATA & ~RESET);
    MBOX.MEM_TO_C_DIAG_EN = MBOX.CSH_EN_CSH_DATA | EBOX_DIAG_CYC;
    CHAN_WR_MEM = CHAN_TO_MEM & CHAN_CORE_BUSY;
    CHAN_STATUS_TO_MB = CHAN_WR_MEM & CHAN_EPT;
    CHAN_BUF_TO_MB = CHAN_WR_MEM & ~CHAN_EPT;
    MBOX.CHAN_READ = CHAN_CORE_BUSY & ~CHAN_TO_MEM;
    CHAN_EPT = CCL.CHAN_EPT;
    AR_TO_MB_SEL = PMA.CSH_EBOX_CYC & APR.EBOX_SBUS_DIAG &
                   ~CHAN_CORE_BUSY & ~MTR.CCA_WRITEBACK |
                   ~CHAN_CORE_BUSY & ~MTR.CCA_WRITEBACK & MBOX.E_CACHE_WR_CYC;
    EBOX_DIAG_CYC = AR_TO_MB_SEL;
    CORE_RD_IN_PROG = ~RESET & MBOX.CORE_RD_IN_PROG;
  end

  bit e51q14;
  always_ff @(posedge clk) begin
    CHAN_CORE_BUSY <= CHAN_CORE_BUSY_IN;
    MBZ.RD_PSE_WR_REF <= MEM_RD_RQ & MEM_WR_RQ & MEM_START_C |
                         ~CORE_BUSY & MBZ.RD_PSE_WR_REF & ~RESET;
    CORE_BUSY <= CHAN_CORE_BUSY | MEM_START_C |
                 CORE_BUSY_IN | CORE_RD_IN_PROG | MBOX.MB_REQ_HOLD;
    CHAN_TO_MEM <= CCL.CHAN_TO_MEM & CSH_CHAN_CYC |
                   ~CSH_CHAN_CYC & CHAN_TO_MEM & ~RESET;
    e51q14 <= CORE_RD_IN_PROG;
  end

  bit [0:2] e47Q;
  priority_encoder8 e47(.d({2'b00, AR_TO_MB_SEL, CHAN_BUF_TO_MB,
                            CORE_RD_IN_PROG, 1'b0, CHAN_STATUS_TO_MB, 1'b0}),
                        .q(e47Q));

  always_latch begin
    if (e51q14) MBOX.MB_IN_SEL = e47Q;
  end


  // MBZ2 p.304
  USR4 e22(.S0('0),
           .D(EBUS_REG_IN[0:3]),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[0:3]));

  USR4 e15(.S0('0),
           .D(EBUS_REG_IN[4:7]),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[4:7]));

  USR4 e16(.S0('0),
           .D({MBOX.PAGED_REF, MBOX.PMA[14:16]}),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q({EBUS_REG[8], EBUS_REG[14:16]}));

  USR4 e26(.S0('0),
           .D(MBOX.PMA[17:20]),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[17:20]));

  USR4 e13(.S0('0),
           .D(MBOX.PMA[21:24]),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[21:24]));

  USR4 e11(.S0('0),
           .D({MBOX.PMA[25:26], MBOX.PMA[34:35]}),
           .S3('0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q({EBUS_REG[25:26], EBUS_REG[34:35]}));

  mux2x4 e31(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({MBOX.CORE_BUSY, ~MBOX.ADR_PAR_ERR,
                  ~MBOX.CHAN_ADR_PAR_ERR, EBUS_REG[15]}),
             .D1({~MBOX.CHAN_PAR_ERR, MBOX.CBUS_PAR_LEFT_TE,
                  MBOX.CBUS_PAR_RIGHT_TE, EBUS_REG[16]}),
             .B0(EBUS.data[15]),
             .B1(EBUS.data[16]));

  mux2x4 e39(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({SHM.AR_PAR_ODD, MBOX.MEM_PAR_IN, MBOX.CSH_PAR_BIT_IN, EBUS_REG[17]}),
             .D1({MBOX.MB_PAR_BIT_IN, CSH_PAR_BIT, 1'b0, EBUS_REG[18]}),
             .B0(EBUS.data[17]),
             .B1(EBUS.data[18]));

  mux2x4 e34(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({~MBOX.CSH_EN_CSH_DATA, ~MBOX.MEM_TO_C_DIAG_EN,
                  ~MBOX.CHAN_READ, EBUS_REG[19]}),
             .D1({MBOX.MB_IN_SEL[2], MBOX.MB_IN_SEL[1], MBOX.MB_IN_SEL[0], EBUS_REG[20]}),
             .B0(EBUS.data[19]),
             .B1(EBUS.data[20]));

  mux2x4 e35(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({MBOX.NXM_ACK, ~MBZ.RD_PSE_WR_REF, MBOX.MEM_BUSY, EBUS_REG[21]}),
             .D1({CHAN_CORE_BUSY, ~MBOX.NXM_ERR, ~MBOX.HOLD_ERA, EBUS_REG[22]}),
             .B0(EBUS.data[21]),
             .B1(EBUS.data[22]));

  mux2x4 e32(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({MBOX.NXM_ANY, ~MBZ.RD_PSE_WR_REF, NXM_T2, EBUS_REG[23]}),
             .D1({~NXM_T6comma7, ~MBOX.SBUS_ERR, ~MBOX.MB_PAR_ERR, EBUS_REG[24]}),
             .B0(EBUS.data[23]),
             .B1(EBUS.data[24]));

  mux2x4 e44(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({~MBOX.CHAN_NXM_ERR, ~MBOX.NXM_DATA_VAL,
                  PAG.MB_00to17_PAR, EBUS_REG[25]}),
             .D1({PAG.MB_18to35_PAR, CSH.PAR_BIT_A, CSH.PAR_BIT_B, EBUS_REG[26]}),
             .B0(EBUS.data[25]),
             .B1(EBUS.data[26]));

  always_comb begin
    EBUS.data[0:8]   = CTL.DIAG_READ_FUNC_16x ? EBUS_REG[0:8]   : '0;
    EBUS.data[14]    = CTL.DIAG_READ_FUNC_16x ? EBUS_REG[14]    : '0;
    EBUS.data[34:35] = CTL.DIAG_READ_FUNC_16x ? EBUS_REG[34:35] : '0;
  end


  // MBZ3 p.305
  bit [0:1] ignoredE23;
  USR4 e23(.S0('0),
           .D(4'b0000),
           .S3('0),
           .SEL({NXM_FLG & MEM_START_C,
                 NXM_FLG & MEM_START_C & ~MBOX.PHASE_CHANGE_COMING}),
           .CLK(clk),
           .Q({ignoredE23, MBOX.NXM_ACKN, NXM_CLR_T0}));

  bit e51q2, e71q2, e71q7;
  bit e68q4, e57q3, e72q2;
  always_comb begin
    MBOX.NXM_DATA_VAL = NXM_CLR_T0 & MEM_RD_RQ;
    NXM_CLR_DONE = NXM_FLG & ~MEM_START_C;
    MBOX.NXM_ANY = NXM_FLG;
    MEM_START_C = MBOX.MEM_START_A | MBOX.MEM_START_B;
    RESET = CLK.MR_RESET;
    MBOX.CHAN_NXM_ERR = CHAN_MEM_REF & ~e51q2 & MBOX.NXM_ERR;
    e71q7 = MBOX.MEM_START_A | MBOX.MEM_START_B | MBOX.RQ_HOLD_FF;
    SEQUENTIAL_RQ = e71q7 & CHAN_CORE_BUSY |
                    SEQUENTIAL_RQ & ~RESET & CHAN_CORE_BUSY;
    MBOX.HOLD_ERA = ~e71q7 | ERR_HOLD | RQ_HOLD_DLY | NXM_FLG;
    ERR_HOLD = APR.ANY_EBOX_ERR_FLG | MBOX.NXM_ERR | MB_PAR_ERR | ADR_PAR_ERR_FLG;
    HOLD_ERR_REG = ERR_HOLD | NXM_FLG;
    e72q2 = e68q4 | RESET;
  end

  always_ff @(posedge clk) begin
    NXM_FLG <= NXM_CRY_A & NXM_CRY_B & MEM_START_C |
               ~NXM_CLR_DONE & NXM_FLG & ~RESET;
    CHAN_MEM_REF <= MEM_START_C & CHAN_CORE_BUSY | CORE_BUSY & CHAN_MEM_REF & ~RESET;
    A_CHANGE_COMING <= MBOX.A_CHANGE_COMING_IN;
    MBOX.NXM_ERR <= NXM_CLR_DONE |
                    ~MBOX.NXM_ERR_CLR & MBOX.NXM_ERR & ~RESET;
    e51q2 <= MBOX.NXM_ERR;
    RQ_HOLD_DLY <= e71q7;
    e68q4 <= MBOX.A_CHANGE_COMING_IN ^ e72q2;
    e57q3 <= e72q2 & MBOX.A_CHANGE_COMING_IN & e71q2;
  end

  UCR4 e52(.CIN(e57q3),
           .SEL({MEM_START_C, 1'b0}),
           .D(4'b0000),
           .CLK(clk),
           .COUT(NXM_CRY_A),
           .Q());
  
  UCR4 e48(.CIN(NXM_CRY_A),
           .SEL({MEM_START_C, 1'b0}),
           .CLK(clk),
           .COUT(NXM_CRY_B),
           .Q());

  // MBZ4 p.306
  bit e57q2, e25q2, e25q15, e25q3, e30q13;
  always_ff @(posedge clk) begin
    e57q2 <= e57q2 & MEM_START_C |
             MBOX.ACKN_PULSE & MEM_START_C;
    e25q2 <= NXM_FLG;
    NXM_T2 <= NXM_FLG & e25q2 |
              ~e57q2 & ~NXM_FLG & MEM_START_C & MBOX.ACKN_PULSE;
    NXM_T3 <= NXM_T2;
    NXM_T4 <= NXM_T3;
    NXM_T5 <= NXM_T4;
    NXM_T6 <= NXM_T4;
    e25q15 <= NXM_T6 & MEM_RD_RQ;
    SBUS_ERR_FLG <= MBOX.MEM_ERROR & A_CHANGE_COMING |
                    APR.SBUS_ERR & MBOX.SBUS_ERR & ~RESET;
    MB_PAR_ERR <= ~MBOX.MB_PAR_ODD & MB_TEST_PAR_B_IN |
                  ~MBOX.MB_PAR_ODD & MB_TEST_PAR_A_IN & APR.MB_PAR_ERR |
                  MBOX.MB_PAR_ERR & ~RESET & APR.MB_PAR_ERR |
                  ~MBOX.MB_PAR_ODD & MBOX.ACKN_PULSE & ~MEM_RD_RQ;
    ADR_PAR_ERR_FLG <= MBOX.MEM_ADR_PAR_ERR & A_CHANGE_COMING |
                       ~APR.S_ADR_P_ERR & MBOX.ADR_PAR_ERR & ~RESET;
    e25q3 <= ADR_PAR_ERR_FLG;
    e30q13 <= MB_PAR_ERR;
  end

  always_comb begin
    MEM_RD_RQ = MBX.MEM_RD_RQ;
    MEM_WR_RQ = MBX.MEM_WR_RQ;
    NXM_T6comma7 = NXM_T6 | e25q15;
    CORE_BUSY_IN = NXM_T2 | NXM_T3 | NXM_T4 | NXM_T5 | MBOX.CORE_BUSY;
    LOAD_MB_MAGIC = ~ERR_HOLD & NXM_T6comma7 & NXM_FLG |
                    MB_TEST_PAR_A_IN & ~HOLD_ERR_REG |
                    MB_TEST_PAR_B_IN & ~HOLD_ERR_REG |
                    ~HOLD_ERR_REG & MBOX.ACKN_PULSE & ~MEM_RD_RQ;
    MBOX.SBUS_ERR = SBUS_ERR_FLG;
    MBOX.MB_PAR_ERR = MB_PAR_ERR;
    MBOX.ADR_PAR_ERR = ADR_PAR_ERR_FLG;
    MBOX.CHAN_ADR_PAR_ERR = e25q3 & MBOX.ADR_PAR_ERR & CHAN_MEM_REF;
    MBOX.CHAN_PAR_ERR = e30q13 & MBOX.MB_PAR_ERR & CHAN_MEM_REF;
  end

  USR4  e6(.S0('0),
           .D({MBOX.MB_DATA_CODE_2, MBOX.MB_DATA_CODE_1, MBOX.MB_SEL}),
           .S3('0),
           .SEL({2{LOAD_MB_MAGIC}}),
           .CLK(clk),
           .Q({MB_DATA_SOURCE, MB_WD_SEL}));


  // MBZ5 p.307
  bit [2:3] e45Ignored, e56Ignored;
  USR4 e45(.S0('0),
           .D({CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, 2'b00}),
           .S3('0),
           .SEL({2{CRC.CBUS_OUT_HOLD}}),
           .CLK(clk),
           .Q({MBOX.CBUS_PAR_LEFT_TE, MBOX.CBUS_PAR_RIGHT_TE, e45Ignored}));

  USR4 e56(.S0('0),
           .D({CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, 2'b00}),
           .S3('0),
           .SEL({2{MBOX.CH_T0}}),
           .CLK(clk),
           .Q({MB_CH_BUF_00to17_PAR, MB_CH_BUF_18to35_PAR, e56Ignored}));

  always_comb begin
    CH_BUF_IN_00to17_PAR = CH_BUF_MB_SEL ? PAG.MB_00to17_PAR : CH_REG_00to17_PAR;
    CH_BUF_IN_18to35_PAR = CH_BUF_MB_SEL ? PAG.MB_18to35_PAR : CH_REG_18to35_PAR;
    CH_BUF_PAR_BIT = MB_CH_BUF_00to17_PAR | MB_CH_BUF_18to35_PAR;
    CCW_PAR_BIT = CCL.ODD_WC_PAR ^ CCW.ODD_ADR_PAR;
  end

  always_latch begin

    if (CH_REG_HOLD) begin
      CH_REG_00to17_PAR = CCL.DATA_REVERSE ?
                          MBOX.CBUS_PAR_RIGHT_RE :
                          MBOX.CBUS_PAR_LEFT_RE;
      CH_REG_18to35_PAR = CCL.DATA_REVERSE ?
                          MBOX.CBUS_PAR_LEFT_RE :
                          MBOX.CBUS_PAR_RIGHT_RE;
    end
  end

  always_ff @(posedge clk) begin
    CH_BUF_ADR <= CRC.CH_BUF_ADR;
    CH_REG_HOLD <= ~MBOX.CH_T2;
  end

  // e60,e55
  always_ff @(MBOX.CH_BUF_WR, CH_BUF_ADR) begin

    if (MBOX.CH_BUF_WR) begin
      chBufParRAM[CH_BUF_ADR] <= {CH_BUF_00to17_PAR, CH_BUF_18to35_PAR};
    end else begin
      {CH_BUF_00to17_PAR, CH_BUF_18to35_PAR} <= chBufParRAM[CH_BUF_ADR];
    end
  end

  mux2x4 e50(.EN(MBOX.MEM_TO_C_EN),
             .SEL(MBOX.MEM_TO_C_SEL),
             .D0({SHM.AR_PAR_ODD, MBOX.MB_PAR, MBOX.MEM_PAR_IN, 1'b0}),
             .B0(MBOX.CSH_PAR_BIT_IN),
             .D1(), .B1());

  mux e40(.en('1),
          .sel(MBOX.MB_IN_SEL),
          .d({CSH_PAR_BIT, 1'b0, SHM.AR_PAR_ODD, CH_BUF_PAR_BIT,
              MBOX.MEM_PAR_IN, 1'b0, CCW_PAR_BIT, 1'b0}),
          .q(MBOX.MB_PAR_BIT_IN));

  // MBZ6 p.308
  always_comb begin
    CSH.PAR_BIT_A = MBOX.CSH_PAR_BIT_IN | (|MBOX.CSH_PAR_BIT_A);
    CSH.PAR_BIT_B = |MBOX.CSH_PAR_BIT_B;
    CSH_PAR_BIT =   |MBOX.CSH_PAR_BIT_A | CSH.PAR_BIT_B;

    ERA_SEL = APR.EBOX_ERA & CSH.EBOX_CYC;
    EBUS_REG_IN = ERA_SEL ?
                  {MB_WD_SEL, CCA_REF, CHAN_REF, MB_DATA_SOURCE, MEM_WRITE} :
                  {MCL.VMA_USER,
                   PAG.PF_HOLD_01_IN,
                   PAG.PF_HOLD_02_IN,
                   PAG.PF_HOLD_03_IN,
                   PAG.PF_HOLD_04_IN,
                   PAG.PF_HOLD_05_IN,
                   PAG.PT_PUBLIC};
    MB_TEST_PAR_B_IN = CCL.CH_TEST_MB_PAR |
                       MBX.CACHE_TO_MB_T4 & CORE_BUSY & ~RESET;
  end

  bit ignoredE18;
  USR4 e18(.S0('0),
           .D({~MEM_RD_RQ, CHAN_CORE_BUSY, MTR.CCA_WRITEBACK, 1'b0}),
           .S3('0),
           .SEL({2{MBOX.HOLD_ERA}}),
           .CLK(clk),
           .Q({MEM_WRITE, CHAN_REF, CCA_REF, ignoredE18}));
endmodule
