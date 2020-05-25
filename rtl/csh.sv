// 04-25-2020: Manually compared with schematics (and found a few problems).
`timescale 1ns/1ns
`include "ebox.svh"

module csh(iAPR APR,
           iCCL CCL,
           iCLK CLK,
           iCON CON,
           iCSH CSH,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iMBC MBC,
           iMBX MBX,
           iMBOX MBOX,
           iMCL MCL,
           iMTR MTR,
           iPAG PAG,
           iPI PIC,
           iPMA PMA,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA
           );

  bit clk;
  bit MB_REQ, CHAN_REQ_EN, CYC_TYPE_HOLD, WRITEBACK_T2;
  bit EBOX_REQ_EN, NON_EBOX_REQ_GRANT;
  bit CACHE_IDLE_IN_A, CACHE_IDLE_IN_B, CACHE_IDLE_IN_C, CACHE_IDLE_IN_D, CACHE_IDLE_IN;
  bit EBOX_T0, EBOX_T1, EBOX_T2, PGRF_CYC, RESET, DATA_DLY_1, DATA_DLY_2;
  bit MBOX_RESP, EBOX_RESTART, SBUS_DIAG_3;
  bit EBOX_MAP, MAP_PROBLEM, PAGE_FAIL_T2;
  bit MB_TEST_PAR_A_IN, LRU_ANY_WR;
  bit PAGE_REFILL_T4_IN, PAGE_REFILL_T4, PAGE_REFILL_T9comma12;
  bit PAGE_REFILL_T10, PAGE_REFILL_T11, PAGE_REFILL_T13;
  bit EBOX_REFILL_OK, PAGE_REFILL_COMP, PAGE_REFILL_T7;
  bit CSH_T0, T1, T2_IN, T3;
  bit CCA_T3, WR_TEST, RD_PSE_2ND_REQ_EN;
  bit e52q3, e52q13, e52q14, e52q15;
  bit MB_REQ_GRANT, CACHE_IDLE, EBOX_PAUSE_WRITE, E_CORE_RD_T3;
  bit E_T2_MEM_REF, CCA_CYC_DONE, CHAN_WR_T5, EBOX_RETRY_NEXT;
  bit E_RD_T2_OK, WRITEBACK_T1, EBOX_SYNC_HOLD, E_CORE_RD_COMP;
  bit EBOX_READ, E_REQ_EN_CLR, EBOX_RETRY_NEXT_IN;
  bit E_WR_T2, ANY_VALID_MATCH, CACHE_WR_FROM_MEM, RD_FOUND;
  bit E_WRITEBACK, EBOX_WR_T3, E_RD_T2_CORE_OK, RD_PAUSE_2ND_HALF;
  bit EBOX_PAUSE, MB_CYC, KI10_PAGING_MODE;
  bit ANY_WRITTEN_MATCH;
  bit EBOX_TOOK_1_WD, WR_DATA_RDY;
  bit PAGE_FAIL_DLY, EBOX_WR_T4, PAGE_FAIL_T3;
  bit EBOX_WR_T4_IN, PAGE_FAIL_HOLD_FF, EBOX_CYC;
  bit DATA_CLR_T4;
  bit EBOX_SYNC_SEEN, DATA_DLY1, CACHE_WR_IN, WRITE_OK, CCA_INVAL_T4;

  // CSH1 p.24
  assign clk = CLK.CSH;
  assign CSH.MB_REQ_GRANT = MB_REQ;
  assign CSH.CHAN_REQ_GRANT = ~MB_REQ & CCL.CHAN_REQ & CHAN_REQ_EN;
  assign CSH.EBOX_REQ_GRANT = ~MB_REQ & CLK.EBOX_REQ & EBOX_REQ_EN & ~CCL.CHAN_REQ;
  assign CYC_TYPE_HOLD = ~CSH.READY_TO_GO & ~WRITEBACK_T2;

  assign CSH.EBOX_ERA_GRANT = APR.EBOX_ERA & ~CCL.CHAN_REQ & CLK.EBOX_REQ & EBOX_REQ_EN & ~MB_REQ;
  assign CSH.EBOX_CCA_GRANT = APR.EBOX_CCA & ~CCL.CHAN_REQ & CLK.EBOX_REQ & EBOX_REQ_EN & ~MB_REQ;
  assign CSH.CCA_REQ_GRANT = MBX.CCA_REQ & ~CCL.CHAN_REQ & CSH.CCA_REQ_EN & ~CLK.EBOX_REQ & ~MB_REQ;
  assign NON_EBOX_REQ_GRANT = PAGE_REFILL_T4 | MB_REQ_GRANT | CSH.CHAN_REQ_GRANT | CSH.CCA_REQ_GRANT;

  assign CACHE_IDLE_IN_A = PMA.CSH_WRITEBACK_CYC & MBX.CACHE_TO_MB_DONE |
                           ~CSH.READY_TO_GO & CACHE_IDLE |
                           CSH.E_CACHE_WR_CYC & MBOX.CACHE_TO_MB_T4 |
                           CSH.CHAN_RD_T5 & MBOX.PHASE_CHANGE_COMING;

  assign CACHE_IDLE_IN_B = EBOX_PAUSE_WRITE & E_T2_MEM_REF & PAG.PAGE_OK |
                           CCA_CYC_DONE | EBOX_WR_T4 |
                           EBOX_T0 & APR.EBOX_LOAD_REG |
                           CACHE_IDLE_IN_C;

  // NOTE: Wire OR
  assign CACHE_IDLE_IN_D = VMA.AC_REF & EBOX_T0 | EBOX_T1 & CLK.EBOX_CYC_ABORT;

  // NOTE: Wire OR
  assign CACHE_IDLE_IN = e52q3 | e52q14 | e52q15;
  assign CACHE_IDLE = CACHE_IDLE_IN;

  assign PGRF_CYC = PMA.PAGE_REFILL_CYC;
  assign CSH.EBOX_CYC = EBOX_CYC;

  assign CSH.READY_TO_GO = e52q13 & PAGE_REFILL_T10 |
                           CLK.EBOX_SYNC & CACHE_IDLE |
                           (~EBOX_CYC | PAGE_REFILL_T4 | RESET) & CACHE_IDLE |
                           ~MCL.VMA_PAUSE & MBOX_RESP & CSH.ONE_WORD_RD;

  assign RESET = CLK.MR_RESET;

  always_ff @(posedge clk) e52q3 <= CACHE_IDLE_IN_D;
  always_ff @(posedge clk) e52q13 <= ~MBOX.MEM_BUSY;
  always_ff @(posedge clk) e52q14 <= CACHE_IDLE_IN_A | CHAN_WR_T5 | CACHE_WR_FROM_MEM |
                                     RESET | CACHE_IDLE_IN_B | EBOX_RETRY_NEXT;
  always_ff @(posedge clk) e52q15 <= CSH.READY_TO_GO & ~CSH.EBOX_REQ_GRANT & ~NON_EBOX_REQ_GRANT |
                                     E_RD_T2_OK & RD_FOUND |
                                     MBOX.A_CHANGE_COMING_IN & MBX.SBUS_DIAG_3 |
                                     CSH.CHAN_T3 & ~ANY_VALID_MATCH & CCL.CHAN_TO_MEM;

  always_ff @(posedge clk) CHAN_REQ_EN <= ~WRITEBACK_T1 & ~PAGE_REFILL_T4_IN & ~MBOX.MEM_BUSY;
  always_ff @(posedge clk) MB_REQ <= MBX.MB_REQ_IN;

  // MBOX.CORE_BUSY here is <EC1> -CORE BUSY L CSH1 A8 p.24.
  always_ff @(posedge clk) CSH.CCA_REQ_EN <= ~WRITEBACK_T1 & ~PAGE_REFILL_T4_IN & ~MBOX.CORE_BUSY;

  // Note active low symbol
  USR4 e72(.S0(1'b0),
           .D({CSH.EBOX_REQ_GRANT, CSH.MB_REQ_GRANT,
               CSH.CHAN_REQ_GRANT, CSH.CCA_REQ_GRANT}),
           .S3(1'b0),
           .Q({EBOX_CYC, CSH.MB_CYC, CSH.CHAN_CYC, CSH.CCA_CYC}),
           .SEL({2{CYC_TYPE_HOLD}}),
           .CLK(clk));


  // CSH2 p.25
  bit e23out2;
  assign e23out2 = CSH.E_CACHE_WR_CYC & MBOX.CACHE_TO_MB_T4 |
                   ~EBOX_SYNC_HOLD & DATA_DLY_1 |
                   MBC.CORE_DATA_VALminus1 & CSH.E_CORE_RD_RQ |
                   ~E_CORE_RD_COMP & MBOX_RESP & ~EBOX_RESTART;

  assign CSH.MBOX_RESP_IN = E_RD_T2_OK & RD_FOUND |
                            MBOX.A_CHANGE_COMING_IN & SBUS_DIAG_3 |
                            ~RESET & e23out2 |
                            CACHE_IDLE_IN & CSH.EBOX_CYC;

  assign EBOX_RESTART = MBOX_RESP & CLK.EBOX_SYNC;
  assign SBUS_DIAG_3 = MBX.SBUS_DIAG_3;

  assign CSH.E_CACHE_WR_CYC = MCL.VMA_WRITE & CSH.EBOX_CYC & ~EBOX_READ;
  assign CSH.EBOX_RETRY_REQ = CSH.EBOX_CYC & WRITEBACK_T1 |
                              EBOX_RETRY_NEXT & ~RESET;

  assign E_REQ_EN_CLR = WRITEBACK_T1 | E_WRITEBACK & MCL.VMA_READ & PMA.CSH_WRITEBACK_CYC;
  assign EBOX_RETRY_NEXT_IN = (~MBX.CACHE_BIT | LRU_ANY_WR) &
                              // <Fv2> CORE BUSY L CSH2 C4.
                              E_WR_T2 & PAG.PAGE_OK & MBOX.CORE_BUSY & ~ANY_VALID_MATCH |
                              (CSH.ADR_READY &
                               // <Fv2> CORE BUSY L CSH2 C4.
                               (MBOX.CORE_BUSY & APR.EBOX_SBUS_DIAG |
                                EBOX_REFILL_OK & PAG.PAGE_REFILL & ~RESET) &
                               EBOX_CYC) |
                              ~MBC.WRITE_OK & WR_TEST & EBOX_CYC |
                              ~RD_FOUND & E_RD_T2_OK & MBOX.CORE_BUSY; // <FV2> CORE BUSY L CSH2 B3.
  assign WR_TEST = CSH.CLEAR_WR_T0 | EBOX_WR_T3;

  always_ff @(posedge clk) MBOX_RESP <= CSH.MBOX_RESP_IN;

  always_ff @(posedge clk) CSH.ONE_WORD_RD <= E_RD_T2_CORE_OK & ~ANY_VALID_MATCH & ~MBX.CACHE_BIT |
                                              CSH.ONE_WORD_RD & ~EBOX_RESTART & ~CSH.READY_TO_GO;
  always_ff @(posedge clk) RD_PAUSE_2ND_HALF <= CSH.ONE_WORD_RD & EBOX_RESTART & EBOX_PAUSE |
                                                RD_PAUSE_2ND_HALF & ~CSH.READY_TO_GO;
  always_ff @(posedge clk) RD_PSE_2ND_REQ_EN <= DATA_DLY_2 & RD_PAUSE_2ND_HALF |
                                                RD_PSE_2ND_REQ_EN & ~CLK.EBOX_REQ & ~RESET;

  always_ff @(posedge clk) CSH.E_CORE_RD_RQ <= E_RD_T2_CORE_OK &  ANY_VALID_MATCH & ~RD_FOUND |
                                               E_RD_T2_CORE_OK & ~ANY_VALID_MATCH & ~LRU_ANY_WR |
                                               E_RD_T2_CORE_OK & ~ANY_VALID_MATCH & ~MBX.CACHE_BIT |
                                               ~MBC.CORE_DATA_VALID & ~RESET & CSH.E_CORE_RD_RQ;

  always_ff @(posedge clk) EBOX_RETRY_NEXT <= EBOX_RETRY_NEXT_IN;
  // <EC1> -CORE BUSY L on CSH2 A3.
  always_ff @(posedge clk) EBOX_REQ_EN <= ~MBOX.CORE_BUSY & ~E_REQ_EN_CLR & ~PAGE_REFILL_T4_IN |
                                          MB_CYC & MCL.VMA_READ |
                                          RESET |
                                          ~E_REQ_EN_CLR & EBOX_REQ_EN & ~EBOX_RETRY_NEXT;


  // CSH3 p.26
  assign MBOX.LOAD_EBUS_REG = CTL.DIAG_LD_EBUS_REG | PAGE_FAIL_T2 |
                              APR.EBOX_READ_REG & CSH.EBOX_T3 & ~MAP_PROBLEM;
  assign CACHE_IDLE_IN_C = APR.EBOX_READ_REG & CSH.EBOX_T3 & ~MAP_PROBLEM | PAGE_FAIL_T3;
  assign EBOX_MAP = MCL.EBOX_MAP;
  assign MAP_PROBLEM = MCL.EBOX_MAP &
                       (PAG.PAGE_REFILL | ~KI10_PAGING_MODE) &
                       ~PAG.PAGE_OK;
  assign CSH.ADR_READY = EBOX_T2 | CSH.T2;
  assign CSH.ANY_VAL_HOLD_IN = CSH.ADR_READY & ANY_VALID_MATCH |
                               ~CSH.READY_TO_GO & CSH.ANY_VAL_HOLD;
  assign ANY_WRITTEN_MATCH = |(CSH.VALID_MATCH & CSH.ANY_WR);
  assign RD_FOUND = |(MBOX.CSH_WD_VAL & CSH.VALID_MATCH);
  assign ANY_VALID_MATCH = |(CSH.VALID_MATCH);
  assign MB_TEST_PAR_A_IN = DATA_DLY_2 | CSH.PAGE_REFILL_T12 | CACHE_WR_FROM_MEM;
  assign CSH.MATCH_HOLD_IN[0] = (~ANY_VALID_MATCH | CSH.VALID_MATCH[3] | CSH.VALID_MATCH[2]) &
                                (CSH.VALID_MATCH[2] | CSH.LRU_2 | CSH.VALID_MATCH[3]);
  assign CSH.MATCH_HOLD_IN[1] = (~ANY_VALID_MATCH | CSH.VALID_MATCH[3] | CSH.VALID_MATCH[1]) &
                                (CSH.VALID_MATCH[1] | CSH.LRU_1 | CSH.VALID_MATCH[3]);
  assign CSH.MB_WR_RQ_CLR_NXT = PAGE_REFILL_T11 | CSH.WR_FROM_MEM_NXT |
                                EBOX_TOOK_1_WD | MBOX.CHAN_READ;

  always_ff @(posedge clk) CSH.ANY_VAL_HOLD <= CSH.ANY_VAL_HOLD_IN;
  always_ff @(posedge clk) CSH.GATE_VMA_27_33 <= CSH.EBOX_T0_IN | CSH.EBOX_CYC & ~MBX.REFILL_ADR_EN_NXT;
  always_ff @(posedge clk) CSH.ADR_PMA_EN <= ~CSH.EBOX_CYC & ~CSH.EBOX_T0_IN & ~MBX.REFILL_ADR_EN_NXT;

  mux2x4 e26(.EN(1'b1),
             .SEL({CSH.LRU_2, CSH.LRU_1}),
             .D0(CSH.ANY_WR),
             .D1('0),
             .B0(LRU_ANY_WR),
             .B1());


  // CSH4 p.27
  bit e18q4, e18q13;
  assign CSH.EBOX_T0_IN = CSH.READY_TO_GO & CSH.EBOX_REQ_GRANT |
                          CLK.EBOX_REQ & RD_PSE_2ND_REQ_EN;
  assign E_T2_MEM_REF = ~APR.EBOX_SBUS_DIAG & EBOX_T2 & ~APR.EBOX_READ_REG;
  assign E_WR_T2 = ~MCL.VMA_PAUSE & E_T2_MEM_REF & ~EBOX_READ;
  assign E_RD_T2_OK = PAG.PAGE_OK & MCL.VMA_READ & EBOX_T2;
  // MBOX.CORE_BUSY is <EC1> -CORE BUSY L on CSH4 C5 p.27.
  assign E_RD_T2_CORE_OK = E_RD_T2_OK & ~MBOX.CORE_BUSY;
  assign EBOX_READ = MCL.VMA_READ;
  assign EBOX_PAUSE_WRITE = ~EBOX_READ & EBOX_PAUSE;
  assign EBOX_PAUSE = MCL.VMA_PAUSE;
  assign EBOX_WR_T4_IN = EBOX_WR_T3 & ~EBOX_RETRY_NEXT_IN;
  assign CSH.REFILL_RAM_WR = APR.EN_REFILL_RAM_WR & EBOX_T2;

  // NOTE: "Wire AND"
  assign PAGE_FAIL_T2 = e18q13 | e18q4;

  always_ff @(posedge clk) EBOX_T0 <= CSH.EBOX_T0_IN;
  always_ff @(posedge clk) EBOX_T1 <= EBOX_T0 & ~VMA.AC_REF & ~CACHE_IDLE_IN;
  always_ff @(posedge clk) EBOX_T2 <= EBOX_T1 & ~CLK.EBOX_CYC_ABORT;
  always_ff @(posedge clk) CSH.EBOX_T3 <= EBOX_T2;
  // <EC1> -CORE BUSY L on CSH4 B7.
  always_ff @(posedge clk) CSH.ONE_WORD_WR_T0 <= ~MBOX.CORE_BUSY & APR.EBOX_SBUS_DIAG & EBOX_T2 |
                                                 ~MBX.CACHE_BIT & ~ANY_VALID_MATCH &
                                                 // <Ec1> -CORE BUSY L on CSH4 A7.
                                                 PAG.PAGE_OK & ~MBOX.CORE_BUSY &
                                                   ~MCL.VMA_PAUSE & ~EBOX_READ & E_T2_MEM_REF;
  always_ff @(posedge clk) CSH.WRITEBACK_T1 <= ANY_WRITTEN_MATCH & MBX.CSH_CCA_VAL_CORE & CCA_T3 |
                                               // <Ec1> -CORE BUSY L on CSH4 A7.
                                               E_T2_MEM_REF & ~MBOX.CORE_BUSY & ~EBOX_PAUSE_WRITE &
                                                 PAG.PAGE_OK & MBX.CACHE_BIT &
                                                 LRU_ANY_WR & ~ANY_VALID_MATCH;
  always_ff @(posedge clk) WRITEBACK_T2 <= WRITEBACK_T1;

  always_ff @(posedge clk) PAGE_FAIL_DLY <= CSH.PAGE_FAIL_HOLD;
  always_ff @(posedge clk) e18q4 <= PAGE_FAIL_DLY;
  always_ff @(posedge clk) e18q13 <= CSH.PAGE_FAIL_HOLD;
  always_ff @(posedge clk) PAGE_FAIL_T3 <= PAGE_FAIL_T2;

  always_ff @(posedge clk) DATA_CLR_T4 <= MBC.CSH_DATA_CLR_T3;
  always_ff @(posedge clk) EBOX_WR_T3 <= DATA_CLR_T4 & CSH.E_CACHE_WR_CYC |
                                         E_WR_T2 & ANY_VALID_MATCH & PAG.PAGE_OK;
  always_ff @(posedge clk) EBOX_WR_T4 <= EBOX_WR_T4_IN;
  always_ff @(posedge clk) CSH.CLEAR_WR_T0 <= PAG.PAGE_OK & ~ANY_VALID_MATCH &
                                              E_WR_T2 & MBX.CACHE_BIT & ~LRU_ANY_WR;
  always_ff @(posedge clk) CSH.DATA_CLR_DONE <= MBC.DATA_CLR_DONE_IN & ~CSH.READY_TO_GO |
                                                ANY_VALID_MATCH & E_WR_T2 & PAG.PAGE_OK;


  // CSH5 p.28
  bit e68q3, e68q2, e35q2, e35q14;
  always_ff @(posedge clk) CSH.PAGE_REFILL_T9 <= MBX.CACHE_TO_MB_DONE & PMA.PAGE_REFILL_CYC;
  always_ff @(posedge clk) CSH.PAGE_REFILL_T13 <= PAGE_REFILL_T9comma12;
  always_ff @(posedge clk) PAGE_REFILL_T4 <= PAGE_REFILL_T4_IN;
  // <EC1> -CORE BUSY L on CSH5 B8 p.28.
  always_ff @(posedge clk) PAGE_REFILL_COMP <= PAGE_REFILL_T10 & ~MBOX.CORE_BUSY |
                                               PAGE_REFILL_COMP & ~EBOX_RESTART & ~RESET;
  always_ff @(posedge clk) CSH.PAGE_REFILL_T8 <= PAGE_REFILL_T7;
  // <FV2> CORE BUSY L on CSH5 C6.
  always_ff @(posedge clk) PAGE_REFILL_T10 <= MBOX.CORE_BUSY & ~MBX.MB_SEL_HOLD_FF | PAGE_REFILL_T13;
  always_ff @(posedge clk) e35q14 <= PAGE_REFILL_T10;
  always_ff @(posedge clk) e35q2 <= MBOX.MB_SEL_HOLD;
  // Note: "Wire AND"
  always_ff @(posedge clk) PAGE_REFILL_T11 <= e35q14 | e35q2;
  always_ff @(posedge clk) CSH.PAGE_REFILL_T12 <= PAGE_REFILL_T11;
  always_ff @(posedge clk) e68q3 <= NON_EBOX_REQ_GRANT;
  always_ff @(posedge clk) e68q2 <= CSH.READY_TO_GO;
  always_ff @(posedge clk) T1 <= CSH_T0;
  always_ff @(posedge clk) CSH.T2 <= T2_IN;
  always_ff @(posedge clk) T3 <= CSH.T2;
  always_ff @(posedge clk) CHAN_WR_T5 <= CSH.CHAN_WR_T5_IN;
  always_ff @(posedge clk) CSH.CHAN_T4 <= ANY_VALID_MATCH & CSH.CHAN_T3;
  always_ff @(posedge clk) CSH.CHAN_RD_T5 <= CSH.CHAN_T3 & ~CCL.CHAN_TO_MEM & ~ANY_VALID_MATCH |
                                             MBX.CACHE_TO_MB_DONE & CSH.CHAN_CYC |
                                             ~RESET & ~CACHE_IDLE_IN & CSH.CHAN_RD_T5;

  assign PAGE_REFILL_T9comma12 = CSH.PAGE_REFILL_T12 | CSH.PAGE_REFILL_T9;
  // <EC1> -CORE BUSY L on CSH5 C8.
  assign PAGE_REFILL_T4_IN = ~MBOX.CORE_BUSY & CSH.EBOX_T3 & EBOX_REFILL_OK & PAG.PAGE_REFILL;
  assign EBOX_REFILL_OK = (EBOX_MAP | ~APR.EBOX_READ_REG) & ~PAGE_REFILL_COMP;
  assign PAGE_REFILL_T7 = PAG.PAGE_REFILL_CYC & T3;

  // NOTE: "Wire AND"
  assign CSH_T0 = e68q3 | e68q2;

  assign T2_IN = T1 & ~CSH.WR_FROM_MEM_NXT;
  assign CCA_T3 = T3 & CSH.CCA_CYC;
  assign CSH.CHAN_WR_T5_IN = CCL.CHAN_TO_MEM & CSH.CHAN_T4;
  assign CSH.CHAN_T3 = CSH.CHAN_CYC & T3;


  // CSH6 p.29
  always_ff @(posedge clk) EBOX_SYNC_HOLD <= ~EBOX_T0 & ~RESET & EBOX_SYNC_SEEN;
  always_ff @(posedge clk) CACHE_WR_FROM_MEM <= CSH.WR_FROM_MEM_NXT;
  always_ff @(posedge clk) CSH.CHAN_WR_CACHE <= ANY_VALID_MATCH & CCL.CHAN_TO_MEM & CSH.CHAN_T3 |
                                                CSH.CHAN_WR_CACHE & ~CSH.READY_TO_GO;
  always_ff @(posedge clk) PAGE_FAIL_HOLD_FF <= ~CON.KI10_PAGING_MODE & EBOX_T2 & PAG.PAGE_FAIL |
                                                E_T2_MEM_REF & PAG.PAGE_FAIL & ~APR.EBOX_READ_REG |
                                                ~CSH.READY_TO_GO & PAGE_FAIL_HOLD_FF & ~APR.EBOX_READ_REG |
                                                CSH.EBOX_T3 & PAG.PAGE_REFILL & PAGE_REFILL_COMP;
  always_ff @(posedge clk) CSH.PAGE_REFILL_ERROR <= PAGE_REFILL_COMP & PAG.PAGE_REFILL & CSH.EBOX_T3 |
                                                    CSH.PAGE_REFILL_ERROR & ~EBOX_RESTART & ~RESET;
  always_ff @(posedge clk) DATA_DLY_1 <= E_CORE_RD_COMP;
  always_ff @(posedge clk) DATA_DLY_2 <= DATA_DLY1;
  always_ff @(posedge clk) WR_DATA_RDY <= ~CSH.ONE_WORD_RD & E_CORE_RD_COMP |
                                          WR_DATA_RDY & ~CACHE_WR_IN & ~RESET;
  always_ff @(posedge clk) CSH.CCA_INVAL_T4 <= MBX.CSH_CCA_INVAL_CSH &
                                               CCA_T3 &
                                               ANY_VALID_MATCH &
                                               (~ANY_WRITTEN_MATCH | ~MBX.CSH_CCA_VAL_CORE);
  always_ff @(posedge clk) CSH.CCA_CYC_DONE <= CSH.CCA_INVAL_T4 |
                                               ~ANY_VALID_MATCH & CCA_T3 |
                                               ~MBX.CSH_CCA_INVAL_CSH & ~ANY_WRITTEN_MATCH & CCA_T3 |
                                               ~MBX.CSH_CCA_VAL_CORE & ~MBX.CSH_CCA_INVAL_CSH & CCA_T3;
  always_ff @(posedge clk) CSH.USE_HOLD <= (EBOX_T1 | CSH.USE_HOLD | T2_IN) &
                                           ~CSH.READY_TO_GO;
  always_ff @(posedge clk) EBOX_TOOK_1_WD <= EBOX_SYNC_SEEN & CSH.ONE_WORD_RD;

  assign EBOX_SYNC_SEEN = EBOX_SYNC_HOLD | EBOX_RESTART;
  assign CSH.WR_FROM_MEM_NXT = EBOX_SYNC_SEEN & WR_DATA_RDY |
                               T1 & MB_CYC & ~RESET;
  assign CSH.PAGE_FAIL_HOLD = PAGE_FAIL_HOLD_FF;
  assign E_CORE_RD_COMP = CSH.E_CORE_RD_RQ & MBC.CORE_DATA_VALID;
  assign CSH.EBOX_LOAD_REG = APR.EBOX_LOAD_REG & EBOX_T0;
  assign WRITE_OK = MBC.WRITE_OK;
  assign CSH.CACHE_WR_IN = MBC.CSH_DATA_CLR_T1 & CSH.ONE_WORD_RD & CSH.E_CORE_RD_RQ |
                           EBOX_WR_T3 & WRITE_OK |
                           ~RESET & CSH.WR_FROM_MEM_NXT;

  assign KI10_PAGING_MODE = CON.KI10_PAGING_MODE;

  // NOTE: Wire AND
  assign CSH.MBOX_PT_DIR_WR = KI10_PAGING_MODE & (PAGE_FAIL_T3 | CSH.PAGE_REFILL_T12);

  assign CSH.USE_WR_EN = PAG.PAGE_OK & ANY_VALID_MATCH & EBOX_T2 |
                         ~CSH.ONE_WORD_RD & MBC.CSH_DATA_CLR_T2 |
                         MBX.CCA_ALL_PAGES_CYC & CCA_INVAL_T4;


  // CSH7 p.30
  assign CSH.EBUSdriver.driving = CTL.DIAG_READ_FUNC_17x;
  mux e12(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(~CTL.DIAG[4:6]),
          .d({~PAGE_REFILL_COMP, ~CSH.CHAN_RD_T5, ~CSH.CHAN_WR_CACHE, ~CSH.ONE_WORD_RD,
              ~CSH.E_CORE_RD_RQ, ~CSH.EBOX_RETRY_REQ,
              ~CSH.CCA_INVAL_T4, ~CSH.PAGE_REFILL_ERROR}),
          .q(CSH.EBUSdriver.data[22]));

  mux  e7(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(~CTL.DIAG[4:6]),
          .d({CSH.CACHE_WR_IN, ~WR_DATA_RDY, ~CSH.CCA_CYC_DONE, ~MBOX_RESP,
              ~CSH.PAGE_FAIL_HOLD, CSH.USE_WR_EN, ~CSH.PAGE_REFILL_T8, ~DATA_DLY_1}),
          .q(CSH.EBUSdriver.data[23]));

  mux e32(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(~CTL.DIAG[4:6]),
          .d({~CSH.MBOX_PT_DIR_WR, ~PAGE_FAIL_T2, ~CSH.CHAN_T4, ~RD_PSE_2ND_REQ_EN,
              ~PAGE_REFILL_T9comma12, ~MB_TEST_PAR_A_IN, ~EBOX_T0, PAGE_FAIL_DLY}),
          .q(CSH.EBUSdriver.data[24]));

  mux  e2(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(~CTL.DIAG[4:6]),
          .d({~WR_TEST, CSH.EBOX_LOAD_REG, CSH.LRU_2, CSH.LRU_1,
              ~CSH.ANY_WR[3], ~CSH.ANY_WR[1], ~CSH.ANY_WR[2], ~CSH.ANY_WR[0]}),
          .q(CSH.EBUSdriver.data[25]));

  mux e78(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(CTL.DIAG[4:6]),
          .d({CSH.ANY_VAL_HOLD_IN, ~CSH.FILL_CACHE_RD, CSH.READY_TO_GO, ~T1,
              ~CSH_T0, ~T3, ~CSH.T2, ~PAGE_REFILL_T10}),
          .q(CSH.EBUSdriver.data[26]));

  mux e71(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(CTL.DIAG[4:6]),
          .d({~CSH.DATA_CLR_DONE, ~CHAN_WR_T5, CSH.USE_HOLD, WRITEBACK_T1,
              CSH.ADR_PMA_EN, CSH.GATE_VMA_27_33, CSH.E_CACHE_WR_CYC, CYC_TYPE_HOLD}),
          .q(CSH.EBUSdriver.data[27]));

  mux e73(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(CTL.DIAG[4:6]),
          .d({~CSH.REFILL_RAM_WR, ~CSH.MB_WR_RQ_CLR_NXT, ~CSH.CCA_CYC, ~CSH.CCA_WRITEBACK,
              ~EBOX_CYC, ~CSH.MB_CYC, ~CSH.E_WRITEBACK, ~CSH.RD_PAUSE_2ND_HALF}),
          .q(CSH.EBUSdriver.data[28]));

  mux e57(.en(CTL.DIAG_READ_FUNC_17x),
          .sel(CTL.DIAG[4:6]),
          .d({~CSH.EBOX_T3, ~EBOX_T1, ~EBOX_REQ_EN, ~EBOX_T2,
              ~CACHE_IDLE, ~CSH.ONE_WORD_WR_T0, ~CSH.PAGE_REFILL_T4, ~EBOX_WR_T4}),
          .q(CSH.EBUSdriver.data[29]));

  assign E_CORE_RD_T3 = ~EBOX_READ & CSH.EBOX_T3 |
                        CSH.EBOX_T3 & CSH.E_CORE_RD_RQ & ~RESET;

  always_ff @(posedge clk) CSH.FILL_CACHE_RD <= E_CORE_RD_T3 & CSH.E_CORE_RD_RQ |
                                                CSH.FILL_CACHE_RD & ~EBOX_RESTART & ~RESET;
  always_ff @(posedge clk) CSH.CCA_WRITEBACK <= WRITEBACK_T1 & CSH.CCA_CYC |
                                                ~CACHE_IDLE & CSH.CCA_WRITEBACK;
  always_ff @(posedge clk) CSH.E_WRITEBACK <= WRITEBACK_T1 & CSH.EBOX_CYC |
                                              ~E_CORE_RD_T3 & CSH.E_WRITEBACK & ~RESET;
endmodule // csh
