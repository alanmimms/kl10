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
           iEBUS EBUS,
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
  bit CSH_WD_0_VAL, CSH_WD_1_VAL, CSH_WD_2_VAL, CSH_WD_3_VAL;
  bit EBOX_PAGED, CCA_CYC_DONE, RESET, CSH_CCA_CYC, CSH_CCA_ONE_PAGE;
  bit CCA_HOLD_ADR, MB_WR_RQ_ANY, MB_WR_RQ_P1, MB_WR_RQ_P2, CTOMB_LOAD;
  bit MB_WR_RQ_CLR, MB_WR_RQ_CLR_FF, MB_SEL_HOLD_FF_IN;
  bit MB_REQ_ALLOW, MB_REQ_ALLOW_FF, CORE_BUSY;
  bit [0:1] MB_SEL;
  bit [0:3] MB_WR_RQ, CTOMB_WD_RQ, CSH_TO_MB_WD, WD_NEEDED, CSH_WD_VAL;
  bit [0:3] e77SR;
  bit [0:7] CORE_WD_COMING;     // Larger to drop 4MSBs off E18
  bit e85q2, e85q15;
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
  bit DIAG_CYC_DONE, WR_WDS_IN_MB;


  // MBX1 p.178
  always_comb begin
    MBX.REFILL_ADR_EN_NXT = CSH.MB_REQ_GRANT & CSH.READY_TO_GO |
                            MBC.CSH_DATA_CLR_T3 & E_CORE_RD_RQ |
                            ~CSH.READY_TO_GO & MBX.REFILL_ADR_EN;
    MBX.FORCE_MATCH_EN = MBX.REFILL_ADR_EN | E_CORE_RD_RQ | PMA.CSH_WRITEBACK_CYC;
    MBOX.FORCE_NO_MATCH = MBX.FORCE_MATCH_EN |
                          EBOX_DIAG_CYC |
                          MBX.CCA_ALL_PAGES_CYC |
                          ~CON.CACHE_LOOK_EN |
                          C_DIR_PAR_ERR;
    CSH_WD_0_VAL = ANY_VAL_HOLD & e77SR[0];
    CSH_WD_1_VAL = ANY_VAL_HOLD & e77SR[1];
    CSH_WD_2_VAL = ANY_VAL_HOLD & e77SR[2];
    CSH_WD_3_VAL = ANY_VAL_HOLD & e77SR[3];
    READY_TO_GO = CSH.READY_TO_GO;
    EBOX_PAGED = PMA.EBOX_PAGED;
    MBX.CCA_INVAL_T4 = CSH.CCA_INVAL_T4;
    CCA_CYC_DONE = CSH.CCA_CYC_DONE;
    MBX.CCA_SEL[0] = ~EBOX_LOAD_REG & e85q2 | ~APR.EBOX_CCA & ~RESET;
    MBX.CCA_SEL[1] = ~EBOX_LOAD_REG | ~APR.EBOX_CCA;
    MBX.CACHE_BIT = (PAG.PT_CACHE & PMA.EBOX_PAGED & MCL.EBOX_CACHE |
                     ~EBOX_PAGED & MCL.EBOX_CACHE) &
                    ~C_DIR_PAR_ERR & MBOX.CACHE_EXISTS;
    RESET = CLK.MR_RESET;
    CSH_CCA_CYC = CSH.CCA_CYC;
    MBX.CCA_ALL_PAGES_CYC = CSH.CCA_CYC & ~CSH_CCA_ONE_PAGE;
    MBX.CCA_REQ = e85q15 & ~RESET;
  end

  always_ff @(posedge clk) begin
    MBX.REFILL_ADR_EN <= MBX.REFILL_ADR_EN_NXT;
    MBX.EBOX_LOAD_REG <= CSH.EBOX_LOAD_REG;
    e85q2 <= ~CCA_CYC_DONE;
    e85q15 <= (MBX.CCA_REQ | ~MBX.CCA_SEL[1]) &
              (~CCA_CYC_DONE | ~PMA.CCA_CRY_OUT);
    CCA_HOLD_ADR <= ~READY_TO_GO & (CSH.CCA_INVAL_T4 | CCA_HOLD_ADR);
  end

  USR4 e77(.S0('0),
           .D({CSH._0_WD_VAL, CSH._1_WD_VAL, CSH._2_WD_VAL, CSH._3_WD_VAL}),
           .S3('0),
           .SEL({2{ANY_VAL_HOLD}}),
           .Q(e77SR),
           .CLK(clk));

  bit unusedE78;
  USR4 e78(.S0('0),
           .D({IR.AC[10:12], 1'b0}),
           .S3('0),
           .SEL({2{MBX.CCA_SEL[1]}}),
           .Q({CSH_CCA_ONE_PAGE, MBX.CSH_CCA_VAL_CORE, MBX.CSH_CCA_INVAL_CSH, unusedE78}),
           .CLK(clk));


  // MBX2 p.179
  bit [0:2] e33Q;
  bit e57q7, e45q6;

  always_comb begin
    CACHE_TO_MB_CONT = |CTOMB_WD_RQ;
    MBOX.SBUS_ADR[34] = (PMA.PA[34] | e57q7) &
                        (e33Q[1] | e45q6 | ~e57q7) &
                        (CCW.CHA[34] | ~e57q7 | ~e45q6);
    MBOX.SBUS_ADR[35] = (PMA.PA[35] | e57q7) &
                        (e33Q[2] | e45q6 | ~e57q7) &
                        (CCW.CHA[35] | ~e45q6 | ~e57q7);
    MBX.CHAN_WR_CYC = CSH.CHAN_CYC & CCL.CHAN_TO_MEM;
    CTOMB_LOAD = MBX.CHAN_WR_CYC & CSH.T2 |
                 CSH.PAGE_REFILL_T8 |
                 CSH.CHAN_T4 & ~MBX.CHAN_WR_CYC;
    CSH_TO_MB_WD = (WD_NEEDED & CTOMB_LOAD | CSH.WD_WR) &
                   (CSH_WD_VAL | MBX.CHAN_WR_CYC | CSH.WD_WR);
    MB_SEL_HOLD_FF_IN = MB_WR_RQ_CLR_FF & (MB_WR_RQ_ANY | MBX.MB_SEL_HOLD);
    MBOX.MB_SEL_2_EN = (CCL.CH_MB_SEL[0] | ~CHAN_READ) &
                       (MB_WR_RQ_P2 | CHAN_READ);
    MBOX.MB_SEL_1_EN = (CCL.CH_MB_SEL[1] | ~CHAN_READ) &
                       (MB_WR_RQ_P1 | CHAN_READ);
    MBX.MB_SEL_HOLD = (~MBOX.ACKN_PULSE | MBX.MEM_RD_RQ) &
                      MB_SEL_HOLD_FF &
                      (~SBUS_DIAG_2 & ~RESET) &
                      // -MBX3 CORE BUSY 1A H on MBX2 A3.
                      (MBX.MEM_RD_RQ | ~CORE_DATA_VALID | ~CORE_BUSY);
    CHAN_READ = MBOX.CHAN_READ;
  end

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
  
  decoder e18(.sel({1'b0, MBC.CORE_ADR}),
              // -MBX3 CORE BUSY 1A L on MBX2 B4.
              .en(~CORE_BUSY & (MBC.CORE_DATA_VALminus2 | CSH.ONE_WORD_WR_T0)),
              .q(CORE_WD_COMING)); // Only [0:3] is actually used
  
  bit [2:3] unusedE12;
  USR4 e12(.S0('0),
           .D({{2{MBOX.MB_SEL_2_EN}}, {2{MBOX.MB_SEL_1_EN}}}),
           .S3('0),
           .SEL({2{MBX.MB_SEL_HOLD}}),
           .Q({MB_SEL, unusedE12}),
           .CLK(clk));

  USR4  e9(.S0('0),
           .D({(CORE_WD_COMING[0] | CSH_TO_MB_WD[0] | MB_WR_RQ[0]) &
               (MB_SEL[0] | MB_SEL[1] | ~MB_WR_RQ_CLR),
               (CORE_WD_COMING[1] | CSH_TO_MB_WD[1] | MB_WR_RQ[1]) &
               (MB_SEL[0] | ~MB_SEL[1] | ~MB_WR_RQ_CLR),
               (CORE_WD_COMING[2] | CSH_TO_MB_WD[2] | MB_WR_RQ[2]) &
               (~MB_SEL[0] | MB_SEL[1] | ~MB_WR_RQ_CLR),
               (CORE_WD_COMING[3] | CSH_TO_MB_WD[3] | MB_WR_RQ[3]) &
               (~MB_SEL[0] | ~MB_SEL[1] | ~MB_WR_RQ_CLR)}),
              .S3('0),
              .SEL({1'b0, RESET}),
              .Q(MB_WR_RQ),
              .CLK(clk));
               

  always_ff @(posedge clk) begin
    ANY_VAL_HOLD <= CSH.ANY_VAL_HOLD_IN;
    MB_WR_RQ_CLR_FF <= CSH.MB_WR_RQ_CLR_NXT;
    MBOX.MB_REQ_HOLD <= MB_WR_RQ_ANY | MB_SEL_HOLD_FF_IN;
    MBX.MB_SEL_HOLD_FF <= MB_SEL_HOLD_FF_IN;
  end
  

  // MBX3 p.180
  USR4 e22(.S0('0),
           .D({MBOX.MB_PAR_BIT_IN, CSH_TO_MB_WD[0],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2] | ~MB_IN_SEL[0] & ~MB_IN_SEL[2]}),
           .S3('0),
           .SEL({2{MBOX.MB0_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB0_PAR, CTOMB_WD_RQ[0], MB0_DATA_CODE_2, MB0_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e21(.S0('0),
           .D({MBOX.MB_PAR_BIT_IN, CSH_TO_MB_WD[1],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2] | ~MB_IN_SEL[0] & ~MB_IN_SEL[2]}),
           .S3('0),
           .SEL({2{MBOX.MB1_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB1_PAR, CTOMB_WD_RQ[1], MB1_DATA_CODE_2, MB1_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e26(.S0('0),
           .D({MBOX.MB_PAR_BIT_IN, CSH_TO_MB_WD[2],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2] | ~MB_IN_SEL[0] & ~MB_IN_SEL[2]}),
           .S3('0),
           .SEL({2{MBOX.MB2_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB2_PAR, CTOMB_WD_RQ[2], MB2_DATA_CODE_2, MB2_DATA_CODE_1}),
           .CLK(clk));
           
  USR4 e31(.S0('0),
           .D({MBOX.MB_PAR_BIT_IN, CSH_TO_MB_WD[3],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2],
               ~MB_IN_SEL[0] & ~MB_IN_SEL[2] | ~MB_IN_SEL[0] & ~MB_IN_SEL[2]}),
           .S3('0),
           .SEL({2{MBOX.MB3_HOLD_IN & (CTOMB_LOAD | MBX.WRITEBACK_T2 | RESET)}}),
           .Q({MB3_PAR, CTOMB_WD_RQ[3], MB3_DATA_CODE_2, MB3_DATA_CODE_1}),
           .CLK(clk));
           
  bit e70q14;
  bit [0:3] e48SR;
  
  always_comb begin
    case (MB_SEL)
    2'b00: MBOX.MB_PAR = MB0_PAR;
    2'b01: MBOX.MB_PAR = MB1_PAR;
    2'b10: MBOX.MB_PAR = MB2_PAR;
    2'b11: MBOX.MB_PAR = MB3_PAR;
    endcase

    case (MB_SEL)
    2'b00: MBOX.MB_DATA_CODE_2 = MB0_DATA_CODE_2;
    2'b01: MBOX.MB_DATA_CODE_2 = MB1_DATA_CODE_2;
    2'b10: MBOX.MB_DATA_CODE_2 = MB2_DATA_CODE_2;
    2'b11: MBOX.MB_DATA_CODE_2 = MB3_DATA_CODE_2;
    endcase

    case (MB_SEL)
    2'b00: MBOX.MB_DATA_CODE_1 = MB0_DATA_CODE_1;
    2'b01: MBOX.MB_DATA_CODE_1 = MB1_DATA_CODE_1;
    2'b10: MBOX.MB_DATA_CODE_1 = MB2_DATA_CODE_1;
    2'b11: MBOX.MB_DATA_CODE_1 = MB3_DATA_CODE_1;
    endcase

    MBX.REFILL_HOLD = CCA_HOLD_ADR | PMA.CSH_WRITEBACK_CYC | MB_REQ_ALLOW;
    MB_REQ_ALLOW = CSH.E_CORE_RD_RQ & ~CSH.ONE_WORD_RD |
                   (MBOX.MB_REQ_HOLD | MBOX.CORE_RD_IN_PROG) & ~RESET & MB_REQ_ALLOW_FF;
    // MBOX.CORE_BUSY is <EA1> CORE BUSY A H on MBX3 B7 (p.180).
    // We drive MBX3 CORE BUSY 1A L and MBX3 CORE BUSY 1A H from that.
    CORE_BUSY = MBOX.CORE_BUSY;
    EBOX_DIAG_CYC = PMA.CSH_EBOX_CYC & APR.EBOX_SBUS_DIAG;
    MBOX.MEM_DATA_TO_MEM = MBC.MEM_START & ~MBX.MEM_RD_RQ |
                           SBUS_DIAG_0 & ~SBUS_DIAG_2 |
                           // MBX3 CORE BUSY 1A H on MBX3 A7.
                           CORE_BUSY;
    e70q14 = MBX.CACHE_TO_MB_DONE & EBOX_DIAG_CYC |
             ~DIAG_CYC_DONE & SBUS_DIAG_CYC & ~RESET;
    MBOX.MEM_DIAG = SBUS_DIAG_0 & ~SBUS_DIAG_1;
    DIAG_CYC_DONE = SBUS_DIAG_3 & MBC.A_CHANGE_COMING;

    MBOX.MEM_TO_C_SEL[0] = e48SR[0] & e48SR[2] |
                           (E_CORE_RD_RQ | EBOX_DIAG_CYC) & e48SR[3];
    MBOX.MEM_TO_C_SEL[1] = e48SR[1] & e48SR[2] |
                           (E_CORE_RD_RQ | EBOX_DIAG_CYC) & e48SR[3] &
                           ~MBOX.E_CACHE_WR_CYC;

  end

  always_ff @(posedge clk) begin
    MB_REQ_ALLOW_FF <= MB_REQ_ALLOW;
    SBUS_DIAG_CYC <= e70q14;
  end

  USR4 e67(.S0('0),
           .D(4'b1111),
           .S3('0),
           .SEL({~MBC.A_CHANGE_COMING & e70q14, e70q14}),
           .CLK(clk),
           .Q({SBUS_DIAG_0, SBUS_DIAG_1, SBUS_DIAG_2, SBUS_DIAG_3}));

  USR4 e48(.S0('0),
           .D(EBUS.data[30:33]),
           .S3('0),
           .SEL(2'b00),
           .CLK(~CTL.DIAG_LOAD_FUNC_071),
           .Q(e48SR));

  
  // MBX4 p.181
  always_comb begin
    clk = CLK.MBX;
    MBOX.CSH_WR_WR_EN[0] = ~CSH_CHAN_CYC & ~MBOX.CSH_WR_WR_DATA &
                           ~MBOX.MB_SEL[0] & ~MBOX.MB_SEL[1] |
                           CSH_CHAN_CYC & WD_NEEDED[0] |
                           MBOX.CSH_WR_WR_DATA & ~PMA.PA[34] & ~PMA.PA[35];
    MBOX.CSH_WR_WR_EN[1] = ~CSH_CHAN_CYC & ~MBOX.CSH_WR_WR_DATA &
                           ~MBOX.MB_SEL[0] & MBOX.MB_SEL[1] |
                           CSH_CHAN_CYC & WD_NEEDED[1] |
                           MBOX.CSH_WR_WR_DATA & ~PMA.PA[34] & PMA.PA[35];
    MBOX.CSH_WR_WR_EN[2] = ~CSH_CHAN_CYC & ~MBOX.CSH_WR_WR_DATA &
                           MBOX.MB_SEL[0] & ~MBOX.MB_SEL[1] |
                           CSH_CHAN_CYC & WD_NEEDED[2] |
                           MBOX.CSH_WR_WR_DATA & PMA.PA[34] & ~PMA.PA[35];
    MBOX.CSH_WR_WR_EN[3] = ~CSH_CHAN_CYC & ~MBOX.CSH_WR_WR_DATA &
                           MBOX.MB_SEL[0] & MBOX.MB_SEL[1] |
                           CSH_CHAN_CYC & WD_NEEDED[3] |
                           MBOX.CSH_WR_WR_DATA & PMA.PA[34] & PMA.PA[35];
    WD_NEEDED[0] = CCW.WD0_REQ | ~CSH.CHAN_CYC;
    WD_NEEDED[1] = CCW.WD1_REQ | ~CSH.CHAN_CYC;
    WD_NEEDED[2] = CCW.WD2_REQ | ~CSH.CHAN_CYC;
    WD_NEEDED[3] = CCW.WD3_REQ | ~CSH.CHAN_CYC;
    E_CORE_RD_RQ = CSH.E_CORE_RD_RQ;
    CSH_CHAN_CYC = CSH.CHAN_CYC;
    MBX.WRITEBACK_T2 = MBOX.CSH_WR_OUT_EN;
    MBX.CACHE_TO_MB_DONE = CACHE_TO_MB_T1 & ~CACHE_TO_MB_CONT;
  end

  always_ff @(posedge clk) begin
    MBOX.CSH_WR_OUT_EN <= CSH.WRITEBACK_T1;
    CACHE_TO_MB_T1 <= MBX.CACHE_TO_MB_T4 | MBOX.CSH_WR_OUT_EN;
    MBX.CACHE_TO_MB_T2 <= CACHE_TO_MB_T1 & ~CACHE_TO_MB_DONE & ~RESET |
                          CTOMB_LOAD & ~MBX.CHAN_WR_CYC |
                          MBOX.PHASE_CHANGE_COMING & MBX.CACHE_TO_MB_T2 |
                          CSH.ONE_WORD_WR_T0;
    CACHE_TO_MB_T3 <= MBX.CACHE_TO_MB_T2 & MBOX.PHASE_CHANGE_COMING;
    MBX.CACHE_TO_MB_T4 <= CACHE_TO_MB_T3;
  end


  // MBX5 p.182
  bit e71q13, e75q14, e75q15;
  always_comb begin
    ONE_WORD_RD = CSH.ONE_WORD_RD;
    RD_NON_VAL_WDS = E_CORE_RD_RQ & ~ONE_WORD_RD |
                     CSH.PGRF_CYC |
                     CSH.CHAN_CYC & ~MBX.CHAN_WR_CYC;
    WR_WDS_IN_MB = MBOX.E_CACHE_WR_CYC | MBX.CHAN_WR_CYC | PMA.CSH_WRITEBACK_CYC;

    MBX.RQ_IN[0] = ~PMA.PA[34] & ~PMA.PA[35] & ONE_WORD_RD |
                   WR_WDS_IN_MB & MB_WR_RQ[0] |
                   ~CSH_WD_0_VAL & WD_NEEDED[0] & RD_NON_VAL_WDS;
    MBX.RQ_IN[1] = ~PMA.PA[34] & PMA.PA[35] & ONE_WORD_RD |
                   WR_WDS_IN_MB & MB_WR_RQ[1] |
                   ~CSH_WD_1_VAL & WD_NEEDED[1] & RD_NON_VAL_WDS;
    MBX.RQ_IN[2] = PMA.PA[34] & ~PMA.PA[35] & ONE_WORD_RD |
                   WR_WDS_IN_MB & MB_WR_RQ[2] |
                   ~CSH_WD_2_VAL & WD_NEEDED[2] & RD_NON_VAL_WDS;
    MBX.RQ_IN[3] = PMA.PA[34] & PMA.PA[35] & ONE_WORD_RD |
                   WR_WDS_IN_MB & MB_WR_RQ[3] |
                   ~CSH_WD_3_VAL & WD_NEEDED[3] & RD_NON_VAL_WDS;
    C_DIR_PAR_ERR = APR.C_DIR_P_ERR | e75q15;

    MBX.MEM_RD_RQ_IN = E_CORE_RD_RQ | ONE_WORD_RD | RD_NON_VAL_WDS;
    MBX.MEM_WR_RQ_IN = MBX.CACHE_TO_MB_T4 | MBX.CHAN_WR_CYC |
                       ONE_WORD_RD & MCL.VMA_PAUSE;
    MBX.MB_REQ_IN = MBOX.MB_REQ_HOLD & ~CSH.MB_CYC & MB_REQ_ALLOW & ~MBC.INH_1ST_MB_REQ;
    MBOX.MEM_TO_C_EN = CSH.MB_CYC | MBOX.MEM_TO_C_DIAG_EN;
  end

  always_ff @(posedge clk) begin
    e71q13 <= CON.CACHE_LOOK_EN & ~CSH_CCA_CYC & CSH.ADR_READY & CSH.ADR_PAR_BAD |
              CSH.WRITEBACK_T1 & CSH.ADR_PAR_BAD |
              ~READY_TO_GO & ~RESET & e71q13;
    e75q14 <= e71q13 & READY_TO_GO |
              ~APR.C_DIR_P_ERR & MBX.CSH_ADR_PAR_ERR & ~RESET;
    e75q15 <= e75q14;
  end


  // MBX6 p.183
  bit e61q14, e32Q, e46Q, e56Q;
  always_comb begin
    DIAG = CTL.DIAG[4:6];
    DIAG_EN = CTL.DIAG_READ_FUNC_17x;
    MBX.EBUSdriver.driving = DIAG_EN;
  end

  mux e43(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.CACHE_BIT, MBX.CACHE_TO_MB[34], MBX.CACHE_TO_MB[35], CACHE_TO_MB_DONE,
              ~MBX.CACHE_TO_MB_T2, ~CACHE_TO_MB_T3,
              ~MBX.CACHE_TO_MB_T4, MBX.CCA_ALL_PAGES_CYC}),
          .q(MBX.EBUSdriver.data[30]));

  mux e38(.en(DIAG_EN),
          .sel(DIAG),
          .d({~MBX.CCA_REQ, MBX.CCA_SEL[1], MBX.CCA_SEL[0], ~MBX.CHAN_WR_CYC,
              MBX.CSH_CCA_INVAL_CSH, MBX.CSH_CCA_VAL_CORE,
              MBOX.CSH_WR_WD_EN[0], MBOX.CSH_WR_WD_EN[1]}),
          .q(MBX.EBUSdriver.data[31]));

  mux e11(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBOX.CSH_WR_WD_EN[2], MBOX.CSH_WR_WD_EN[3],
              MBOX.FORCE_NO_MATCH, MBOX.MEM_DATA_TO_MEM,
              MBOX.MB_DATA_CODE_1, MBOX.MB_DATA_CODE_2, MBOX.MB_PAR, MBOX.MB_REQ_HOLD}),
          .q(MBX.EBUSdriver.data[32]));

  mux e35(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.MB_REQ_IN, MBOX.MB_SEL[1], MBOX.MB_SEL[0], MBX.MB_SEL_HOLD,
              MBOX.MB0_HOLD_IN, MBOX.MB1_HOLD_IN, MBOX.MB2_HOLD_IN, MBOX.MB3_HOLD_IN}),
          .q(MBX.EBUSdriver.data[33]));

  mux e30(.en(DIAG_EN),
          .sel(DIAG),
          .d({~MBOX.MEM_TO_C_EN, ~MBOX.MEM_DIAG, MBX.MEM_RD_RQ_IN, MBOX.MEM_TO_C_SEL[1],
              MBOX.MEM_TO_C_SEL[0], MBX.MEM_WR_RQ_IN, MBX.REFILL_HOLD, MBX.RQ_IN[0]}),
          .q(MBX.EBUSdriver.data[34]));

  mux e16(.en(DIAG_EN),
          .sel(DIAG),
          .d({MBX.RQ_IN[1:3], MBOX.SBUS_ADR[34:35],
              ~MBX.SBUS_DIAG_3, ~SBUS_DIAG_CYC, ~MBX.WRITEBACK_T2}),
          .q(MBX.EBUSdriver.data[35]));

  always_ff @(posedge clk) begin
    CORE_DATA_VALIDminus1 <= MBC.CORE_DATA_VALminus2;
    CORE_DATA_VALID <= CORE_DATA_VALIDminus1;
    e61q14 <= e56Q;
  end

  mux e46(.en('1),
          .sel(MBOX.MB_IN_SEL),
          .d({MBX.CACHE_TO_MB[35], 1'b0, PMA.PA[35], CCL.CH_MB_SEL[1],
             MBC.CORE_ADR[35], 1'b0, CCL.CH_MB_SEL[1], 1'b0}),
          .q(e46Q));

  mux e56(.en('1),
          .sel(MBOX.MB_IN_SEL),
          .d({~CACHE_TO_MB_T3, 1'b0, ~CSH.ONE_WORD_WR_T0, ~CCL.CH_LOAD_MB,
              ~CORE_DATA_VALIDminus1, 1'b0, ~CCL.CH_LOAD_MB, 1'b0}),
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
  decoder e36(.en(~CACHE_TO_MB_CONT & CSH.CHAN_CYC & e61q14),
              .sel({1'b0, e32Q, e56Q}),
              .q({MBOX.MB0_HOLD_IN, MBOX.MB1_HOLD_IN, 
                  MBOX.MB2_HOLD_IN, MBOX.MB3_HOLD_IN, e36Ignored}));
endmodule
