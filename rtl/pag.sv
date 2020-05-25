`timescale 1ns/1ns
// M8520 PAG
module pag(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCSH CSH,
           iMBOX MBOX,
           iMCL MCL,
           iPAG PAG,
           iPMA PMA,
           iSHM SHM,
           iVMA VMA
           );

  bit PT_WR, PT_LEFT_EN, PT_RIGHT_EN;
  bit [0:35] ptOut;
  bit [12:19] ptDirOut;
  bit PT_MATCH;

  bit PT_ACCESS_A, PT_ACCESS_B;
  bit PT_PUBLIC_A, PT_PUBLIC_B;
  bit PT_WRITABLE_A, PT_WRITABLE_B;
  bit PT_SOFTWARE_A, PT_SOFTWARE_B;

  bit PAGE_EXEC_PAGED_REF, PAGE_EXEC_REF, PAGE_USER_PAGED_REF, PAGE_UNPAGED_REF;
  bit PAGE_TEST_WRITE, PAGE_TEST_PRIVATE, PAGE_FAIL_A;
  bit PT_DIR_CLR, PT_EN, PT_WR_BOTH_HALVES, PAGED_REF, PAGE_WRITE_OK;
  bit PT_PAR_LEFT, PT_PAR_RIGHT, PT_PAR_ODD, MB_PAR_ODD, PT_WRITABLE;
  bit PF_CODE_2X, MB_PAR, PT_ADR_25_A_IN, PT_ADR_25_B_IN, PT_ADR_25_C_IN;
  bit MB_00to05_PAR_ODD, MB_06to11_PAR_ODD, MB_12to17_PAR_ODD;
  bit MB_18to23_PAR_ODD, MB_24to29_PAR_ODD, MB_30to35_PAR_ODD;


  // PAG1 p.106 (also some from PAG3 for ptDir RAMs and some from PAG5 parity RAMs).
  bit ptDirWEA;
  assign ptDirWEA = CSH.MBOX_PT_DIR_WR | CLK.PT_DIR_WR;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(256), .WIDTH(36), .NBYTES(2))
  pt
    (.clk(PT_WR & (PT_LEFT_EN | PT_RIGHT_EN)),
     .din(PAG.PT_IN),
     .dout(ptOut),
     .addr(PAG.PT_ADR[18:25]),
     .oe(1'b1),
     .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));

  sim_mem
    #(.SIZE(128), .WIDTH(6), .NBYTES(1))
  ptDirA
    (.clk(ptDirWEA),
     .din({MCL.VMA_USER, VMA.VMA[13:17]}),
     .dout(ptDirOut[12:17]),
     .addr(PAG.PT_ADR[18:24]),
     .oe(1'b1),
     .wea(ptDirWEA));

  // Two rightmost bits have unique CE and .addr[6].
  sim_mem
    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
  ptDirB
    (.clk(~PAG.PT_ADR[24] | PT_DIR_CLR),
     .din(PT_DIR_CLR),
     .dout(ptDirOut[18]),
     .addr({PAG.PT_ADR[18:23], 1'b0}),
     .oe(1'b1),
     .wea(ptDirWEA & (~PAG.PT_ADR[24] | PT_DIR_CLR)));

  sim_mem
    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
  ptDirC
    (.clk(PAG.PT_ADR[24] | PT_DIR_CLR),
     .din(PT_DIR_CLR),
     .dout(ptDirOut[19]),
     .addr({PAG.PT_ADR[18:23], 1'b0}),
     .oe(1'b1),
     .wea(ptDirWEA & (PAG.PT_ADR[24] & PT_DIR_CLR)));

  sim_mem
    #(.SIZE(256), .WIDTH(2), .NBYTES(2))
  ptParity
    (.clk(PT_WR),
     .din({(PAG.MB_00to17_PAR | ~CON.KI10_PAGING_MODE) &
           (SHM.AR_PAR_ODD | CON.KI10_PAGING_MODE),
           (PAG.MB_18to35_PAR | ~CON.KI10_PAGING_MODE) &
           (SHM.AR_PAR_ODD | CON.KI10_PAGING_MODE)}),
     .dout({PT_PAR_LEFT, PT_PAR_RIGHT}),
     .addr(PAG.PT_ADR[18:25]),
     .oe(1'b1),
     .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));

`else

  pt_256x36_4byte_mem
    //    #(.SIZE(256), .WIDTH(36), .NBYTES(2))
    pt
      (.addra(PAG.PT_ADR),
       .clka(PT_WR & (PT_LEFT_EN | PT_RIGHT_EN)),
       .dina(PAG.PT_IN),
       .douta(ptOut),
       .wea({{2{PT_WR & PT_LEFT_EN}}, {2{PT_WR & PT_RIGHT_EN}}}));

  ptDir_128x6_mem
    //    #(.SIZE(128), .WIDTH(6), .NBYTES(1))
    ptDirA
      (.clka(ptDirWEA),
       .dina({MCL.VMA_USER, VMA.VMA[13:17]}),
       .douta(ptDirOut[12:17]),
       .addra(PAG.PT_ADR[18:24]),
       .wea(ptDirWEA));

  // Two rightmost bits have unique CE and .addr[6].
  ptDir_128x1_mem
    //    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
    ptDirB
      (.clka(~PAG.PT_ADR[24] | PT_DIR_CLR),
       .dina(PT_DIR_CLR),
       .douta(ptDirOut[18]),
       .addra({PAG.PT_ADR[18:23], 1'b0}),
       .wea(ptDirWEA & (~PAG.PT_ADR[24] | PT_DIR_CLR)));

  ptDir_128x1_mem
    //    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
    ptDirC
      (.clka(~PAG.PT_ADR[24] | PT_DIR_CLR),
       .dina(PT_DIR_CLR),
       .douta(ptDirOut[19]),
       .addra({PAG.PT_ADR[18:23], 1'b0}),
       .wea(ptDirWEA & (PAG.PT_ADR[24] | PT_DIR_CLR)));

  ptDir_256x2_mem
    //    #(.SIZE(256), .WIDTH(2), .NBYTES(2))
    ptParity
      (.clka(PT_WR),
       .dina({(PAG.MB_00to17_PAR | ~CON.KI10_PAGING_MODE) &
              (SHM.AR_PAR_ODD | CON.KI10_PAGING_MODE),
              (PAG.MB_18to35_PAR | ~CON.KI10_PAGING_MODE) &
              (SHM.AR_PAR_ODD | CON.KI10_PAGING_MODE)}),
       .douta({PT_PAR_LEFT, PT_PAR_RIGHT}),
       .addra(PAG.PT_ADR[18:25]),
       .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));
`endif

  assign PT_ACCESS_A = ptOut[0];
  assign PT_ACCESS_B = ptOut[18];
  assign PAG.PT_ACCESS = PT_MATCH & (PT_ACCESS_A | PT_ACCESS_B);

  assign PT_PUBLIC_A = ptOut[1];
  assign PT_PUBLIC_B = ptOut[19];
  assign PAG.PT_PUBLIC = PT_MATCH & (PT_PUBLIC_A | PT_PUBLIC_B);

  assign PT_WRITABLE_A = ptOut[2];
  assign PT_WRITABLE_B = ptOut[20];
  assign PAG.PT_WRITABLE = PT_MATCH & (PT_WRITABLE_A | PT_WRITABLE_B);

  assign PT_SOFTWARE_A = ptOut[3];
  assign PT_SOFTWARE_B = ptOut[21];
  assign PAG.PT_SOFTWARE = PT_MATCH & (PT_SOFTWARE_A | PT_SOFTWARE_B);

  assign PAG.PT_CACHE = ptOut[4] | ptOut[22];


  // PAG2 p.107
  always_comb for (int k = 14; k <= 26; ++k)
    PAG.PT[k] = (PT_EN | PMA.PA[k]) & (ptOut[k-9] | ptOut[k+9] | ~PT_EN);


  // PAG3 p.108
  assign PAG.PT_ADR[18] = VMA.VMA[18];
  assign PAG.PT_ADR[19] = MCL.VMA_EXEC ^ VMA.VMA[19];
  assign PAG.PT_ADR[20] = VMA.VMA[17] ^ VMA.VMA[20];
  assign PAG.PT_ADR[21:23] = VMA.VMA[21:23];

  assign PAG.PT_ADR[24] = (MBOX.SEL_2 | ~CSH.PGRF_CYC) & (VMA.VMA[24] | CSH.PGRF_CYC);

  assign PT_ADR_25_A_IN = VMA.VMA[25] & ~PT_WR_BOTH_HALVES;
  assign PT_ADR_25_B_IN = MBOX.SEL_1 & CSH.PGRF_CYC;
  assign PT_ADR_25_C_IN = APR.WR_PT_SEL_0 & APR.WR_PT_SEL_1;

  assign PAG.PT_ADR[26] = VMA.VMA[26];
  assign PT_WR_BOTH_HALVES = CSH.PGRF_CYC | APR.WR_PT_SEL_0;
  assign PT_DIR_CLR = ~APR.WR_PT_SEL_0 & APR.WR_PT_SEL_1 |
                 CSH.PAGE_FAIL_HOLD & CON.KI10_PAGING_MODE;

  assign PT_LEFT_EN = ~PAG.PT_ADR[26] | PT_WR_BOTH_HALVES;
  assign PT_RIGHT_EN = PAG.PT_ADR[26] | PT_WR_BOTH_HALVES;

  assign PT_WR = CLK.PT_WR | CSH.PAGE_REFILL_T12;
  assign PT_EN = CSH.EBOX_CYC & PMA.EBOX_PAGED;


  // PAG4 p.109
  bit e67q14;
  bit e79q15;
  bit e85q6;
  assign PAGE_EXEC_PAGED_REF = ~MCL.PAGE_ILL_ENTRY & PAGE_EXEC_REF & PMA.EBOX_PAGED;
  assign PAGE_EXEC_REF = ~MCL.VMA_USER & ~MCL.PAGE_UEBR_REF;
  assign PAGE_USER_PAGED_REF = ~MCL.PAGE_UEBR_REF & ~MCL.PAGE_ILL_ENTRY & ~PAGE_EXEC_REF;
  assign PAGE_UNPAGED_REF = ~MCL.PAGE_ILL_ENTRY & ~PMA.EBOX_PAGED;
  assign e67q14 = ~PAGE_TEST_PRIVATE & PAGE_USER_PAGED_REF |
                  PMA.EBOX_PAGED & ~PAGE_TEST_PRIVATE & PAGE_EXEC_REF;
  assign PAGE_TEST_WRITE = ~MCL.PAGE_ILL_ENTRY &
                           (PAGE_EXEC_PAGED_REF | PAGE_USER_PAGED_REF | e67q14) &
                           (PT_PUBLIC_A | PT_PUBLIC_B | e67q14) &
                           PAG.PT_ACCESS;
  assign PAG.PF_EBOX_HANDLE = ((~PT_MATCH | ~PAG.PT_ACCESS & PT_PAR_ODD) & PAGED_REF |
                               ~PAGE_WRITE_OK & PAGE_TEST_WRITE & PT_PAR_ODD) &
                              ~CON.KI10_PAGING_MODE;
  assign PAGE_TEST_PRIVATE = MCL.PAGE_TEST_PRIVATE;
  assign PAGED_REF = PAGE_USER_PAGED_REF | PAGE_EXEC_PAGED_REF;
  assign PAG.PAGE_REFILL = PAGED_REF & ~PT_MATCH & ~PAGE_FAIL_A;

  assign PAGE_WRITE_OK = PT_WRITABLE | ~MCL.VMA_WRITE;
  assign PAG.PAGE_OK = MCL.PAGE_UEBR_REF & ~MCL.PAGE_ILL_ENTRY |
                       PAGE_WRITE_OK & PAGE_TEST_WRITE & PT_PAR_ODD |
                       PAG.PT_ACCESS & ~MCL.VMA_WRITE & PAGE_EXEC_PAGED_REF & PT_PAR_ODD |
                       PAGE_EXEC_REF & PAGE_UNPAGED_REF & ~PAGE_TEST_PRIVATE;
  assign PAGE_FAIL_A = (MCL.PAGE_ILL_ENTRY |
                        PAGE_TEST_PRIVATE & PAGE_UNPAGED_REF & PAGE_EXEC_REF) |
                       ~CON.KI10_PAGING_MODE & ~PT_MATCH & PAGED_REF |
                       CSH.PAGE_REFILL_ERROR & PAGED_REF |
                       PAGED_REF & ~PT_PAR_ODD & PT_MATCH;
  assign e79q15 = MCL.VMA_WRITE & PAGE_EXEC_PAGED_REF & PAG.PT_ACCESS |
                  PAG.PT_ACCESS & PAGE_USER_PAGED_REF;
  assign PAG.PAGE_FAIL = PAGED_REF & ~PAG.PT_ACCESS & PT_MATCH |
                         PAGE_FAIL_A |
                         ~PAGE_WRITE_OK & PAGE_TEST_WRITE |
                         PAGE_TEST_PRIVATE & ~PAG.PT_PUBLIC &
                         e79q15;
  assign PF_CODE_2X = PAGE_TEST_PRIVATE & ~PAG.PT_PUBLIC & e79q15 |
                      PAGE_FAIL_A;
  assign e85q6 = PAGED_REF & ~PT_PAR_ODD & PT_MATCH;
  assign PAG.PF_HOLD_01_IN = PF_CODE_2X;
  assign PAG.PF_HOLD_02_IN = ~PF_CODE_2X & PAG.PT_ACCESS;
  assign PAG.PF_HOLD_03_IN = (MCL.VMA_ADR_ERR | PAG.PT_WRITABLE | e85q6) &
                             (MCL.VMA_ADR_ERR | ~PF_CODE_2X | e85q6);
  assign PAG.PF_HOLD_04_IN = (PAG.PT_SOFTWARE | CSH.PAGE_REFILL_ERROR | MCL.PAGE_ADDRESS_COND) &
                             (CSH.PAGE_REFILL_ERROR | MCL.PAGE_ADDRESS_COND | ~PF_CODE_2X);
  assign PAG.PF_HOLD_05_IN = MCL.VMA_WRITE & ~CSH.PAGE_REFILL_ERROR |
                             PF_CODE_2X & ~CSH.PAGE_REFILL_ERROR;


  // PAG5 p.110
  assign PAG.MB_18to35_PAR = MB_00to05_PAR_ODD ^
                             MB_06to11_PAR_ODD ^
                             MB_12to17_PAR_ODD ^
                             MB_PAR;
  assign PAG.MB_00to17_PAR = MB_18to23_PAR_ODD ^
                             MB_24to29_PAR_ODD ^
                             MB_30to35_PAR_ODD ^
                             MB_PAR;
  assign MB_PAR_ODD = MB_00to05_PAR_ODD ^
                      MB_06to11_PAR_ODD ^
                      MB_12to17_PAR_ODD ^
                      MB_18to23_PAR_ODD ^
                      MB_24to29_PAR_ODD ^
                      MB_30to35_PAR_ODD ^
                      MB_PAR;

  assign PT_PAR_ODD = ^{PAG.PT_ACCESS, PAG.PT_PUBLIC, PAG.PT_WRITABLE, PAG.PT_SOFTWARE,
                        PAG.PT_CACHE, PAG.PT[14:26], PT_PAR_LEFT, PT_PAR_RIGHT};

  assign PAG.PT_ADR[25] = PT_ADR_25_A_IN | PT_ADR_25_B_IN | PT_ADR_25_C_IN;
endmodule // pag
