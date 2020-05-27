// Schematic review: MBZ1, MBZ2, MBZ3, MBZ4, MBZ5, MBZ6.
`timescale 1ns/1ns
`include "ebox.svh"

// M8537 MBZ
module mbz(iAPR APR,
           iCCL CCL,
           iCCW CCW,
           iCLK CLK,
           iCRC CRC,
           iCSH CSH,
           iCTL CTL,
           iEBUS.mod EBUS,
           iMBC MBC,
           iMBOX MBOX,
           iMBX MBX,
           iMBZ MBZ,
           iMCL MCL,
           iMTR MTR,
           iPAG PAG,
           iPMA PMA,
           iSHM SHM
           );

  bit clk, RESET;
  bit CHAN_CORE_BUSY_IN, CHAN_CORE_BUSY, EBOX_DIAG_CYC, CHAN_TO_MEM;
  bit MEM_RD_RQ, MEM_WR_RQ, CORE_BUSY_IN, CORE_RD_IN_PROG;
  bit CHAN_STATUS_TO_MB, CHAN_BUF_TO_MB, CHAN_EPT, AR_TO_MB_SEL, MEM_START_C;
  bit NXM_FLG, NXM_CLR_T0, NXM_CLR_DONE, A_CHANGE_COMING, MBOX_NXM_ERR_CLR;
  bit SEQUENTIAL_RQ, RQ_HOLD_DLY, NXM_CRY_A, NXM_CRY_B;
  bit [0:1] MB_DATA_SOURCE, MB_WD_SEL;
  bit LOAD_MB_MAGIC, MB_TEST_PAR_A_IN, MB_TEST_PAR_B_IN, HOLD_ERR_REG;
  bit ERR_HOLD, NXM_T6comma7, SBUS_ERR_FLG, MB_PAR_ERR, ADR_PAR_ERR_FLG;
  bit CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, MB_CH_BUF_00to17_PAR, MB_CH_BUF_18to35_PAR;
  bit CH_BUF_MB_SEL, CH_BUF_IN_00to17_PAR, CH_BUF_IN_18to35_PAR;
  bit CH_REG_00to17_PAR, CH_REG_18to35_PAR, CSH_PAR_BIT, CH_BUF_PAR_BIT, CCW_PAR_BIT;
  bit [0:6] CH_BUF_ADR;
  bit [0:6] EBUS_REG_IN;
  bit [0:35] EBUS_REG;
  bit NXM_T2, NXM_T3, NXM_T4, NXM_T5, NXM_T6, MEM_WRITE, CHAN_REF, CCA_REF, CHAN_WR_MEM;
  bit CHAN_MEM_REF, ERA_SEL, CH_REG_HOLD;

  // MBZ1 p.303
  assign clk = CLK.MBZ;
  assign CHAN_CORE_BUSY_IN = MBOX.CCL_HOLD_MEM & CHAN_CORE_BUSY | MBOX.CSH_CHAN_CYC;
  assign MBOX.MEM_BUSY = MEM_START_C | CORE_BUSY_IN | CORE_RD_IN_PROG | MBOX.MB_REQ_HOLD;
  assign MBOX.CSH_EN_CSH_DATA = ~(~EBUS.data[34] & CTL.DIAG_LOAD_FUNC_071 |
                                  ~EBUS.data[35] & CTL.DIAG_LOAD_FUNC_071 &
                                  MBOX.CSH_EN_CSH_DATA & ~RESET);
  assign MBOX.MEM_TO_C_DIAG_EN = MBOX.CSH_EN_CSH_DATA | EBOX_DIAG_CYC;
  assign CHAN_WR_MEM = CHAN_TO_MEM & CHAN_CORE_BUSY;
  assign CHAN_STATUS_TO_MB = CHAN_WR_MEM & CHAN_EPT;
  assign CHAN_BUF_TO_MB = CHAN_WR_MEM & ~CHAN_EPT;
  assign MBOX.CHAN_READ = CHAN_CORE_BUSY & ~CHAN_TO_MEM;
  assign CHAN_EPT = CCL.CHAN_EPT;
  assign AR_TO_MB_SEL = PMA.CSH_EBOX_CYC & APR.EBOX_SBUS_DIAG &
                        ~CHAN_CORE_BUSY & ~MTR.CCA_WRITEBACK |
                        ~CHAN_CORE_BUSY & ~MTR.CCA_WRITEBACK & CSH.E_CACHE_WR_CYC;
  assign EBOX_DIAG_CYC = AR_TO_MB_SEL;
  assign CORE_RD_IN_PROG = ~RESET & MBOX.CORE_RD_IN_PROG;

  bit e51q14;
  always_ff @(posedge clk) CHAN_CORE_BUSY <= CHAN_CORE_BUSY_IN;
  always_ff @(posedge clk) MBZ.RD_PSE_WR_REF <= MEM_RD_RQ & MEM_WR_RQ & MEM_START_C |
                                                // -MBZ4 CORE BUSY A L on MBZ1 B8 p.303. XXX
                                                ~MBOX.CORE_BUSY & MBZ.RD_PSE_WR_REF & ~RESET;
  // <DH2> CORE BUSY L and <DM2> CORE BUSY H latched and driven on MBZ1 D3.
  always_ff @(posedge clk) MBOX.CORE_BUSY <= CHAN_CORE_BUSY | MEM_START_C |
                                             CORE_BUSY_IN | CORE_RD_IN_PROG | MBOX.MB_REQ_HOLD;
  always_ff @(posedge clk) CHAN_TO_MEM <= CCL.CHAN_TO_MEM & MBOX.CSH_CHAN_CYC |
                                          ~MBOX.CSH_CHAN_CYC & CHAN_TO_MEM & ~RESET;
  always_ff @(posedge clk) e51q14 <= CORE_RD_IN_PROG;

  bit [0:2] e47Q;
  priority_encoder8 e47(.d({2'b00,
                            AR_TO_MB_SEL,
                            CHAN_BUF_TO_MB,
                            CORE_RD_IN_PROG,
                            1'b0,
                            CHAN_STATUS_TO_MB,
                            1'b0}),
                        .q(e47Q));

  always_latch if (e51q14) MBOX.MB_IN_SEL <= e47Q;


  // MBZ2 p.304
  USR4 e22(.S0(1'b0),
           .D(EBUS_REG_IN[0:3]),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[0:3]));

  USR4 e15(.S0(1'b0),
           .D({EBUS_REG_IN[4:6], PAG.PT_CACHE}),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[4:7]));

  USR4 e16(.S0(1'b0),
           .D({MBOX.PAGED_REF, MBOX.PMA[14:16]}),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q({EBUS_REG[8], EBUS_REG[14:16]}));

  USR4 e26(.S0(1'b0),
           .D(MBOX.PMA[17:20]),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[17:20]));

  USR4 e13(.S0(1'b0),
           .D(MBOX.PMA[21:24]),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[21:24]));

  USR4 e11(.S0(1'b0),
           .D({MBOX.PMA[25:26], MBOX.PMA[34:35]}),
           .S3(1'b0),
           .SEL({2{MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q({EBUS_REG[25:26], EBUS_REG[34:35]}));

  mux2x4 e31(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             // <DM2> CORE BUSY H on MBZ2 C8.
             .D0({MBOX.CORE_BUSY,
                  ~MBOX.MBOX_ADR_PAR_ERR,
                  ~MBOX.CHAN_ADR_PAR_ERR,
                  EBUS_REG[15]}),
             .D1({~MBOX.CHAN_PAR_ERR,
                  MBOX.CBUS_PAR_LEFT_TE,
                  MBOX.CBUS_PAR_RIGHT_TE,
                  EBUS_REG[16]}),
             .B0(MBZ.EBUSdriver.data[15]),
             .B1(MBZ.EBUSdriver.data[16]));

  mux2x4 e39(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({SHM.AR_PAR_ODD,
                  MBOX.MEM_PAR_IN,
                  MBOX.CSH_PAR_BIT_IN,
                  EBUS_REG[17]}),
             .D1({MBOX.MB_PAR_BIT_IN,
                  CSH_PAR_BIT,
                  1'b0,
                  EBUS_REG[18]}),
             .B0(MBZ.EBUSdriver.data[17]),
             .B1(MBZ.EBUSdriver.data[18]));

  mux2x4 e34(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({~MBOX.CSH_EN_CSH_DATA,
                  ~MBOX.MEM_TO_C_DIAG_EN,
                  ~MBOX.CHAN_READ,
                  EBUS_REG[19]}),
             .D1({MBOX.MB_IN_SEL,
                  EBUS_REG[20]}),
             .B0(MBZ.EBUSdriver.data[19]),
             .B1(MBZ.EBUSdriver.data[20]));

  mux2x4 e35(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({MBOX.NXM_ACK,
                  ~MBZ.RD_PSE_WR_REF,
                  MBOX.MEM_BUSY,
                  EBUS_REG[21]}),
             .D1({CHAN_CORE_BUSY,
                  ~MBOX.NXM_ERR,
                  ~MBOX.HOLD_ERA,
                  EBUS_REG[22]}),
             .B0(MBZ.EBUSdriver.data[21]),
             .B1(MBZ.EBUSdriver.data[22]));

  mux2x4 e32(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({~MBOX.NXM_ANY,
                  ~MBZ.RD_PSE_WR_REF,
                  NXM_T2,
                  EBUS_REG[23]}),
             .D1({~NXM_T6comma7,
                  ~MBOX.SBUS_ERR,
                  ~MBOX.MB_PAR_ERR,
                  EBUS_REG[24]}),
             .B0(MBZ.EBUSdriver.data[23]),
             .B1(MBZ.EBUSdriver.data[24]));

  mux2x4 e44(.EN(CTL.DIAG_READ_FUNC_16x),
             .SEL(CTL.DIAG[5:6]),
             .D0({~MBOX.CHAN_NXM_ERR,
                  ~MBOX.NXM_DATA_VAL,
                  PAG.MB_00to17_PAR,
                  EBUS_REG[25]}),
             .D1({PAG.MB_18to35_PAR,
                  CSH.PAR_BIT_A,
                  CSH.PAR_BIT_B,
                  EBUS_REG[26]}),
             .B0(MBZ.EBUSdriver.data[25]),
             .B1(MBZ.EBUSdriver.data[26]));

  assign MBZ.EBUSdriver.driving = CTL.DIAG_READ_FUNC_16x;
  assign MBZ.EBUSdriver.data[0:8]   = EBUS_REG[0:8];
  assign MBZ.EBUSdriver.data[14]    = EBUS_REG[14];
  assign MBZ.EBUSdriver.data[34:35] = EBUS_REG[34:35];


  // MBZ3 p.305
  bit [0:1] ignoredE23;
  USR4 e23(.S0(1'b0),
           .D('0),
           .S3(~MBOX.NXM_ACKN & ~NXM_CLR_T0),
           .SEL({NXM_FLG & MEM_START_C,
                 NXM_FLG & MEM_START_C & ~MBOX.PHASE_CHANGE_COMING}),
           .CLK(clk),
           .Q({ignoredE23, MBOX.NXM_ACKN, NXM_CLR_T0}));

  bit e51q2, e71q7;
  bit e68q4, e57q3, e72q2;
  assign MBOX_NXM_ERR_CLR = APR.NXM_ERR;
  assign MBOX.NXM_DATA_VAL = NXM_CLR_T0 & MEM_RD_RQ;
  assign NXM_CLR_DONE = NXM_FLG & ~MEM_START_C;
  assign MBOX.NXM_ANY = NXM_FLG;
  assign MEM_START_C = MBOX.MEM_START_A | MBOX.MEM_START_B;
  assign RESET = CLK.MR_RESET;
  assign MBOX.CHAN_NXM_ERR = CHAN_MEM_REF & ~e51q2 & MBOX.NXM_ERR;
  assign e71q7 = MBOX.MEM_START_A | MBOX.MEM_START_B | MBOX.RQ_HOLD_FF;
  assign SEQUENTIAL_RQ = (e71q7 | CHAN_CORE_BUSY) &
                         (SEQUENTIAL_RQ | ~RESET | CHAN_CORE_BUSY);
  assign MBOX.HOLD_ERA = ~e71q7 | ERR_HOLD | RQ_HOLD_DLY | NXM_FLG;
  assign ERR_HOLD = APR.ANY_EBOX_ERR_FLG | MBOX.NXM_ERR | MB_PAR_ERR | RESET | ADR_PAR_ERR_FLG;
  assign HOLD_ERR_REG = ERR_HOLD | NXM_FLG;
  assign e72q2 = e68q4 | RESET;

  always_ff @(posedge clk) NXM_FLG <= NXM_CRY_A & NXM_CRY_B & MEM_START_C |
                                      NXM_FLG & ~NXM_CLR_DONE & ~RESET;
  // <DH2> CORE BUSY L on MBZ3 B7.
  always_ff @(posedge clk) CHAN_MEM_REF <= MEM_START_C & CHAN_CORE_BUSY | MBOX.CORE_BUSY & CHAN_MEM_REF & ~RESET;
  always_ff @(posedge clk) A_CHANGE_COMING <= MBOX.A_CHANGE_COMING_IN;
  always_ff @(posedge clk) MBOX.NXM_ERR <= NXM_CLR_DONE |
                                           MBOX.NXM_ERR & ~MBOX_NXM_ERR_CLR & ~RESET;
  always_ff @(posedge clk) e51q2 <= MBOX.NXM_ERR;
  always_ff @(posedge clk) RQ_HOLD_DLY <= e71q7;
  always_ff @(posedge clk) e68q4 <= MBOX.A_CHANGE_COMING_IN ^ e72q2;
  always_ff @(posedge clk) e57q3 <= e72q2 & MBOX.A_CHANGE_COMING_IN;

  UCR4 e53(.SEL({MEM_START_C, 1'b0}),
           .D('0),
           .CLK(clk),
           .CIN(e57q3),
           .COUT(NXM_CRY_A),
           .Q());
  
  UCR4 e48(.SEL({MEM_START_C, 1'b0}),
           .D('0),
           .CLK(clk),
           .CIN(NXM_CRY_A),
           .COUT(NXM_CRY_B),
           .Q());

  // MBZ4 p.306
  bit e57q2, e25q2, e25q15, e25q3, e30q13;
  always_ff @(posedge clk) e57q2 <= e57q2 & MEM_START_C |
                                    MBOX.ACKN_PULSE & MEM_START_C;
  always_ff @(posedge clk) e25q2 <= NXM_FLG;
  always_ff @(posedge clk) NXM_T2 <= NXM_FLG & ~e25q2 |
                                     ~e57q2 & ~NXM_FLG & MEM_START_C & MBOX.ACKN_PULSE;
  always_ff @(posedge clk) NXM_T3 <= NXM_T2;
  always_ff @(posedge clk) NXM_T4 <= NXM_T3;
  always_ff @(posedge clk) NXM_T5 <= NXM_T4;
  always_ff @(posedge clk) NXM_T6 <= NXM_T4;
  always_ff @(posedge clk) e25q15 <= NXM_T6 & MEM_RD_RQ;
  always_ff @(posedge clk) SBUS_ERR_FLG <= MBOX.MEM_ERROR & A_CHANGE_COMING |
                                           ~APR.SBUS_ERR & MBOX.SBUS_ERR & ~RESET;
  always_ff @(posedge clk) MB_PAR_ERR <= ~MBOX.MB_PAR_ODD & MB_TEST_PAR_B_IN |
                                         ~MBOX.MB_PAR_ODD & MB_TEST_PAR_A_IN & ~APR.MB_PAR_ERR |
                                         MBOX.MB_PAR_ERR & ~RESET & ~APR.MB_PAR_ERR |
                                         ~MBOX.MB_PAR_ODD & MBOX.ACKN_PULSE & ~MEM_RD_RQ;
  always_ff @(posedge clk) ADR_PAR_ERR_FLG <= MBOX.MEM_ADR_PAR_ERR & A_CHANGE_COMING |
                                              ~APR.S_ADR_P_ERR & MBOX.MBOX_ADR_PAR_ERR & ~RESET;
  always_ff @(posedge clk) e25q3 <= ADR_PAR_ERR_FLG;
  always_ff @(posedge clk) e30q13 <= MB_PAR_ERR;

  assign MEM_RD_RQ = MBOX.MEM_RD_RQ;
  assign MEM_WR_RQ = MBOX.MEM_WR_RQ;
  assign NXM_T6comma7 = NXM_T6 | e25q15;
  // <EA1> CORE BUSY A H on MBZ4 A5.
  // Same signal drives MBZ4 CORE BUSY A L and MBZ4 CORE BUSY A H.
  assign CORE_BUSY_IN = NXM_T2 | NXM_T3 | NXM_T4 | NXM_T5 | MBC.CORE_BUSY;
  assign LOAD_MB_MAGIC = ~ERR_HOLD & NXM_T6comma7 & NXM_FLG |
                         MB_TEST_PAR_A_IN & ~HOLD_ERR_REG |
                         MB_TEST_PAR_B_IN & ~HOLD_ERR_REG |
                         ~HOLD_ERR_REG & MBOX.ACKN_PULSE & ~MEM_RD_RQ;
  assign MBOX.SBUS_ERR = SBUS_ERR_FLG;
  assign MBOX.MB_PAR_ERR = MB_PAR_ERR;
  assign MBOX.MBOX_ADR_PAR_ERR = ADR_PAR_ERR_FLG;
  assign MBOX.CHAN_ADR_PAR_ERR = ~e25q3 & MBOX.MBOX_ADR_PAR_ERR & CHAN_MEM_REF;
  assign MBOX.CHAN_PAR_ERR = ~e30q13 & MBOX.MB_PAR_ERR & CHAN_MEM_REF;

  USR4  e6(.S0(1'b0),
           .D({MBOX.MB_DATA_CODE_2, MBOX.MB_DATA_CODE_1, MBOX.MB_SEL}),
           .S3(1'b0),
           .SEL({2{LOAD_MB_MAGIC}}),
           .CLK(clk),
           .Q({MB_DATA_SOURCE, MB_WD_SEL}));


  // MBZ5 p.307
  bit [2:3] e45Ignored, e56Ignored;
  USR4 e45(.S0(1'b0),
           .D({CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, 2'b00}),
           .S3(1'b0),
           .SEL({2{CRC.CBUS_OUT_HOLD}}),
           .CLK(clk),
           .Q({MBOX.CBUS_PAR_LEFT_TE, MBOX.CBUS_PAR_RIGHT_TE, e45Ignored}));

  USR4 e56(.S0(1'b0),
           .D({CH_BUF_00to17_PAR, CH_BUF_18to35_PAR, 2'b00}),
           .S3(1'b0),
           .SEL({2{MBOX.CH_T0}}),
           .CLK(clk),
           .Q({MB_CH_BUF_00to17_PAR, MB_CH_BUF_18to35_PAR, e56Ignored}));

  assign CH_BUF_IN_00to17_PAR = CH_BUF_MB_SEL ? PAG.MB_00to17_PAR : CH_REG_00to17_PAR;
  assign CH_BUF_IN_18to35_PAR = CH_BUF_MB_SEL ? PAG.MB_18to35_PAR : CH_REG_18to35_PAR;
  assign CH_BUF_PAR_BIT = MB_CH_BUF_00to17_PAR ^ MB_CH_BUF_18to35_PAR;
  assign CCW_PAR_BIT = CCL.ODD_WC_PAR ^ CCW.ODD_ADR_PAR;

  always_latch if (CH_REG_HOLD) begin
    CH_REG_00to17_PAR <= CCL.DATA_REVERSE ?
                         MBOX.CBUS_PAR_RIGHT_RE :
                         MBOX.CBUS_PAR_LEFT_RE;
    CH_REG_18to35_PAR <= CCL.DATA_REVERSE ?
                         MBOX.CBUS_PAR_LEFT_RE :
                         MBOX.CBUS_PAR_RIGHT_RE;
  end

  // e60,e55
  bit [0:1] chBufParRAM[0:127];
  always_ff @(posedge clk) CH_BUF_ADR <= CRC.CH_BUF_ADR; // Combine E54 hexff and E51q4 dff section
  always_ff @(posedge clk) CH_REG_HOLD <= ~MBOX.CH_T2;
  always_ff @(posedge clk) {CH_BUF_00to17_PAR, CH_BUF_18to35_PAR} = chBufParRAM[CH_BUF_ADR];

  always_ff @(MBOX.CH_BUF_WR) if (MBOX.CH_BUF_WR)
    chBufParRAM[CH_BUF_ADR] <= {CH_BUF_IN_00to17_PAR, CH_BUF_IN_18to35_PAR};

  mux2x4 e50(.EN(MBOX.MEM_TO_C_EN),
             .SEL(MBOX.MEM_TO_C_SEL),
             .D0({SHM.AR_PAR_ODD,
                  MBOX.MB_PAR,
                  MBOX.MEM_PAR_IN,
                  1'b0}),
             .B0(MBOX.CSH_PAR_BIT_IN),
             .D1(), .B1());

  mux e40(.en(1'b1),
          .sel(MBOX.MB_IN_SEL),
          .d({CSH_PAR_BIT,
              1'b0,
              SHM.AR_PAR_ODD,
              CH_BUF_PAR_BIT,
              MBOX.MEM_PAR_IN,
              1'b0,
              CCW_PAR_BIT,
              1'b0}),
          .q(MBOX.MB_PAR_BIT_IN));

  // MBZ6 p.308
  assign CSH.PAR_BIT_A = MBOX.CSH_PAR_BIT_IN | (|MBOX.CSH_PAR_BIT_A);
  assign CSH.PAR_BIT_B = |MBOX.CSH_PAR_BIT_B;
  assign CSH_PAR_BIT =   |MBOX.CSH_PAR_BIT_A | CSH.PAR_BIT_B;

  assign ERA_SEL = APR.EBOX_ERA & CSH.EBOX_CYC;
  assign EBUS_REG_IN = ERA_SEL ?
                       {MB_WD_SEL,
                        CCA_REF,
                        CHAN_REF,
                        MB_DATA_SOURCE,
                        MEM_WRITE} :
                       {MCL.VMA_USER,
                        PAG.PF_HOLD_01_IN,
                        PAG.PF_HOLD_02_IN,
                        PAG.PF_HOLD_03_IN,
                        PAG.PF_HOLD_04_IN,
                        PAG.PF_HOLD_05_IN,
                        PAG.PT_PUBLIC};
  assign MB_TEST_PAR_B_IN = CCL.CH_TEST_MB_PAR |
                            // MBZ4 CORE BUSY A L on MBZ6 A3.
                            MBOX.CACHE_TO_MB_T4 & MBOX.CORE_BUSY & ~RESET;

  bit ignoredE18;
  USR4 e18(.S0(1'b0),
           .D({~MEM_RD_RQ, CHAN_CORE_BUSY, MTR.CCA_WRITEBACK, 1'b0}),
           .S3(1'b0),
           .SEL({2{MBOX.HOLD_ERA}}),
           .CLK(clk),
           .Q({MEM_WRITE, CHAN_REF, CCA_REF, ignoredE18}));
endmodule
