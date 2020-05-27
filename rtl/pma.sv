`timescale 1ns/1ns
`include "ebox.svh"

module pma(iAPR APR,
           iCCL CCL,
           iCLK CLK,
           iCSH CSH,
           iMBX MBX,
           iMCL MCL,
           iPAG PAG,
           iPMA PMA,
           iVMA VMA);

  bit clock;
  bit CCA_LOAD, UBR_SEL;
  bit [0:2] _14to26_SEL, _27_SEL, _28to31_SEL, _32to33_SEL, _34to35_SEL;
  bit HOLD_ERA;
  bit PAGE_REFILL_T4, WRITEBACK_T2, CYC_TYPE_HOLD, PAGE_REFILL_5comma7, PAGE_REFILL_7;
  bit PAGE_REFILL_3comma4;
  bit [14:35] VA, UBR, EBR, CCA, UEBR, CAM, ERA;
  bit PGRF_UBR_COND;
  bit [0:1] CCA_SEL;
  bit VA_19to21eq7, VMA_EXEC_PER_PROC;

  // PMA1 p.84
  USR4  e5(.S0(1'b0),
           .D(VA[15:18]),
           .S3(1'b0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[15:18]),
           .CLK(clock));

  USR4 e13(.S0(1'b0),
           .D(VA[19:22]),
           .S3(1'b0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[19:22]),
           .CLK(clock));

  USR4 e12(.S0(1'b0),
           .D(VA[23:26]),
           .S3(1'b0),
           .SEL({2{~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)}}),
           .Q(UBR[23:26]),
           .CLK(clock));

  USR4  e3(.S0(1'b0),
           .D(VA[15:18]),
           .S3(1'b0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[15:18]),
           .CLK(clock));

  USR4  e8(.S0(1'b0),
           .D(VA[19:22]),
           .S3(1'b0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[19:22]),
           .CLK(clock));

  USR4  e7(.S0(1'b0),
           .D(VA[23:26]),
           .S3(1'b0),
           .SEL({2{APR.EBOX_UBR & MBX.EBOX_LOAD_REG}}),
           .Q(EBR[23:26]),
           .CLK(clock));

  bit unusedE20;
  USR4 e20(.S0(1'b0),
           .D({(UBR[14] | APR.EBOX_UBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG)),
               (EBR[14] | APR.EBOX_EBR & MBX.EBOX_LOAD_REG) &
               (VA[14] | ~(APR.EBOX_EBR & MBX.EBOX_LOAD_REG)),
              (CCA[14] | CCA_LOAD) & (VA[14] & ~CCA_LOAD),
              1'b0}),
           .S3(1'b0),
           .SEL(2'b00),
           .Q({UBR[14], EBR[14], CCA[14], unusedE20}),
           .CLK(clock));

  mux4x2  e4(.SEL(UBR_SEL),
             .D0(EBR[15:18]), 
             .D1(UBR[15:18]),
             .B(UEBR[15:18]));

  mux4x2 e18(.SEL(UBR_SEL),
             .D0(EBR[19:22]),
             .D1(UBR[19:22]),
             .B(UEBR[19:22]));

  mux4x2  e2(.SEL(UBR_SEL),
             .D0(EBR[23:26]),
             .D1(UBR[23:26]),
             .B(UEBR[23:26]));

  assign UEBR[14] = (UBR_SEL | EBR[14]) & (~UBR_SEL & UBR[14]);
  assign VA[14:26] = VMA.VMA[14:26];
  assign VA_19to21eq7 = VMA.VMA[19:21] == 3'b111;


  // PMA2 p.85
  bit e65q2;
  bit e36q15;
  bit unusedE40;
  bit [0:1] unusedE70;
  assign clock = CLK.PMA;
  assign CCA_LOAD = ~(APR.EBOX_UBR & MBX.EBOX_LOAD_REG);
  assign e65q2 = ~MBX.CCA_ALL_PAGES_CYC | (CCA[34:35] == 2'b00);
  assign e36q15 = CCA[30:33] == 4'b0000;
  assign PMA.CCA_CRY_OUT = &{e65q2, e36q15, CCA[27:29] == 3'b000};
  
  USR4 e10(.S0(1'b0),
           .D(VA[15:18]),
           .S3(1'b0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[15:18]),
           .CLK(clock));

  USR4 e24(.S0(1'b0),
           .D(VA[19:22]),
           .S3(1'b0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[19:22]),
           .CLK(clock));

  USR4 e28(.S0(1'b0),
           .D(VA[23:26]),
           .S3(1'b0),
           .SEL({2{CCA_LOAD}}),
           .Q(CCA[23:26]),
           .CLK(clock));

  UCR4 e40(.D(4'b0111),
           .CIN(~e36q15),
           .Q({unusedE40, CCA[27:29]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));

  UCR4 e75(.D(4'b1111),
           .CIN(~e65q2),
           .Q({CCA[30:33]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));

  UCR4 e70(.D(4'b0011),
           .CIN(1'b1),
           .Q({unusedE70, CCA[34:35]}),
           .COUT(),
           .SEL(CCA_SEL),
           .CLK(clock));


  // PMA3 p.86
  genvar k;
  generate
    for (k = 14; k <= 26; ++k) begin: PA14to26
      mux paMux(.en(1'b1),
                .sel(_14to26_SEL),
                .d({VMA.VMA[k], UEBR[k], 1'b0, PMA.CCW_CHA[k],
                    CAM[k], CCA[k], ERA[k], PAG.PT[k]}),
                .q(PMA.PA[k]));
    end
  endgenerate
  
  mux e80(.en(1'b1),
          .sel(_27_SEL),
          .d({ERA[27], 2'b10, PMA.CCW_CHA[27], {2{CCA[27]}}, VMA.VMA[27], 1'b0}),
          .q(PMA.PA[27]));

  mux e45(.en(1'b1),
          .sel(_28to31_SEL),
          .d({ERA[28], 1'b1, VA[18], PMA.CCW_CHA[28], {2{CCA[28]}}, VMA.VMA[28], 1'b0}),
          .q(PMA.PA[28]));

  mux e50(.en(1'b1),
          .sel(_28to31_SEL),
          .d({ERA[29], {2{VA[19]}}, PMA.CCW_CHA[29], {2{CCA[29]}}, VMA.VMA[29], 1'b0}),
          .q(PMA.PA[29]));

  mux e55(.en(1'b1),
          .sel(_28to31_SEL),
          .d({ERA[30], {2{VA[20]}}, PMA.CCW_CHA[30], {2{CCA[30]}}, VMA.VMA[30], 1'b0}),
          .q(PMA.PA[30]));

  mux e60(.en(1'b1),
          .sel(_28to31_SEL),
          .d({ERA[31], {2{VA[21]}}, PMA.CCW_CHA[31], {2{CCA[31]}}, VMA.VMA[31], 1'b0}),
          .q(PMA.PA[31]));


  // PMA4 p.87
  generate
    for (k = 14; k <= 33; k += 4) begin:ERA14_33
      USR4 eraSR(.S0(1'b0),
                 .D(PMA.PA[k:k+3]),
                 .S3(1'b0),
                 .SEL({2{HOLD_ERA}}),
                 .Q(ERA[k:k+3]),
                 .CLK(clock));
    end
  endgenerate

  bit [2:3] unusedE53;
  USR4 e53(.S0(1'b0),
           .D({PMA.PA[34:35], 2'b00}),
           .S3(1'b0),
           .SEL({2{HOLD_ERA}}),
           .Q({ERA[34:35], unusedE53}),
           .CLK(clock));

  mux e71(.en(1'b1),
          .sel(_32to33_SEL),
          .d({ERA[32], 1'b0, VA[22], PMA.CCW_CHA[32], {2{CCA[32]}}, VMA.VMA[32], 1'b0}),
          .q(PMA.PA[32]));

  mux e76(.en(1'b1),
          .sel(_32to33_SEL),
          .d({ERA[33], 1'b0, VA[23], PMA.CCW_CHA[33], {2{CCA[33]}}, VMA.VMA[33], 1'b0}),
          .q(PMA.PA[33]));

  mux e74(.en(1'b1),
          .sel(_32to33_SEL),
          .d({ERA[34], 1'b0, MBX.CACHE_TO_MB[34], PMA.CCW_CHA[34],
              {2{CCA[34]}}, VMA.VMA[34], 1'b0}),
          .q(PMA.PA[34]));

  mux e69(.en(1'b1),
          .sel(_32to33_SEL),
          .d({ERA[35], 1'b0, MBX.CACHE_TO_MB[35], PMA.CCW_CHA[35],
              {2{CCA[35]}}, VMA.VMA[35], 1'b0}),
          .q(PMA.PA[35]));

  assign PMA.ADR_PAR = ^PMA.PA[14:33] ^ 1'b1;
  assign PMA._14_26_PAR = ^PMA.PA[14:26];
  assign PMA.PMA[14:35] = PMA.PA[14:35];


  // PMA5 p.88
  bit unusedE73;
  USR4 e73(.S0(1'b0),
           .D({PAGE_REFILL_T4, CSH.EBOX_REQ_GRANT, WRITEBACK_T2, 1'b0}),
           .S3(1'b0),
           .SEL({2{CYC_TYPE_HOLD}}),
           .Q({PMA.PAGE_REFILL_CYC, PMA.CSH_EBOX_CYC, PMA.CSH_WRITEBACK_CYC, unusedE73}),
           .CLK(clock));

  bit [0:2] e77out, e72out, e57out, e62out;
  bit [0:3] e78SR;
  priority_encoder8 e77(.d({1'b0,
                            (CSH.CHAN_REQ_GRANT | PAGE_REFILL_T4) &
                            (CCL.CHAN_EPT | PAGE_REFILL_T4),
                            1'b0,
                            CSH.CHAN_REQ_GRANT,
                            WRITEBACK_T2,
                            CSH.CCA_REQ_GRANT,
                            1'b0,
                            CSH.EBOX_REQ_GRANT}),
                        .any(),
                        .q(e77out));

  priority_encoder8 e72(.d({CSH.EBOX_ERA_GRANT,
                            PAGE_REFILL_5comma7,
                            1'b0,
                            CSH.CHAN_REQ_GRANT,
                            CSH.EBOX_CCA_GRANT,
                            CSH.CCA_REQ_GRANT,
                            CSH.EBOX_REQ_GRANT,
                            1'b1}),
                        .any(),
                        .q(e72out));

  priority_encoder8 e57(.d({CSH.EBOX_ERA_GRANT,
                            PAGE_REFILL_7,
                            PAGE_REFILL_3comma4,
                            CSH.CHAN_REQ_GRANT,
                            CSH.EBOX_CCA_GRANT,
                            CSH.CCA_REQ_GRANT,
                            CSH.EBOX_REQ_GRANT,
                            1'b1}),
                        .any(),
                        .q(e57out));

  priority_encoder8 e62(.d({CSH.EBOX_ERA_GRANT,
                            1'b0,
                            PAGE_REFILL_T4,
                            CSH.CHAN_REQ_GRANT,
                            CSH.EBOX_CCA_GRANT,
                            CSH.CCA_REQ_GRANT,
                            CSH.EBOX_REQ_GRANT,
                            1'b1}),
                        .any(),
                        .q(e62out));

  USR4 e78(.S0(1'b0),
           .D({e77out, e72out[0]}),
           .S3(1'b0),
           .SEL({2{CYC_TYPE_HOLD}}),
           .Q(e78SR),
           .CLK(clock));
  
  USR4 e79(.S0(1'b0),
           .D({e72out[1:2], e57out[0:1]}),
           .S3(1'b0),
           .SEL({2{~CSH.READY_TO_GO}}),
           .Q({_27_SEL[1:2], _28to31_SEL[0:1]}),
           .CLK(clock));
  
  USR4 e63(.S0(1'b0),
           .D({e57out[2], e62out}),
           .S3(1'b0),
           .SEL({2{~CSH.READY_TO_GO}}),
           .Q({_28to31_SEL[2], _32to33_SEL[0:2]}),
           .CLK(clock));

  assign PGRF_UBR_COND = MCL.VMA_USER | VMA_EXEC_PER_PROC;
  assign PAGE_REFILL_5comma7 = CSH.PAGE_REFILL_T4 & (~MCL.VMA_USER & ~VA[18]);
  assign PAGE_REFILL_3comma4 = ~(~MCL.VMA_USER & ~VA[18]) & CSH.PAGE_REFILL_T4;
  assign PAGE_REFILL_T4 = CSH.PAGE_REFILL_T4;
  assign PAGE_REFILL_7 = CSH.PAGE_REFILL_T4 & (~MCL.VMA_USER & ~VA[18]) & ~VMA_EXEC_PER_PROC;
  assign PMA.CYC_TYPE_HOLD = ~CSH.READY_TO_GO & ~MBX.WRITEBACK_T2;
  assign WRITEBACK_T2 = MBX.WRITEBACK_T2;
  assign VMA_EXEC_PER_PROC = VA_19to21eq7 & ~VA[18];

  assign _14to26_SEL[0] = e78SR[0] &
                          (APR.EBOX_CCA | APR.EBOX_ERA | PMA.EBOX_PAGED |
                           ~PMA.CSH_EBOX_CYC | ~PMA.CSH_EBOX_CYC);
  assign _14to26_SEL[1] = e78SR[1] &
                          (APR.EBOX_CCA | APR.EBOX_ERA | PMA.EBOX_PAGED |
                           ~PMA.CSH_EBOX_CYC | ~PMA.CSH_EBOX_CYC);
  assign _14to26_SEL[2] = e78SR[2] &
                          (MCL.VMA_EPT | APR.EBOX_EBR | APR.EBOX_CCA | PMA.EBOX_PAGED |
                           MCL.VMA_UPT | APR.EBOX_UBR | ~PMA.CSH_EBOX_CYC);
  assign _27_SEL[0] = e78SR[3];
  assign UBR_SEL = (MCL.VMA_UPT | APR.EBOX_UBR) & PMA.CSH_EBOX_CYC |
                   PMA.PAGE_REFILL_CYC & PGRF_UBR_COND;
  assign _34to35_SEL[0] = _32to33_SEL[0] & ~PMA.CSH_WRITEBACK_CYC;
  assign _34to35_SEL[1] = _32to33_SEL[1] & PMA.CSH_WRITEBACK_CYC;
  assign _34to35_SEL[2] = _32to33_SEL[2] & ~PMA.CSH_WRITEBACK_CYC;
  assign PMA.EBOX_PAGED = MCL.EBOX_MAY_BE_PAGED | MCL.EBOX_MAY_BE_PAGED & VA_19to21eq7;
endmodule
