`timescale 1ns/1ns
`include "mbox.svh"
module csh(iAPR APR,
           iCLK CLK,
           iCCL CCL,
           iCSH CSH
);

  // XXX temporary
  initial begin
    CSH.EBOX_RETRY_REQ = '0;
    CSH.EBOX_T0_IN = '0;
    CSH.MBOX_RESP_IN = '0;
    CSH.PAGE_FAIL_HOLD = '0;
    CSH.GATE_VMA_27_33 = '0;

    CSH.PAR_BIT_A = '0;
    CSH.PAR_BIT_B = '0;
  end

  bit clk;
  bit MB_REQ, CHAN_REQ_EN, EBOX_CYC, CYC_TYPE_HOLD, READY_TO_GO, WRITEBACK_T2;
  bit EBOX_REQ_GRANT, EBOX_REQ_EN, NON_EBOX_REQ_GRANT;
  bit CACHE_IDLE_IN_A, CACHE_IDLE_IN_B, CACHE_IDLE_IN_C, CACHE_IDLE_IN_D, CACHE_IDLE_IN_H;
  bit PHASE_CHANGE_COMING, CHAN_RD_T5, E_CACHE_WR_CYC, CACHE_TO_MB_T4;
  bit EBOX_T0, PGRF_CYC, RESET, DATA_DLY_1;
  bit MBOX_RESP, EBOX_RESTART, A_CHANGE_COMING_IN, SBUS_DIAG_3;
  bit ONE_WORD_RD, EBOX_MAP, MAP_PROBLEM, PAGE_FAIL_T2, EBOX_T2;
  bit MB_TEST_PAR_A_IN, LRU_ANY_WR, ANY_VAL_HOLD_IN;
  bit e52q3, e52q13, e52q14, e52q15;

  // CSH1 p.24
  always_comb begin
    clk = CLK.CSH;
    CSH.MB_REQ_GRANT = MB_REQ;
    CSH.CHAN_REQ_GRANT = ~MB_REQ & CCL.CHAN_REQ & CHAN_REQ_EN;
    EBOX_REQ_GRANT = ~MB_REQ & CLK.EBOX_REQ & EBOX_REQ_EN & ~CCL.CHAN_REQ;
    CYC_TYPE_HOLD = ~READY_TO_GO & ~WRITEBACK_T2;

    CSH.EBOX_ERA_GRANT = APR.EBOX_ERA & ~CCL.CHAN_REQ & EBOX_REQ & ~MB_REQ;
    CSH.EBOX_CCA_GRANT = APR.EBOX_CCA & ~CCL.CHAN_REQ & EBOX_REQ & CLK.EBOX_REQ & ~MB_REQ;
    CSH.CCA_REQ_GRANT = MBX.CCA_REQ & ~CCL.CHAN_REQ & CCA_REQ_EN & ~CLK.EBOX_REQ & ~MB_REQ;
    NON_EBOX_REQ_GRANT = PAGE_REFILL_T4 | MB_REQ_GRANT |
                         CSH.CHAN_REQ_GRANT | CSH.CCA_REQ_GRANT;

    CACHE_IDLE_IN_A = PMA.CSH_WRITEBACK_CYC & MBX.CACHE_TO_MB_DONE |
                      ~READY_TO_GO & CACHE_IDLE |
                      E_CACHE_WR_CYC & CACHE_TO_MB_T4 |
                      CHAN_RD_T5 & PHASE_CHANGE_COMING;

    CACHE_IDLE_IN_B = EBOX_PAUSE_WRITE & E_T2_MEM_REF & PAG.PAGE_OK |
                      (CCA_CYC_DONE | EBOX_WR_T4) |
                      EBOX_T0 & APR.EBOX_LOAD_REG |
                      CACHE_IDLE_IN_C;

    CACHE_IDLE_IN_D = VMA.AC_REF & EBOX_T0 | EBOX_T1 & CLK.EBOX_CYC_ABORT;

    CACHE_IDLE_IN_H = e52q3 | e52q14 | e52q15;

    PGRF_CYC = PMA.PAGE_REFILL_CYC;

    READY_TO_GO = e52q13 & PAGE_REFILL_T10 |
                  CLK.EBOX_SYNC & CACHE_IDLE |
                  (~EBOX_CYC | PAGE_REFILL_T4 | RESET) & CACHE_IDLE |
                  ~MCL.VMA_PAUSE & MBOX_RESP & ONE_WORD_RD;

    RESET = CLK.MR_RESET;
  end

  always_ff @(posedge clk) begin
    e52q3 <= CACHE_IDLE_IN_D;
    e52q13 <= ~MEM_BUSY;
    e52q14 <= CACHE_IDLE_IN_A | CHAN_WQR_T5 | CACHE_WR_FROM_MEM |
              RESET | CACHE_IDLE_IN_B | EBOX_RETRY_NEXT;
    e52q15 <= READY_TO_GO & ~EBOX_REQ_GRANT & ~NON_EBOX_REQ_GRANT |
              E_RD_T2_OK & RD_FOUND |
              A_CHANGE_COMING_IN & MBX.SBUS_DIAG_3 |
              CHAN_T3 & ~ANY_VALID_MATCH & CCL.CHAN_TO_MEM;

    CHAN_REQ_EN <= ~WRITEBACK_T1 & ~PAGE_REFILL_T4_IN & ~MEM_BUSY;
    MB_REQ <= MBX.MB_REQ_IN;
    CCA_REQ_EN <= ~WRIETBACK_T1 & ~PAGE_REFILL_T4_IN & ~CORE_BUSY;
  end

  // Note active low symbol
  USR4 e72(.S0('0),
           .D({CSH.EBOX_REQ_GRANT, CSH.MB_REQ_GRANT, CSH.CHAN_REQ_GRANT, CSH.CCA_REQ_GRANT}),
           .S3('0),
           .SEL(CYC_TYPE_HOLD),
           .Q({EBOX_CYC, CSH.MB_CYC, CSH.CHAN_CYC, CSH.CCA_CYC}),
           .CLK(clk));


  // CSH2 p.25
  always_comb begin
    CSH.MBOX_RESP_IN = E_RD_T2_OK & RD_FOUND |
                       A_CHANGE_COMING_IN & SBUS_DIAG_3 |
                       ~RESET & (E_CACHE_WR_CYC & CACHE_TO_MB_T4 |
                                 ~EBOX_SYNC_HOLD & DATA_DLY_1 |
                                 MBC.CORE_DATA_VALminus1 & E_CORE_RD_RQ |
                                 ~E_CORE_RD_COMP & MBOX_RESP & ~EBOX_RESTART) |
                       CACHE_IDLE_IN & EBOX_CYC;

    EBOX_RESTART = MBOX_RESP & CLK.EBOX_SYNC;
    SBUS_DIAG_3 = MBX.SBUS_DIAG_3;

    E_CACHE_WR_CYC = MCL.VMA_WRITE & EBOX_CYC & ~EBOX_READ;
    CSH.EBOX_RETRY_REQ = EBOX_CYC & WRITEBACK_T1 |
                         EBOX_RETRY_NEXT & ~RESET;

    E_REQ_EN_CLR = WRITEBACK_T1 | (E_WRITEBACK & MCL.VMA_READ & PMA.CSH_WRITEBACK_CYC);
    EBOX_RETRY_NEXT_IN = (~MBX.CACHE_BIT | LRU_ANY_WR) &
                         E_WR_T2 & PAG.PAGE_OK & CORE_BUSY &
                         ~ANY_VALID_MATCH |
                         (CSH.ADR_READY &
                          (CORE_BUSY & APR.EBOX_SBUS_DIAG |
                           EBOX_REFILL_OK & PAG.PAGE_REFILL & ~RESET) &
                          EBOX_CYC) |
                         ~MBC.WRITE_OK & WR_TEST & EBOX_CYC |
                         ~RD_FOUND & E_RD_T2_OK & CORE_BUSY;
    WR_TEST = CSH.CLEAR_WR_T0 | EBOX_WR_T3;
  end

  always_ff @(posedge clk) begin
    MBOX_RESP <= CSH.MBOX_RESP_IN;

    ONE_WORD_RD <= E_RD_T2_COR_OK & ~ANY_VALID_MATCH & ~MBX.CACHE_BIT |
                   ~EBOX_RESTART & ONE_WORD_RD & ~READY_TO_GO;
    RD_PAUSE_2ND_HALF <= ONE_WORD_RD & EBOX_RESTART & EBOX_PAUSE |
                         ~READY_TO_GO & RD_PAUSE_2ND_HALF;
    RD_PSE_2ND_REQ_EN <= DATA_DLY_2 & RD_PAUSE_2ND_HALF |
                         RD_PSE_2ND_REQ_EN & ~CLK.EBOX_REQ ~RESET;
    E_CORE_RD_RQ <= E_RD_T2_CORE_OK & ~RD_FOUND & ANY_VALID_MATCH |
                    ~LRU_ANY_WR & ~ANY_VALID_MATCH | E_RD_T2_CORE_OK |
                    ANY_VALID_MATCH & ~MBX.CACHE_BIT & E_RD_T2_CORE_OK |
                    ~MBC.CORE_DATA_VALID & ~RESET & E_CORE_RD_RQ;
    EBOX_RETRY_NEXT <= EBOX_RETRY_NEXT_IN;
    EBOX_REQ_EN <= ~CORE_BUSY & ~E_REQ_EN_CLR & ~PAGE_REFILL_T4_IN |
                   MB_CYC & MCL.VMA_READ |
                   RESET |
                   ~E_REQ_EN_CLR & EBOX_REQ_EN & ~EBOX_RETRY_NEXT;
  end


  // CSH3 p.26
  always_comb begin
    LOAD_EBUS_REG = CTL.DIAG_LD_EBUS_REG | PAGE_FAIL_T2 |
                    APR.EBOX_READ_REG & EBOX_T3 & ~MAP_PROBLEM;
    CACHE_IDLE_IN_C = APR.EBOX_READ_REG & EBOX_T3 & ~MAP_PROBLEM | PAGE_FAIL_T3;
    EBOX_MAP = MCL.EBOX_MAP;
    MAP_PROBLEM = MCL.EBOX_MAP &
                  (PAG.PAGE_REFILL | ~KI10_PAGING_MODE) &
                  ~PAG.PAGE_OK;
    CSH.ADR_READY = EBOX_T2 | CSH.T2;
    ANY_VAL_HOLD_IN = CSH.ADR_READY & ANY_VALID_MATCH |
                      ~READY_TO_GO & ANY_VAL_HOLD;
    ANY_WRITTEN_MATCH = CSH._0_VALID_MATCH & CSH._0_ANY_WR |
                        CSH._1_VALID_MATCH & CSH._1_ANY_WR |
                        CSH._2_VALID_MATCH & CSH._2_ANY_WR |
                        CSH._3_VALID_MATCH & CSH._3_ANY_WR;
    RD_FOUND = _0_WD_VAL & CSH._0_VALID_MATCH |
               _1_WD_VAL & CSH._1_VALID_MATCH |
               _2_WD_VAL & CSH._2_VALID_MATCH |
               _3_WD_VAL & CSH._3_VALID_MATCH;
    ANY_VALID_MATCH = CSH._0_VALID_MATCH | CSH._1_VALID_MATCH |
                      CSH._2_VALID_MATCH | CSH._3_VALID_MATCH;
    MB_TEST_PAR_A_IN = DATA_DLY_2 | PAGE_REFILL_T12 | CACHE_WR_FROM_MEM;
    CSH.MATCH_HOLD_2_IN = (~ANY_VALID_MATCH | CSH._3_VALID_MATCH | CSH._2_VALID_MATCH) &
                          (CSH._2_VALID_MATCH | CSH.LRU_2 | CSH._3_VALID_MATCH);
    CSH.MATCH_HOLD_1_IN = (~ANY_VALID_MATCH | CSH._3_VALID_MATCH | CSH._1_VALID_MATCH) &
                          (CSH._1_VALID_MATCH | CSH.LRU_1 | CSH._3_VALID_MATCH);
    MB_WR_RQ_CLR_NXT = PAGE_REFILL_T11 | CSH.WR_FROM_MEM_NXT |
                       EBOX_TOOK_1_WD | CHAN_READ;
  end

  always_ff @(posedge clk) begin
    ANY_VAL_HOLD <= CSH.ANY_VAL_HOLD_IN;
    CSH.GATE_VMA_27_33 <= EBOX_T0_IN | (EBOX_CYC & ~MBX.REFILL_ADR_EN_NXT);
    CSH.ADR_PMA_EN <= ~EBOX_CYC & ~EBOX_T0_IN & ~MBX.REFILL_ADR_EN_NXT;
  end

  mux e26(.en('1),
          .sel({CSH.LRU_2, CSH.LRU_1}),
          .d0({CSH._0_ANY_WR, CSH._1_ANY_WR, CSH._2_ANY_WR, CSH._3_ANY_WR}),
          .d1(4'b0000),
          .b0(LRU_ANY_WR),
          .b1());


  // CSH4 p.27
  always_comb begin
    CSH.EBOX_T0_IN = READY_TO_GO & EBOX_REQ_GRANT | CLK.EBOX_REQ & RD_PSE_2ND_REQ_EN;
    E_T2_MEM_REF = ~APR.EBOX_SBUS_DIAG & EBOX_T2 & ~APR.EBOX_READ_REG;
    E_WR_T2 = ~MCL.VMA_PASE & E_T2_MEM_REF & ~EBOX_READ;
    E_RD_T2_OK = PAG.PAGE_OK & MCL.VMA_READ & EBOX_T2;
    E_RD_T2_CORE_OK = E_RD_T2_OK & ~CORE_BUSY;
    EBOX_READ = MCL.VMA_READ;
    EBOX_PAUSE_WRITE = ~EBOX_READ & EBOX_PAUSE;
    EBOX_PAUSE = MCL.VMA_PAUSE;
    EBOX_WR_T4_IN = EBOX_WR_T3 & ~EBOX_RETRY_NEXT_IN;
    CSH.REFILL_RAM_WR = APR.EN_REFILL_RAM_WR & EBOX_T2;
  end

  always_ff @(posedge clk) begin
    EBOX_T0 <= CSH.EBOX_T0_IN;
    EBOX_T1 <= EBOX_T0 & ~VMA.AC_REF & ~CACHE_IDLE_IN;
    EBOX_T2 <= EBOX_T1 & ~CLK.EBOX_CYC_ABORT;
    EBOX_T3 <= EBOX_T2;
    CSH.ONE_WORD_WR_T0 <= ~CORE_BUSY & APR.EBOX_SBUS_DIAG & EBOX_T2 |
                          ~MBX.CACHE_BIT & ~ANY_VALID_MATCH & PAG.PAGE_OK &
                          ~CORE_BUSY & ~MCL.VMA_PAUSE & ~EBOX_READ & E_T2_MEM_REF;
    CSH.WRITEBACK_T1 <= ANY_WRITTEN_MATCH & MBX.CSH_CCA_VAL_CORE & CCA_T3 |
                        E_T2_MEM_REF & ~CORE_BUSY & ~EBOX_PAUSE_WRITE &
                        PAG.PAGE_OK & MBX.CACHE_BIT & LRU_ANY_WR & ~ANY_VALID_MATCH;
    WRITEBACK_T2 <= WRITEBACK_T1;

    PAGE_FAIL_DLY <= PAGE_FAIL_HOLD;
    PAGE_FAIL_T2 <= ~(~PAGE_FAIL_DELAY | ~PAGE_FAIL_HOLD);
    PAGE_FAIL_T3 <= PAGE_FAIL_T2;

    DATA_CLR_T2 <= MBC.CSH_DATA_CLR_T3;
    EBOX_WR_T3 <= DATA_CLR_T4 & E_CACHE_WR_CYC |
                  E_WR_T2 & ANY_VALID_MATCH & PAG.PAGE_OK;
    EBOX_WR_T4 <= EBOX_WR_T4_IN;
    CSH.CLEAR_WR_T0 <= PAG.PAGE_OK & ~ANY_VALID_MATCH & E_WR_T2 & MBX.CACHE_BIT & ~LRU_ANY_WR;
    CSH.DATA_CLR_DONE <= MBC.DATA_CLR_DONE_IN & ~READY_TO_GO |
                         ANY_VALID_MATCH & E_WR_T2 & PAG.PAGE_OK;

    // CSH5 p.28
    TODO
    // CSH6 p.29
    TODO
  end
endmodule // csh

