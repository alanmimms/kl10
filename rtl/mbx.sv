// 2020-04-27: Schematic review done: MBX1, MBX2, MBX3, MBX4, MBX5, MBX6.
`timescale 1ns/1ns
`include "ebox.svh"
// M8529 MBX memory control logic
module mbx(iAPR APR,
           iCCL CCL,
           iCCW CCW,
           iCLK CLK,
           iCON CON,
           iCRC CRC,
           iCSH CSH,
           iCTL CTL,
           iEBUS.mod EBUS,
           iEDP EDP,
           iIR IR,
           iMBC MBC,
           iMBOX MBOX,
           iMBX MBX,
           iMCL MCL,
           iPAG PAG,
           iPMA PMA
);

  bit clk;
  bit E_CORE_RD_RQ, EBOX_DIAG_CYC, C_DIR_PAR_ERR, ANY_VAL_HOLD, READY_TO_GO;
  bit EBOX_PAGED, CCA_CYC_DONE, RESET, CSH_CCA_CYC, CSH_CCA_ONE_PAGE;
  bit CCA_HOLD_ADR, MB_WR_RQ_ANY, MB_WR_RQ_P1, MB_WR_RQ_P2, CTOMB_LOAD;
  bit MB_WR_RQ_CLR, MB_WR_RQ_CLR_FF, MB_SEL_HOLD_FF_IN;
  bit MB_REQ_ALLOW, MB_REQ_ALLOW_FF, CORE_BUSY;
  bit [0:3] MB_WR_RQ, CTOMB_WD_RQ, CSH_TO_MB_WD, WD_NEEDED, CSH_WD_VAL;
  bit [0:3] CORE_WD_COMING;     // Larger to drop 4MSBs off E18
  bit SBUS_DIAG_0, SBUS_DIAG_1, SBUS_DIAG_2, SBUS_DIAG_3, SBUS_DIAG_CYC;
  bit CSH_CHAN_CYC, CACHE_TO_MB_T1, CACHE_TO_MB_T3, CACHE_TO_MB_CONT;
  bit RD_NON_VAL_WDS, DIAG_EN, CACHE_TO_MB_DONE, MB_SEL_HOLD_FF, ONE_WORD_RD;
  bit [4:6] DIAG;
  bit [0:2] MB_IN_SEL;
  bit CORE_DATA_VALIDminus1, CORE_DATA_VALID, EBOX_LOAD_REG, CHAN_READ;
  bit MB0_PAR, MB0_DATA_CODE_1, MB0_DATA_CODE_2;
  bit MB1_PAR, MB1_DATA_CODE_1, MB1_DATA_CODE_2;
  bit MB2_PAR, MB2_DATA_CODE_1, MB2_DATA_CODE_2;
  bit MB3_PAR, MB3_DATA_CODE_1, MB3_DATA_CODE_2;
  bit DIAG_CYC_DONE, WR_WDS_IN_MB, CSH_PGRF_CYC;


  // MBX1 p.178
  bit [0:3] e77SR;
  bit e85q2, e85q15;
  assign MBX.REFILL_ADR_EN_NXT = CSH.MB_REQ_GRANT & CSH.READY_TO_GO |
                                 MBC.CSH_DATA_CLR_T3 & E_CORE_RD_RQ |
                                 ~CSH.READY_TO_GO & MBX.REFILL_ADR_EN;
  assign MBX.FORCE_MATCH_EN = MBX.REFILL_ADR_EN | E_CORE_RD_RQ | PMA.CSH_WRITEBACK_CYC;
  assign MBOX.FORCE_NO_MATCH = MBX.FORCE_MATCH_EN |
                               EBOX_DIAG_CYC |
                               MBX.CCA_ALL_PAGES_CYC |
                               ~CON.CACHE_LOOK_EN |
                               C_DIR_PAR_ERR;
  // MBOX.CSH_WD_VAL[0:3] has a local ANDed copy in CSH_WD_VAL[0:3].
  assign CSH_WD_VAL = {4{ANY_VAL_HOLD}} & e77SR;
  assign READY_TO_GO = CSH.READY_TO_GO;
  assign EBOX_PAGED = PMA.EBOX_PAGED;
  assign MBX.CCA_INVAL_T4 = CSH.CCA_INVAL_T4;
  assign CCA_CYC_DONE = CSH.CCA_CYC_DONE;
  assign MBX.CCA_SEL[2] = ~EBOX_LOAD_REG & e85q2 | e85q2 & ~APR.EBOX_CCA & ~RESET;
  assign MBX.CCA_SEL[1] = ~EBOX_LOAD_REG | ~APR.EBOX_CCA;
  assign MBX.CACHE_BIT = (PAG.PT_CACHE & PMA.EBOX_PAGED & MCL.EBOX_CACHE |
                          ~EBOX_PAGED & MCL.EBOX_CACHE) &
                         ~C_DIR_PAR_ERR & MBOX.CACHE_EXISTS;
  assign RESET = CLK.MR_RESET;
  assign CSH_CCA_CYC = CSH.CCA_CYC;
  assign MBX.CCA_ALL_PAGES_CYC = CSH.CCA_CYC & ~CSH_CCA_ONE_PAGE;
  assign MBX.CCA_REQ = e85q15 & ~RESET;

  always_ff @(posedge clk) MBX.REFILL_ADR_EN <= MBX.REFILL_ADR_EN_NXT;
  always_ff @(posedge clk) MBX.EBOX_LOAD_REG <= CSH.EBOX_LOAD_REG;
  always_ff @(posedge clk) e85q2 <= ~CCA_CYC_DONE;
  always_ff @(posedge clk) e85q15 <= (MBX.CCA_REQ | ~MBX.CCA_SEL[1]) &
                                     (~CCA_CYC_DONE | ~PMA.CCA_CRY_OUT);
  always_ff @(posedge clk) CCA_HOLD_ADR <= ~READY_TO_GO & (CSH.CCA_INVAL_T4 | CCA_HOLD_ADR);

  USR4 e77(.S0(1'b0),
           .D(MBOX.CSH_WD_VAL),
           .S3(1'b0),
           .SEL({2{ANY_VAL_HOLD}}),
           .Q(e77SR),
           .CLK(clk));

  bit unusedE78;
  USR4 e78(.S0(1'b0),
           .D({IR.AC[10:12], 1'b0}),
           .S3(1'b0),
           .SEL({2{MBX.CCA_SEL[1]}}),
           .Q({CSH_CCA_ONE_PAGE, MBX.CSH_CCA_VAL_CORE, MBX.CSH_CCA_INVAL_CSH, unusedE78}),
           .CLK(clk));


  // MBX2 p.179
  bit [0:2] e33Q;
  bit e57q7, e45q6;
  assign CACHE_TO_MB_CONT = |CTOMB_WD_RQ;
  assign e45q6 = CSH_CHAN_CYC & ~CCL.CHAN_TO_MEM & ~ANY_VAL_HOLD;
  assign e57q7 = PMA.CSH_WRITEBACK_CYC | CSH_PGRF_CYC | CSH.CHAN_CYC;
  assign CSH_PGRF_CYC = CSH.PGRF_CYC;
  assign MBOX.SBUS_ADR[34] = (PMA.PA[34] | e57q7) &
                             (e33Q[1] | e45q6 | ~e57q7) &
                             (CCW.CHA[34] | ~e57q7 | ~e45q6);
  assign MBOX.SBUS_ADR[35] = (PMA.PA[35] | e57q7) &
                             (e33Q[2] | e45q6 | ~e57q7) &
                             (CCW.CHA[35] | ~e45q6 | ~e57q7); // Last OR gate is A | ~A = 1
  assign MBX.CHAN_WR_CYC = CSH.CHAN_CYC & CCL.CHAN_TO_MEM;
  assign CTOMB_LOAD = MBX.CHAN_WR_CYC & CSH.T2 |
                      CSH.PAGE_REFILL_T8 |
                      CSH.CHAN_T4 & ~MBX.CHAN_WR_CYC;
  assign CSH_TO_MB_WD = (WD_NEEDED & {4{CTOMB_LOAD}} | CSH.WD_WR) &
                        (MBOX.CSH_WD_VAL | {4{MBX.CHAN_WR_CYC}} | CSH.WD_WR);
  // CORE_BUSY is  MBX3 CORE BUSY 1A L here
  assign MB_WR_RQ_CLR = MBOX.MB_SEL_HOLD & CORE_BUSY |
                        MBOX.CHAN_READ |
                        MBOX.MB_SEL_HOLD & MBC.MEM_START |
                        MBOX.MB_SEL_HOLD & ~CSH.E_CACHE_WR_CYC & ~PMA.CSH_WRITEBACK_CYC;
  assign MB_SEL_HOLD_FF_IN = ~MB_WR_RQ_CLR_FF & (MB_WR_RQ_ANY | MBOX.MB_SEL_HOLD);
  assign MBOX.MB_SEL_2_EN = (CCL.CH_MB_SEL[2] | ~CHAN_READ) &
                            (MB_WR_RQ_P2 | CHAN_READ);
  assign MBOX.MB_SEL_1_EN = (CCL.CH_MB_SEL[1] | ~CHAN_READ) &
                            (MB_WR_RQ_P1 | CHAN_READ);
  assign MBOX.MB_SEL_HOLD = (~MBOX.ACKN_PULSE | MBOX.MEM_RD_RQ) &
                            MB_SEL_HOLD_FF &
                            (~SBUS_DIAG_2 & ~RESET) &
                            // -MBX3 CORE BUSY 1A H on MBX2 A3.
                            (MBOX.MEM_RD_RQ | ~CORE_DATA_VALID | ~CORE_BUSY);
  assign CHAN_READ = MBOX.CHAN_READ;
  // MBX2 MB SEL 2{A,B} and MBX2 MB SEL 1{A,B} use MBOX.MB_SEL[0:1] respectively.

  bit e41Ignored, e4Ignored;
  priority_encoder8 e41(.d({CTOMB_WD_RQ, 4'b0000}),
                        .any(),
                        .q({e41Ignored, MBX.CACHE_TO_MB}));

  priority_encoder8  e4(.d({MB_WR_RQ, 4'b0000}),
                        .any(MB_WR_RQ_ANY),
                        .q({e4Ignored, MB_WR_RQ_P2, MB_WR_RQ_P1}));

  priority_encoder8 e33(.d({MBX.RQ_IN, 4'b0000}),
                        .any(),
                        .q(e33Q));
  
  bit [4:7] ignoredE18;
  decoder e18(.sel({1'b0, MBC.CORE_ADR[34:35]}),
              // -MBX3 CORE BUSY 1A L on MBX2 B4.
              .en(~CORE_BUSY & (MBC.CORE_DATA_VALminus2 | CSH.ONE_WORD_WR_T0)),
              .q({CORE_WD_COMING[0:3], ignoredE18}));
  
  // E12
  always_ff @(posedge clk) if (~MBOX.MB_SEL_HOLD) begin
    MBOX.MB_SEL[2] <= MBOX.MB_SEL_2_EN;
    MBOX.MB_SEL[1] <= MBOX.MB_SEL_1_EN;
  end

  bit [0:3] wd;
  assign wd = CORE_WD_COMING | CSH_TO_MB_WD | MB_WR_RQ;
  USR4  e9(.S0(1'b0),
           .D({wd[0] & ( MBOX.MB_SEL[2] |  MBOX.MB_SEL[1] | ~MB_WR_RQ_CLR),
               wd[1] & ( MBOX.MB_SEL[2] | ~MBOX.MB_SEL[1] | ~MB_WR_RQ_CLR),
               wd[2] & (~MBOX.MB_SEL[2] |  MBOX.MB_SEL[1] | ~MB_WR_RQ_CLR),
               wd[3] & (~MBOX.MB_SEL[2] | ~MBOX.MB_SEL[1] | ~MB_WR_RQ_CLR)}),
              .S3(1'b0),
              .SEL({1'b0, RESET}),
              .Q(MB_WR_RQ),
              .CLK(clk));
               

  always_ff @(posedge clk) ANY_VAL_HOLD <= CSH.ANY_VAL_HOLD_IN;
  always_ff @(posedge clk) MB_WR_RQ_CLR_FF <= CSH.MB_WR_RQ_CLR_NXT;
  always_ff @(posedge clk) MBOX.MB_REQ_HOLD <= MB_WR_RQ_ANY | MB_SEL_HOLD_FF_IN;
  always_ff @(posedge clk) MBX.MB_SEL_HOLD_FF <= MB_SEL_HOLD_FF_IN;
  

  // MBX3 p.180
  //
  // MB_IN_SEL[0:2] maps to MBOX global signals
  // [0]: <CF1> MB IN SEL 4 L
  // [1]: <CH2> MB IN SEL 2 L
  // [2]: <EK2> MB IN SEL 1 L
  bit [0:3] e22_e21_e26_e31in;
  assign e22_e21_e26_e31in = {MBOX.MB_PAR_BIT_IN,
                              CSH_TO_MB_WD[0],
                              ~MB_IN_SEL[0] & ~MB_IN_SEL[2],
                              ~MB_IN_SEL[0] & ~MB_IN_SEL[2] |
                              ~MB_IN_SEL[0] & ~MB_IN_SEL[2] & ~MB_IN_SEL[1]};
  USR4 e22(.S0(1'b0),
           .D(e22_e21_e26_e31in),
           .S3(1'b0),
           .SEL({2{MBOX.MB0_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB0_PAR, CTOMB_WD_RQ[0], MB0_DATA_CODE_2, MB0_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e21(.S0(1'b0),
           .D(e22_e21_e26_e31in),
           .S3(1'b0),
           .SEL({2{MBOX.MB1_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB1_PAR, CTOMB_WD_RQ[1], MB1_DATA_CODE_2, MB1_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e26(.S0(1'b0),
           .D(e22_e21_e26_e31in),
           .S3(1'b0),
           .SEL({2{MBOX.MB2_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB2_PAR, CTOMB_WD_RQ[2], MB2_DATA_CODE_2, MB2_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e31(.S0(1'b0),
           .D(e22_e21_e26_e31in),
           .S3(1'b0),
           .SEL({2{MBOX.MB3_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB3_PAR, CTOMB_WD_RQ[3], MB3_DATA_CODE_2, MB3_DATA_CODE_1}),
           .CLK(clk));
           
  bit e70q14;
  always_comb begin
    case (MBOX.MB_SEL)
    2'b00: MBOX.MB_PAR = MB0_PAR;
    2'b01: MBOX.MB_PAR = MB1_PAR;
    2'b10: MBOX.MB_PAR = MB2_PAR;
    2'b11: MBOX.MB_PAR = MB3_PAR;
    endcase

    case (MBOX.MB_SEL)
    2'b00: MBOX.MB_DATA_CODE_2 = MB0_DATA_CODE_2;
    2'b01: MBOX.MB_DATA_CODE_2 = MB1_DATA_CODE_2;
    2'b10: MBOX.MB_DATA_CODE_2 = MB2_DATA_CODE_2;
    2'b11: MBOX.MB_DATA_CODE_2 = MB3_DATA_CODE_2;
    endcase

    case (MBOX.MB_SEL)
    2'b00: MBOX.MB_DATA_CODE_1 = MB0_DATA_CODE_1;
    2'b01: MBOX.MB_DATA_CODE_1 = MB1_DATA_CODE_1;
    2'b10: MBOX.MB_DATA_CODE_1 = MB2_DATA_CODE_1;
    2'b11: MBOX.MB_DATA_CODE_1 = MB3_DATA_CODE_1;
    endcase
  end

  assign MBX.REFILL_HOLD = CCA_HOLD_ADR | PMA.CSH_WRITEBACK_CYC | MB_REQ_ALLOW;
  assign MB_REQ_ALLOW = CSH.E_CORE_RD_RQ & ~CSH.ONE_WORD_RD |
                        (MBOX.MB_REQ_HOLD | MBOX.CORE_RD_IN_PROG) & ~RESET & MB_REQ_ALLOW_FF;
    // MBC.CORE_BUSY is <EA1> CORE BUSY A H on MBX3 B7 (p.180).
    // We drive MBX3 CORE BUSY 1A L and MBX3 CORE BUSY 1A H from that and call it CORE_BUSY here.
  assign CORE_BUSY = MBC.CORE_BUSY;
  assign EBOX_DIAG_CYC = PMA.CSH_EBOX_CYC & APR.EBOX_SBUS_DIAG;
  assign MBOX.MEM_DATA_TO_MEM = MBC.MEM_START & ~MBOX.MEM_RD_RQ |
                                SBUS_DIAG_0 & ~SBUS_DIAG_2 |
                                // MBX3 CORE BUSY 1A H on MBX3 A7.
                                CORE_BUSY;
  assign e70q14 = MBX.CACHE_TO_MB_DONE & EBOX_DIAG_CYC |
                  ~DIAG_CYC_DONE & SBUS_DIAG_CYC & ~RESET;
  assign MBOX.MEM_DIAG = SBUS_DIAG_0 & ~SBUS_DIAG_1;
  assign DIAG_CYC_DONE = SBUS_DIAG_3 & MBC.A_CHANGE_COMING;

  // e48
  bit [0:3] e48SR;
  always_ff @(posedge CTL.DIAG_LOAD_FUNC_071) e48SR[0:3] <= EBUS.data[30:33];
  assign MBOX.MEM_TO_C_SEL[0] = ~e48SR[0] & ~e48SR[2] |  (E_CORE_RD_RQ | EBOX_DIAG_CYC) & ~e48SR[3];
  assign MBOX.MEM_TO_C_SEL[1] = ~e48SR[1] & ~e48SR[2] | ~(E_CORE_RD_RQ | EBOX_DIAG_CYC) & ~e48SR[3] &
                                ~CSH.E_CACHE_WR_CYC;

  assign MBX.SBUS_DIAG_3 = SBUS_DIAG_3;

  always_ff @(posedge clk) MB_REQ_ALLOW_FF <= MB_REQ_ALLOW;
  always_ff @(posedge clk) SBUS_DIAG_CYC <= e70q14;

  USR4 e67(.S0(1'b0),
           .D(4'b0000),
           .S3(1'b0),
           .SEL({~MBC.A_CHANGE_COMING & e70q14, e70q14}),
           .CLK(clk),
           .Q({SBUS_DIAG_0, SBUS_DIAG_1, SBUS_DIAG_2, SBUS_DIAG_3}));

  
  // MBX4 p.181
  assign clk = CLK.MBX;
  assign MBOX.CSH_WR_WR_EN[0] = ~CSH_CHAN_CYC & ~MBC.CSH_WR_WR_DATA & ~MBOX.MB_SEL[2] & ~MBOX.MB_SEL[1] |
                                CSH_CHAN_CYC & WD_NEEDED[0] | MBC.CSH_WR_WR_DATA & ~PMA.PA[34] & ~PMA.PA[35];
  assign MBOX.CSH_WR_WR_EN[1] = ~CSH_CHAN_CYC & ~MBC.CSH_WR_WR_DATA & ~MBOX.MB_SEL[2] &  MBOX.MB_SEL[1] |
                                CSH_CHAN_CYC & WD_NEEDED[1] | MBC.CSH_WR_WR_DATA & ~PMA.PA[34] &  PMA.PA[35];
  assign MBOX.CSH_WR_WR_EN[2] = ~CSH_CHAN_CYC & ~MBC.CSH_WR_WR_DATA &  MBOX.MB_SEL[2] & ~MBOX.MB_SEL[1] |
                                CSH_CHAN_CYC & WD_NEEDED[2] | MBC.CSH_WR_WR_DATA &  PMA.PA[34] & ~PMA.PA[35];
  assign MBOX.CSH_WR_WR_EN[3] = ~CSH_CHAN_CYC & ~MBC.CSH_WR_WR_DATA &  MBOX.MB_SEL[2] &  MBOX.MB_SEL[1] |
                                CSH_CHAN_CYC & WD_NEEDED[3] | MBC.CSH_WR_WR_DATA &  PMA.PA[34] &  PMA.PA[35];
  assign WD_NEEDED = CCW.WD_REQ | {4{~CSH.CHAN_CYC}};
  assign E_CORE_RD_RQ = CSH.E_CORE_RD_RQ;
  assign CSH_CHAN_CYC = CSH.CHAN_CYC;
  assign MBOX.CSH_CHAN_CYC = CSH.CHAN_CYC; // Should this be assigned in another module?
  assign MBX.WRITEBACK_T2 = MBOX.CSH_WR_OUT_EN;
  assign MBX.CACHE_TO_MB_DONE = CACHE_TO_MB_T1 & ~CACHE_TO_MB_CONT;

  always_ff @(posedge clk) MBOX.CSH_WR_OUT_EN <= CSH.WRITEBACK_T1;
  always_ff @(posedge clk) CACHE_TO_MB_T1 <= MBOX.CSH_WR_OUT_EN | MBOX.CACHE_TO_MB_T4;
  always_ff @(posedge clk) MBX.CACHE_TO_MB_T2 <= CACHE_TO_MB_T1 & ~CACHE_TO_MB_DONE & ~RESET |
                                                 CTOMB_LOAD & ~MBX.CHAN_WR_CYC |
                                                 MBOX.PHASE_CHANGE_COMING & MBX.CACHE_TO_MB_T2 |
                                                 CSH.ONE_WORD_WR_T0;
  always_ff @(posedge clk) CACHE_TO_MB_T3 <= MBX.CACHE_TO_MB_T2 & MBOX.PHASE_CHANGE_COMING;
  always_ff @(posedge clk) MBOX.CACHE_TO_MB_T4 <= CACHE_TO_MB_T3;


  // MBX5 p.182
  bit e71q13, e75q15;
  assign ONE_WORD_RD = CSH.ONE_WORD_RD;
  assign RD_NON_VAL_WDS = E_CORE_RD_RQ & ~ONE_WORD_RD |
                          CSH.PGRF_CYC |
                          MBOX.CSH_CHAN_CYC & ~MBX.CHAN_WR_CYC;
  assign WR_WDS_IN_MB = CSH.E_CACHE_WR_CYC | MBX.CHAN_WR_CYC | PMA.CSH_WRITEBACK_CYC;

  assign MBX.RQ_IN[0] = ~PMA.PA[34] & ~PMA.PA[35] & ONE_WORD_RD | WR_WDS_IN_MB & MB_WR_RQ[0] |
                        ~CSH_WD_VAL[0] & WD_NEEDED[0] & RD_NON_VAL_WDS;
  assign MBX.RQ_IN[1] = ~PMA.PA[34] &  PMA.PA[35] & ONE_WORD_RD | WR_WDS_IN_MB & MB_WR_RQ[1] |
                        ~CSH_WD_VAL[1] & WD_NEEDED[1] & RD_NON_VAL_WDS;
  assign MBX.RQ_IN[2] =  PMA.PA[34] & ~PMA.PA[35] & ONE_WORD_RD | WR_WDS_IN_MB & MB_WR_RQ[2] |
                         ~CSH_WD_VAL[2] & WD_NEEDED[2] & RD_NON_VAL_WDS;
  assign MBX.RQ_IN[3] =  PMA.PA[34] &  PMA.PA[35] & ONE_WORD_RD | WR_WDS_IN_MB & MB_WR_RQ[3] |
                         ~CSH_WD_VAL[3] & WD_NEEDED[3] & RD_NON_VAL_WDS;
  assign C_DIR_PAR_ERR = APR.C_DIR_P_ERR | e75q15;

  assign MBX.MEM_RD_RQ_IN = E_CORE_RD_RQ | ONE_WORD_RD | RD_NON_VAL_WDS;
  assign MBX.MEM_WR_RQ_IN = MBOX.CACHE_TO_MB_T4 | MBX.CHAN_WR_CYC | ONE_WORD_RD & MCL.VMA_PAUSE;
  assign MBX.MB_REQ_IN = MBOX.MB_REQ_HOLD & ~CSH.MB_CYC & MB_REQ_ALLOW & ~MBC.INH_1ST_MB_REQ;
  assign MBX.MEM_TO_C_EN = CSH.MB_CYC | MBOX.MEM_TO_C_DIAG_EN;

  // This was labeled <ES1> CON CACHE LOOK EN L which according to my
  // naming convention is supposed to be MBOX.CON_CACHE_LOOK_EN.
  // Because "CON" has no page number associated it would normally be
  // one of the global MBOX variables the MBOX modules use rather than
  // a CON interface export. But CON already exports it so I'm
  // unclenching and dismissing it without prejudice.
  always_ff @(posedge clk) e71q13 <= CON.CACHE_LOOK_EN & ~CSH_CCA_CYC & CSH.ADR_READY & MBOX.CSH_ADR_PAR_BAD |
                                     CSH.WRITEBACK_T1 & MBOX.CSH_ADR_PAR_BAD |
                                     ~READY_TO_GO & ~RESET & e71q13;
  always_ff @(posedge clk) e75q15 <= e71q13 & READY_TO_GO |
                                     ~APR.C_DIR_P_ERR & MBX.CSH_ADR_PAR_ERR & ~RESET;


  // MBX6 p.183
  bit e61q14, e32Q, e46Q, e56Q;
  assign DIAG = CTL.DIAG[4:6];
  assign DIAG_EN = CTL.DIAG_READ_FUNC_17x;
  assign MBX.EBUSdriver.driving = DIAG_EN;

  mux e43(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.CACHE_BIT,
              MBX.CACHE_TO_MB[34],
              MBX.CACHE_TO_MB[35],
              CACHE_TO_MB_DONE,
              ~MBX.CACHE_TO_MB_T2,
              ~CACHE_TO_MB_T3,
              ~MBOX.CACHE_TO_MB_T4,
              MBX.CCA_ALL_PAGES_CYC}),
          .q(MBX.EBUSdriver.data[30]));

  mux e38(.en(DIAG_EN),
          .sel(DIAG),
          .d({~MBX.CCA_REQ,
              MBX.CCA_SEL[1],
              MBX.CCA_SEL[2],
              ~MBX.CHAN_WR_CYC,
              MBX.CSH_CCA_INVAL_CSH,
              MBX.CSH_CCA_VAL_CORE,
              MBOX.CSH_WR_WD_EN[0],
              MBOX.CSH_WR_WD_EN[1]}),
          .q(MBX.EBUSdriver.data[31]));

  mux e11(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBOX.CSH_WR_WD_EN[2],
              MBOX.CSH_WR_WD_EN[3],
              MBOX.FORCE_NO_MATCH,
              MBOX.MEM_DATA_TO_MEM,
              MBOX.MB_DATA_CODE_1,
              MBOX.MB_DATA_CODE_2,
              MBOX.MB_PAR,
              MBOX.MB_REQ_HOLD}),
          .q(MBX.EBUSdriver.data[32]));

  mux e35(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.MB_REQ_IN,
              MBOX.MB_SEL[1],
              MBOX.MB_SEL[2],
              MBOX.MB_SEL_HOLD,
              MBOX.MB0_HOLD_IN,
              MBOX.MB1_HOLD_IN,
              MBOX.MB2_HOLD_IN,
              MBOX.MB3_HOLD_IN}),
          .q(MBX.EBUSdriver.data[33]));

  mux e30(.en(DIAG_EN),
          .sel(DIAG),
          .d({~MBX.MEM_TO_C_EN,
              ~MBOX.MEM_DIAG,
              MBX.MEM_RD_RQ_IN,
              MBOX.MEM_TO_C_SEL[1],
              MBOX.MEM_TO_C_SEL[0],
              MBX.MEM_WR_RQ_IN,
              MBX.REFILL_HOLD,
              MBX.RQ_IN[0]}),
          .q(MBX.EBUSdriver.data[34]));

  mux e16(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.RQ_IN[1:3],
              MBOX.SBUS_ADR[34:35],
              ~MBX.SBUS_DIAG_3,
              ~SBUS_DIAG_CYC,
              ~MBX.WRITEBACK_T2}),
          .q(MBX.EBUSdriver.data[35]));

  always_ff @(posedge clk) CORE_DATA_VALIDminus1 <= MBC.CORE_DATA_VALminus2;
  always_ff @(posedge clk) CORE_DATA_VALID <= CORE_DATA_VALIDminus1;
  always_ff @(posedge clk) e61q14 <= e56Q;

  mux e32(.en(1'b1),
          .sel(MBOX.MB_IN_SEL),
          .d({MBX.CACHE_TO_MB[34],
              1'b0,
              PMA.PA[34],
              CCL.CH_MB_SEL[2],
             MBC.CORE_ADR[34],
              1'b0,
              CCL.CH_MB_SEL[2],
              1'b0}),
          .q(e32Q));

  mux e46(.en(1'b1),
          .sel(MBOX.MB_IN_SEL),
          .d({MBX.CACHE_TO_MB[35],
              1'b0,
              PMA.PA[35],
              CCL.CH_MB_SEL[1],
             MBC.CORE_ADR[35],
              1'b0,
              CCL.CH_MB_SEL[1],
              1'b0}),
          .q(e46Q));

  mux e56(.en(1'b1),
          .sel(MBOX.MB_IN_SEL),
          .d({~CACHE_TO_MB_T3,
              1'b0,
              ~CSH.ONE_WORD_WR_T0,
              ~CCL.CH_LOAD_MB,
              ~CORE_DATA_VALIDminus1,
              1'b0,
              ~CCL.CH_LOAD_MB,
              1'b0}),
          .q(e56Q));

  ////////////////////////////////////////////////////////////////
  // MB_IN_SEL
  //  4  2  1   MB SOURCE      CYCLE TYPE
  //  0  0  0   cache data     cache writeback, CCA WB, page refill, chan mem read
  //  0  1  0       AR         EBOX write, SBUS diag
  //  0  1  1   CHAN DATA BUF  channel data to memory
  //  1  0  0   mem data       memory read
  //  1  1  0   CCW mixer      channel store status
  ////////////////////////////////////////////////////////////////

  bit [4:7] e36Ignored;
  decoder e36(.en(~(~CACHE_TO_MB_CONT & MBOX.CSH_CHAN_CYC) & ~e61q14),
              .sel({1'b0, e32Q, e56Q}),
              .q({MBOX.MB0_HOLD_IN,
                  MBOX.MB1_HOLD_IN,
                  MBOX.MB2_HOLD_IN,
                  MBOX.MB3_HOLD_IN,
                  e36Ignored}));
endmodule
