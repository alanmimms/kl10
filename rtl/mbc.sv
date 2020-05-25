// 04-25-2020: Manually compared with schematics.
`timescale 1ns/1ns
`include "ebox.svh"
// M8531 MBC (MBOX control #3)
module mbc(iAPR APR,
           iCCL CCL,
           iCLK CLK,
           iCON CON,
           iCSH CSH,
           iCTL CTL,
           iMBC MBC,
           iMBX MBX,
           iMBOX MBOX,
           iPMA PMA
           );

  bit clk, RESET;
  bit [34:35] ADR;
  bit [0:1] MATCH_HOLD;
  bit CSH_VAL_WR_PLS_FF, CSH_WR_WR_PLS_FF, CSH_ADR_WR_PLS_FF, CSH_WR_DATA_FF;
  bit CSH_VAL_WR_PULSE, CSH_WR_WR_PULSE, CSH_ADR_WR_PULSE;
  bit CACHE_WR_00, CACHE_WR_09, CACHE_WR_18, CACHE_WR_27;
  bit RQ_HOLD, WRITE_OK, FORCE_BAD_ADR_PAR, RD_PAUSE_2ND_HALF, LAST_ACKN_SEEN;
  bit A_PHASE, CLK_A_PHASE_COMING, FIRST_WD_ADR_SEL;
  bit [0:3] RQ_A;
  bit RQ_0B;
  bit MEM_START_RD, MEM_START_SET, MEM_START_CLR, CORE_BUSY;
  bit ANY_SBUS_RQ_IN, PMA_ADR_PAR_HOLD;
  bit CORE_DATA_VALIDminus2, CORE_RD_IN_PROG, INIT_COMP, LAST_ACKN, ANY_REQUEST;
  bit ANY_RQS_LEFT, HOLD_MATCH;
  bit [27:33] EBUS_REG;
  bit [27:35] PMA_HOLD;

  // MBC1 p.189
  assign clk = CLK.MBC;
  assign RESET = CLK.MR_RESET;
    // NOTE use MBOX.PMA for local references to PMA.

  USR4  e6(.S0(1'b0),
           .D(MBOX.CACHE_ADR[27:30]),
           .S3(1'b0),
           .SEL({2{~MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q(EBUS_REG[27:30]));

  bit ignoreE1;
  USR4  e1(.S0(1'b0),
           .D({MBOX.CACHE_ADR[31:33], 1'b0}),
           .S3(1'b0),
           .SEL({2{~MBOX.LOAD_EBUS_REG}}),
           .CLK(clk),
           .Q({EBUS_REG[31:33], ignoreE1}));

  USR4  e4(.S0(1'b0),
           .D(PMA.PA[27:30]),
           .S3(1'b0),
           .SEL({2{MBX.REFILL_HOLD}}),
           .CLK(clk),
           .Q(PMA_HOLD[27:30]));

  bit ignoredE10;
  USR4 e10(.S0(1'b0),
           .D({PMA.PA[31:33], 1'b0}),
           .S3(1'b0),
           .SEL({2{MBX.REFILL_HOLD}}),
           .CLK(clk),
           .Q({PMA_HOLD[31:33], ignoredE10}));


  mux2x4 e13(.EN(1'b1),
             .D0({1'b0, PMA.PA[27], PMA_HOLD[27], 1'b0}),
             .D1({1'b0, PMA.PA[28], PMA_HOLD[28], 1'b0}),
             .SEL({MBX.REFILL_ADR_EN, CSH.ADR_PMA_EN}),
             .B0(MBX.CSH_ADR[27]),
             .B1(MBX.CSH_ADR[28]));

  mux2x4 e14(.EN(1'b1),
             .D0({1'b0, PMA.PA[29], PMA_HOLD[29], 1'b0}),
             .D1({1'b0, PMA.PA[30], PMA_HOLD[30], 1'b0}),
             .SEL({MBX.REFILL_ADR_EN, CSH.ADR_PMA_EN}),
             .B0(MBX.CSH_ADR[29]),
             .B1(MBX.CSH_ADR[30]));

  mux2x4  e7(.EN(1'b1),
             .D0({1'b0, PMA.PA[31], PMA_HOLD[31], 1'b0}),
             .D1({1'b0, PMA.PA[32], PMA_HOLD[32], 1'b0}),
             .SEL({MBX.REFILL_ADR_EN, CSH.ADR_PMA_EN}),
             .B0(MBX.CSH_ADR[31]),
             .B1(MBX.CSH_ADR[32]));

  mux2x4  e2(.EN(1'b1),
             .D0({1'b0, PMA.PA[33], PMA_HOLD[33], 1'b0}),
             .D1('0),
             .SEL({MBX.REFILL_ADR_EN, CSH.ADR_PMA_EN}),
             .B0(MBX.CSH_ADR[33]),
             .B1());

  mux4x2  e8(.SEL(MBX.REFILL_ADR_EN),
             .D0(PMA.PA[27:30]),
             .D1(MBC.PMA_HOLD[27:30]),
             .B(MBOX.CACHE_ADR[27:30]));

  bit ignoredE3;
  mux4x2  e3(.SEL(MBX.REFILL_ADR_EN),
             .D0({PMA.PA[31:33], 1'b0}),
             .D1({MBC.PMA_HOLD[31:33], 1'b0}),
             .B({MBOX.CACHE_ADR[31:33], ignoredE3}));

  mux2x4 e23(.EN(1'b1),
             .SEL({MBX.REFILL_ADR_EN, ~MBC.FIRST_WD_ADR_SEL}),
             .D0({{2{MBOX.PMA[34]}}, PMA_HOLD[34], MBOX.MB_SEL[2]}),
             .D1({{2{MBOX.PMA[35]}}, PMA_HOLD[35], MBOX.MB_SEL[1]}),
             .B0(MBOX.CACHE_ADR[34]),
             .B1(MBOX.CACHE_ADR[35]));

  USR4 e18(.S0(1'b0),
           .D({CSH.MATCH_HOLD_IN, MBOX.PMA[34:35]}),
           .S3(1'b0),
           .SEL({2{MBX.REFILL_HOLD}}),
           .CLK(clk),
           .Q({MATCH_HOLD, PMA_HOLD[34:35]}));

  bit WRITE_OK_IN_A, WRITE_OK_IN_B;
  assign MBOX.CAM_SEL = MATCH_HOLD;
  assign WRITE_OK_IN_A = |(PMA.PA[27:30] ^ PMA_HOLD[27:30]);
  assign WRITE_OK_IN_B = |(PMA.PA[31:33] ^ PMA_HOLD[31:33]);
  assign MBC.WRITE_OK = WRITE_OK_IN_A | WRITE_OK_IN_B | ~MBX.REFILL_HOLD;


  // MBC2 p.190
  USR4 e58(.S0(1'b0),
           .D({CSH.WR_FROM_MEM_NXT | MBX.CCA_INVAL_T4 | CSH.EBOX_WR_T4_IN | CSH.CHAN_WR_T5_IN |
               MBC.CSH_DATA_CLR_T1 & ~CSH.ANY_VAL_HOLD & ~CSH.ONE_WORD_RD,
               MBX.WRITEBACK_T2    | MBX.CCA_INVAL_T4 | CSH.EBOX_WR_T4_IN | CSH.CHAN_WR_T5_IN |
               MBC.CSH_DATA_CLR_T1 & ~CSH.ANY_VAL_HOLD & ~CSH.ONE_WORD_RD,
               MBC.CSH_DATA_CLR_T1 & ~CSH.ANY_VAL_HOLD & ~CSH.ONE_WORD_RD,
               CSH.CACHE_WR_IN}),
           .S3(1'b0),
           .SEL(2'b00),
           .CLK(clk),
           .Q({CSH_VAL_WR_PLS_FF, CSH_WR_WR_PLS_FF, CSH_ADR_WR_PLS_FF, CSH_WR_DATA_FF}));

  assign MBOX.CSH_VAL_WR_PULSE = CSH_VAL_WR_PLS_FF;
  assign CSH_VAL_WR_PULSE = CSH_VAL_WR_PLS_FF;

  assign MBOX.CSH_WR_WR_PULSE = CSH_WR_WR_PLS_FF;
  assign CSH_WR_WR_PULSE = CSH_WR_WR_PLS_FF;

  assign MBOX.CSH_ADR_WR_PULSE = CSH_ADR_WR_PLS_FF;
  assign CSH_ADR_WR_PULSE = CSH_ADR_WR_PLS_FF;

  assign MBOX.CACHE_WR_00 = CSH_WR_DATA_FF;
  assign CACHE_WR_00 = CSH_WR_DATA_FF;

  assign MBOX.CACHE_WR_09 = CSH_WR_DATA_FF;
  assign CACHE_WR_09 = CSH_WR_DATA_FF;

  assign MBOX.CACHE_WR_18 = CSH_WR_DATA_FF;
  assign CACHE_WR_18 = CSH_WR_DATA_FF;

  assign MBOX.CACHE_WR_27 = CSH_WR_DATA_FF;
  assign CACHE_WR_27 = CSH_WR_DATA_FF;

  assign RQ_HOLD = MBOX.RQ_HOLD_FF | MBC.MEM_START;
  assign MBOX.SBUS_ADR_HOLD = RQ_HOLD;

  assign MBC.DATA_CLR_DONE_IN = MBC.CSH_DATA_CLR_T3 | CSH.DATA_CLR_DONE;

  always_ff @(posedge clk)
    MBOX.RQ_HOLD_FF <= MBX.CHAN_WR_CYC & CSH.CHAN_T3 |
                       ~MBC.MEM_START & MBOX.RQ_HOLD_FF & ~RESET;

  always_ff @(posedge clk)
    FORCE_BAD_ADR_PAR <= APR.WR_BAD_ADR_PAR & ~MBC.MEM_START |
                         MBC.MEM_START & FORCE_BAD_ADR_PAR & ~RESET;

  always_ff @(posedge clk)
    MBC.CSH_DATA_CLR_T1 <= CSH.CLEAR_WR_T0 & WRITE_OK |
                           CSH.EBOX_T3 & CSH.E_CORE_RD_RQ;

  always_ff @(posedge clk) MBC.CSH_DATA_CLR_T2 <= MBC.CSH_DATA_CLR_T1;
  always_ff @(posedge clk) MBC.CSH_DATA_CLR_T3 <= MBC.CSH_DATA_CLR_T2;

  always_ff @(posedge clk)
    MBOX.CSH_SEL_LRU <= MBC.CSH_DATA_CLR_T1 & ~CSH.ANY_VAL_HOLD |
                        MBC.CSH_DATA_CLR_T2 & ~CSH.ANY_VAL_HOLD;


  // MBC3 p.191
  bit e20q15, e25q15, e56q13;
    // VERY STRANGE. At 19.978us into my sim, MBOX.PHASE_CHANGE_COMING
    // is 0 and CLK_A_PHASE_COMING is 1 but MBOX.A_CHANGE_COMING_IN is
    // not 1 at this point. I think this always_comb, which is a big
    // group of signals needs to be broken up. I don't yet know why.
  assign MBOX.A_CHANGE_COMING_IN = ~MBOX.PHASE_CHANGE_COMING & CLK_A_PHASE_COMING;

  // Note the distinction between MBOX.CORE_BUSY and local CORE_BUSY here.
  // MBOX.CORE_BUSY is <DS1> -CORE BUSY L on MBC3 B7 p.191.
  // MBC's local CORE_BUSY is -MBC3 CORE BUSY L on same page and area.
  // Local CORE_BUSY = MBC3 CORE BUSY H is generated on MBC3 A3.
  // CORE BUSY A H <EE1> is generated there also.
  // MBC5 CORE BUSY B is used on MBC5 D6 p.193.
  // MBC5 CORE BUSY B is driven from MBC5 C7, derived from <EE1> CORE BUSY A H.
  assign MEM_START_SET = CSH.E_CORE_RD_RQ & ~MBOX.CORE_BUSY |
                         PMA.CSH_WRITEBACK_CYC           & MBOX.CACHE_TO_MB_T4 |
                         ~CORE_BUSY & CSH.E_CACHE_WR_CYC & MBOX.CACHE_TO_MB_T4 |
                         CCL.START_MEM |
                         CSH.CHAN_RD_T5     & ANY_SBUS_RQ_IN |
                         CSH.PAGE_REFILL_T9 & ANY_SBUS_RQ_IN;

  assign RD_PAUSE_2ND_HALF = CSH.RD_PAUSE_2ND_HALF;

  assign MEM_START_CLR = MBC.MEM_START & MBOX.PHASE_CHANGE_COMING & LAST_ACKN_SEEN |
                         MBOX.MEM_START_A & MBC.A_CHANGE_COMING & LAST_ACKN |
                         MBOX.MEM_START_B & MBC.B_CHANGE_COMING & LAST_ACKN |
                         RESET;

  assign MBOX.PHASE_CHANGE_COMING = ~e25q15;
  assign MBC.A_PHASE_COMING = e20q15 | e56q13 & ~RESET;
  assign CLK_A_PHASE_COMING = MBC.A_PHASE_COMING;
  assign MBOX.CSH_VAL_WR_DATA = MBOX.MEM_TO_C_EN;
  assign MBOX.CSH_VAL_SEL_ALL = ~MBOX.MEM_TO_C_EN & ~CSH.CHAN_WR_CACHE;
  assign MBC.CSH_WR_WR_DATA = CSH.DATA_CLR_DONE & CSH.E_CACHE_WR_CYC;
  assign MBOX.CSH_WR_SEL_ALL = MBC.CSH_WR_WR_DATA & ~CSH.CHAN_WR_CACHE;
  assign MBOX.MEM_TO_C_EN = CSH.DATA_CLR_DONE & MBX.MEM_TO_C_EN;
  assign ANY_SBUS_RQ_IN = |MBX.RQ_IN;
  assign MBC.CORE_BUSY = CORE_BUSY;

  always_ff @(posedge clk) MBC.A_CHANGE_COMING <= MBOX.A_CHANGE_COMING_IN;
  always_ff @(posedge clk) MBC.B_CHANGE_COMING <= ~MBOX.PHASE_CHANGE_COMING & ~CLK_A_PHASE_COMING;
  always_ff @(posedge clk) e56q13 <= RESET;
  always_ff @(posedge clk) e20q15 <= ~A_PHASE | e56q13 & ~RESET;
  always_ff @(posedge clk) e25q15 <= (~A_PHASE | e56q13 & ~RESET) ^ CLK_A_PHASE_COMING;
  always_ff @(posedge clk) A_PHASE <= MBC.A_PHASE_COMING;

  always_ff @(posedge clk)
    MBC.INH_1ST_MB_REQ <= CSH.E_CORE_RD_RQ | ~CSH_VAL_WR_PULSE & MBC.INH_1ST_MB_REQ & ~RESET;

  always_ff @(posedge clk) FIRST_WD_ADR_SEL <= MBC.INH_1ST_MB_REQ;

  always_ff @(posedge clk)
    MBOX.DATA_VALID_A_OUT <= (MBOX.DATA_VALID_A_OUT | MBC.A_CHANGE_COMING) &
                             (~MBC.A_CHANGE_COMING |
                              MBX.CACHE_TO_MB_T2 & CSH.RD_PAUSE_2ND_HALF);
  
  always_ff @(posedge clk)
    MBOX.DATA_VALID_B_OUT <= (MBOX.DATA_VALID_B_OUT | MBC.B_CHANGE_COMING) &
                              (~MBC.B_CHANGE_COMING |
                               MBX.CACHE_TO_MB_T2 & CSH.RD_PAUSE_2ND_HALF);
  
  always_ff @(posedge clk)
    // This drives <EE1> CORE BUSY A H as well.
    CORE_BUSY <= (CORE_BUSY & ~MBC.CORE_DATA_VALID |
                  MBX.CACHE_TO_MB_T2 & CSH.RD_PAUSE_2ND_HALF) &
                 ~RESET;


  // MBC4 p.192
  bit [1:3] e69SR;
  assign MBC.MEM_START = MBOX.MEM_START_A | MBOX.MEM_START_B;
  assign LAST_ACKN = RQ_A[1:3] == '0 && MBOX.ACKN_PULSE;
  assign MBOX.ACKN_PULSE = (MBOX.MEM_ACKN_A | MBOX.NXM_ACKN) & MBC.A_CHANGE_COMING |
                           (MBOX.MEM_ACKN_B | MBOX.NXM_ACKN) & MBC.B_CHANGE_COMING & ~RESET;
  assign MBC.CORE_DATA_VALminus2 = MBOX.NXM_DATA_VAL & MBC.A_CHANGE_COMING |
                                   MBOX.MEM_DATA_VALID_A & MBC.A_CHANGE_COMING |
                                   MBOX.MEM_DATA_VALID_B & MBC.B_CHANGE_COMING |
                                   MBOX.NXM_DATA_VAL & MBC.B_CHANGE_COMING;
  assign CORE_DATA_VALIDminus2 = MBC.CORE_DATA_VALminus2;
  assign MBOX.CORE_RD_IN_PROG = ~RESET & CORE_RD_IN_PROG;
  assign ANY_REQUEST = |(e69SR[1:3]);
  assign MBOX.MEM_ADR_PAR = PMA_ADR_PAR_HOLD ^
                            MBOX.MEM_RD_RQ ^ 
                            MBOX.MEM_WR_RQ ^
                            (^MBOX.MEM_RQ) ^
                            (^ADR) ^
                            FORCE_BAD_ADR_PAR;
  assign ANY_RQS_LEFT = ANY_REQUEST | ~MBC.CORE_DATA_VALID;
  assign INIT_COMP = ANY_RQS_LEFT & CORE_RD_IN_PROG |
                     ~MBOX.NXM_ACKN & ~LAST_ACKN_SEEN
                     & ~MBC.CORE_ADR[34] & ~MBC.CORE_ADR[35] & MEM_START_RD;
  assign MEM_START_RD = (MBOX.MEM_START_A | MBOX.MEM_START_B) & MBOX.MEM_RD_RQ;

  always_ff @(posedge clk)
    MBOX.MEM_START_A <= MBOX.MEM_START_A & ~MEM_START_CLR |
                       ~MBOX.MEM_START_B & MBC.A_CHANGE_COMING & MEM_START_SET;
  
  always_ff @(posedge clk)
    MBOX.MEM_START_B <= MBOX.MEM_START_B & ~MEM_START_CLR |
                       ~MBOX.MEM_START_A & MBC.B_CHANGE_COMING & MEM_START_SET;
  
  always_ff @(posedge clk) LAST_ACKN_SEEN <= LAST_ACKN | ~MBOX.PHASE_CHANGE_COMING & LAST_ACKN_SEEN;
  always_ff @(posedge clk) MBC.CORE_DATA_VALminus1 <= CORE_DATA_VALIDminus2;
  always_ff @(posedge clk) MBC.CORE_DATA_VALID <= MBC.CORE_DATA_VALminus1;
  always_ff @(posedge clk) CORE_RD_IN_PROG <= INIT_COMP;

  bit [0:1] ignoredE76;
  UCR4 e76(.CIN(1'b1),
           .CLK(clk),
           .SEL({INIT_COMP & CORE_RD_IN_PROG,
                 CORE_RD_IN_PROG & ~MBC.CORE_DATA_VALID & RQ_0B & INIT_COMP |
                 ~INIT_COMP & MEM_START_RD}),
           .D({2'b00, ADR}),
           .COUT(),
           .Q({ignoredE76, MBC.CORE_ADR}));

  USR4 e57(.S0(1'b0),
           .D(MBX.RQ_IN),
           .S3(1'b0),
           .SEL({2{RQ_HOLD}}),
           .CLK(clk),
           .Q(MBOX.MEM_RQ));

  USR4 e63(.S0(1'b0),
           .D(MBX.RQ_IN),
           .S3(1'b0),
           .SEL({RQ_HOLD, RQ_HOLD & ~MBOX.ACKN_PULSE & RQ_A[0]}),
           .CLK(clk),
           .Q(RQ_A));

  USR4 e69(.S0(1'b0),
           .D(MBX.RQ_IN),
           .S3(~INIT_COMP & RQ_0B),
           .SEL({MEM_START_RD | INIT_COMP, INIT_COMP & ~MBC.CORE_DATA_VALID & RQ_0B}),
           .CLK(clk),
           .Q({RQ_0B, e69SR}));

  bit ignoredE62;
  USR4 e62(.S0(1'b0),
           .D({MBX.MEM_RD_RQ_IN, PMA.ADR_PAR, {2{MBX.MEM_WR_RQ_IN}}}),
           .S3(1'b0),
           .SEL({2{RQ_HOLD}}),
           .CLK(clk),
           .Q({MBOX.MEM_RD_RQ, PMA_ADR_PAR_HOLD, ignoredE62, MBOX.MEM_WR_RQ}));

  always_latch if (RQ_HOLD) ADR <= MBOX.SBUS_ADR[34:35];


  // MBC5 p.193
  bit e56q4;
  assign MBC.EBUSdriver.driving = CTL.DIAG_READ_FUNC_16x;
  assign HOLD_MATCH = e56q4 |
                      CSH.DATA_CLR_DONE & CSH.E_CACHE_WR_CYC & ~RESET;
  assign MBOX.FORCE_VALID_MATCH[0] = MBOX.CSH_WR_EN[0] & CSH.DATA_CLR_DONE | MBX.FORCE_MATCH_EN |
                                     ~MBOX.PMA[34] & ~MBOX.PMA[35] & MBX.CCA_ALL_PAGES_CYC;
  assign MBOX.FORCE_VALID_MATCH[1] = MBOX.CSH_WR_EN[1] & CSH.DATA_CLR_DONE | MBX.FORCE_MATCH_EN |
                                     ~MBOX.PMA[34] &  MBOX.PMA[35] & MBX.CCA_ALL_PAGES_CYC;
  assign MBOX.FORCE_VALID_MATCH[2] = MBOX.CSH_WR_EN[2] & CSH.DATA_CLR_DONE | MBX.FORCE_MATCH_EN |
                                     MBOX.PMA[34] & ~MBOX.PMA[35] & MBX.CCA_ALL_PAGES_CYC;
  assign MBOX.FORCE_VALID_MATCH[3] = MBOX.CSH_WR_EN[3] & CSH.DATA_CLR_DONE | MBX.FORCE_MATCH_EN |
                                     MBOX.PMA[34] &  MBOX.PMA[35] & MBX.CCA_ALL_PAGES_CYC;

  always_ff @(posedge clk)
    e56q4 <= MBC.CSH_DATA_CLR_T1 & CSH.E_CACHE_WR_CYC |
             ~CSH.EBOX_WR_T4_IN & e56q4 & ~RESET;

  mux e38(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({MBOX.FORCE_VALID_MATCH[0],
              ~MBC.CSH_DATA_CLR_T1,
              CACHE_WR_00,
              ~MBC.B_CHANGE_COMING,
              MBOX.DATA_VALID_B_OUT,
              MBOX.CAM_SEL[1],
              MBOX.MEM_RD_RQ,
              EBUS_REG[27]}),
          .q(MBC.EBUSdriver.data[27]));
  
  mux e16(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({MBOX.FORCE_VALID_MATCH[1],
              ~MBC.CSH_DATA_CLR_T2,
              CACHE_WR_09,
              CORE_BUSY,
              MBC.INH_1ST_MB_REQ,
              MBOX.CAM_SEL[0],
              MBOX.MEM_RQ[0],
              EBUS_REG[28]}),
          .q(MBC.EBUSdriver.data[28]));
  
  mux e30(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({MBOX.FORCE_VALID_MATCH[2],
              ~MBC.CSH_DATA_CLR_T3,
              CACHE_WR_18,
              MBOX.CSH_VAL_SEL_ALL,
              ~MBOX.MEM_TO_C_EN,
              ~MBC.CORE_DATA_VALminus1,
              MBOX.MEM_RQ[1],
              EBUS_REG[29]}),
          .q(MBC.EBUSdriver.data[29]));
  
  mux e35(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({MBOX.FORCE_VALID_MATCH[3],
              MBOX.CSH_SEL_LRU,
              CACHE_WR_27,
              MBOX.CSH_VAL_WR_DATA,
              ~MBOX.PHASE_CHANGE_COMING,
              ~CORE_DATA_VALIDminus2,
              MBOX.MEM_RQ[2],
              EBUS_REG[30]}),
          .q(MBC.EBUSdriver.data[30]));
  
  mux e48(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({MBC.WRITE_OK,
              CSH_VAL_WR_PULSE,
              MBOX.SBUS_ADR_HOLD,
              MBOX.CSH_WR_SEL_ALL,
              ~MBOX.ACKN_PULSE,
              ~MBC.CORE_DATA_VALID,
              MBOX.MEM_RQ[3],
              EBUS_REG[31]}),
          .q(MBC.EBUSdriver.data[31]));
  
  mux e52(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({CSH_ADR_WR_PULSE,
              CSH_WR_WR_PULSE,
              ~MBC.A_CHANGE_COMING,
              MBC.CSH_WR_WR_DATA,
              MBC.CORE_ADR[34],
              CORE_RD_IN_PROG,
              ~MBC.MEM_START,
              EBUS_REG[32]}),
          .q(MBC.EBUSdriver.data[32]));
  
  mux e21(.en(CTL.DIAG_READ_FUNC_16x),
          .sel(CTL.DIAG[4:6]),
          .d({~CSH.DATA_CLR_DONE,
              MBOX.RQ_HOLD_FF,
              ~ANY_SBUS_RQ_IN,
              MBOX.DATA_VALID_A_OUT,
              MBC.CORE_ADR[35],
              MBOX.MEM_ADR_PAR,
              ~MBOX.MEM_WR_RQ,
              EBUS_REG[33]}),
          .q(MBC.EBUSdriver.data[33]));

  bit [0:1] e12L;
  always_latch if (HOLD_MATCH) e12L <= ~CSH.E_CACHE_WR_CYC ? MATCH_HOLD : CSH.MATCH_HOLD_IN;

  bit [4:7] ignoredE19;
  decoder e19(.en(~CSH.RD_PAUSE_2ND_HALF & ~CSH.ONE_WORD_RD),
              .sel({1'b0, e12L}),
              .q({MBOX.CSH_WR_EN, ignoredE19}));
  
endmodule
