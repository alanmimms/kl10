`timescale 1ns/1ns
// M8520 PAG
module pag(iAPR APR,
           iCSH CSH,
           iPAG PAG,
           iPMA PMA,
           iSHM SHM,
           iMBOX MBOX
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
   .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));

  sim_mem
    #(.SIZE(128), .WIDTH(6), .NBYTES(1))
  ptDirA
    (.clk(ptDirWEA),
    .din({MCL.VMA_USER, VMA.VMA[13:17]}),
    .dout(ptDirOut[12:17]),
    .addr(PAG.PT_ADR[18:24]),
    .wea(ptDirWEA));

  // Two rightmost bits have unique CE
  // XXX FIXME
  sim_mem
    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
  ptDirB
    (.clk(~PAG.PT_ADR[24] | PT_DIR_CLR),
    .din(PT_DIR_CLR),
    .dout(ptDirOut[18]),
    .addr({PAG.PT_ADR[18:23], 1'b0}),
    .wea(ptDirWEA));

  sim_mem
    #(.SIZE(128), .WIDTH(1), .NBYTES(1))
  ptDirC
    (.clk(PAG.PT_ADR[24] | PT_DIR_CLR),
    .din(PT_DIR_CLR),
    .dout(ptDirOut[19]),
    .addr({PAG.PT_ADR[18:23], 1'b0}),
    .wea(ptDirWEA));

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
    .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));
`else
  pt_mem pt(.addra(PAG.PT_ADR),
  .clka(PT_WR & (PT_LEFT_EN | PT_RIGHT_EN)),
  .dina(PAG.PT_IN),
  .douta(ptOut),
  .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));

  // XXX FIXME

/*  "this is not complete since we need to split the separate CE bits off
  from the main block of RAM."
  */

  ptDir_mem ptDirA(.addra(PAG.PT_ADR),
    .clka(PT_WR & (PT_LEFT_EN | PT_RIGHT_EN)),
    .dina(PAG.PT_IN),
    .douta(ptOut),
    .wea({PT_WR & PT_LEFT_EN, PT_WR & PT_RIGHT_EN}));
`endif

  always_comb begin
    PT_ACCESS_A = ptOut[0];
    PT_ACCESS_B = ptOut[18];
    PAG.PT_ACCESS = PT_MATCH & (PT_ACCESS_A | PT_ACCESS_B);

    PT_PUBLIC_A = ptOut[1];
    PT_PUBLIC_B = ptOut[19];
    PAG.PT_PUBLIC = PT_MATCH & (PT_PUBLIC_A | PT_PUBLIC_B);

    PT_WRITABLE_A = ptOut[2];
    PT_WRITABLE_B = ptOut[20];
    PAG.PT_WRITABLE = PT_MATCH & (PT_WRITABLE_A | PT_WRITABLE_B);

    PT_SOFTWARE_A = ptOut[3];
    PT_SOFTWARE_B = ptOut[21];
    PAG.PT_SOFTWARE = PT_MATCH & (PT_SOFTWARE_A | PT_SOFTWARE_B);

    PAG.PT_CACHE = ptOut[4] | ptOut[22];
  end


    // PAG2 p.107
  always_comb begin
    for (int k = 14; k <= 26; ++k) begin
      PAG.PT[k] = (PT_EN | PMA.PA[k]) & (ptOut[k-9] | ptOut[k+9] | ~PT_EN);
    end
  end


  // PAG3 p.108
  always_comb begin
    PAG.PT_ADR[18] = VMA.VMA[18];
    PAG.PT_ADR[19] = MCL.VMA_EXEC ^ VMA.VMA[19];
    PAG.PT_ADR[20] = VMA.VMA[17] ^ VMA.VMA[20];
    PAG.PT_ADR[21:23] = VMA.VMA[21:23];

    PAG.PT_ADR[24] = (MBOX.SEL_2 | ~CSH.PGRF_CYC) & (VMA.VMA[24] | CSH.PGRF_CYC);

    PT_ADR_25_A_IN = VMA.VMA[25] & ~PT_WR_BOTH_HALVES;
    PT_ADR_25_B_IN = MBOX.SEL_1 & CSH.PGRF_CYC;
    PT_ADR_25_C_IN = APR.WR_PT_SEL_0 & APR.WR_PT_SEL_1;

    PAG.PT_ADR[26] = VMA.VMA[26];
    PT_WR_BOTH_HALVES = CSH.PGRF_CYC | APR.WR_PT_SEL_0;
    PT_DIR_CLR = ~APR.WR_PT_SEL_0 & APR.WR_PT_SEL_1 |
                 CSH.PAGE_FAIL_HOLD & CON.KI10_PAGING_MODE;

    PT_LEFT_EN = ~PAG.PT_ADR[26] | PT_WR_BOTH_HALVES;
    PT_RIGHT_EN = PAG.PT_ADR[26] | PT_WR_BOTH_HALVES;

    PT_WR = CLK.PT_WR | CSH.PAGE_REFILL_T12;
    PT_EN = CSH.EBOX_CYC & PMA.EBOX_PAGED;
  end


  // PAG4 p.109
  bit e67q14;
  bit e79q15;
  bit e85q6;
  always_comb begin
    PAGE_EXEC_PAGED_REF = ~MCL.PAGE_ILL_ENTRY & PAGE_EXEC_REF & PMA.EBOX_PAGED;
    PAGE_EXEC_REF = ~MCL.VMA_USER & ~MCL.PAGE_UEBR_REF;
    PAGE_USER_PAGED_REF = ~MCL.PAGE_UEBR_REF & ~MCL.PAGE_ILL_ENTRY & ~PAGE_EXEC_REF;
    PAGE_UNPAGED_REF = ~MCL.PAGE_ILL_ENTRY & ~PMA.EBOX_PAGED;
    e67q14 = ~PAGE_TEST_PRIVATE & PAGE_USER_PAGED_REF |
             PMA.EBOX_PAGED & ~PAGE_TEST_PRIVATE & PAGE_EXEC_REF;
    PAGE_TEST_WRITE = ~MCL.PAGE_ILL_ENTRY &
                      (PAGE_EXEC_PAGED_REF | PAGE_USER_PAGED_REF | e67q14) &
                      (PT_PUBLIC_A | PT_PUBLIC_B | e67q14) &
                      PAG.PT_ACCESS;
    PAG.PF_EBOX_HANDLE = ((~PT_MATCH | ~PAG.PT_ACCESS & PT_PAR_ODD) & PAGED_REF |
                         ~PAGE_WRITE_OK & PAGE_TEST_WRITE & PT_PAR_ODD) &
                         ~CON.KI10_PAGING_MODE;
    PAGE_TEST_PRIVATE = MCL.PAGE_TEST_PRIVATE;
    PAGED_REF = PAGE_USER_PAGED_REF | PAGE_EXEC_PAGED_REF;
    PAG.PAGE_REFILL = PAGED_REF & ~PT_MATCH & ~PAGE_FAIL_A;

    PAGE_WRITE_OK = PT_WRITABLE | ~MCL.VMA_WRITE;
    PAG.PAGE_OK = MCL.PAGE_UEBR_REF & ~MCL.PAGE_ILL_ENTRY |
                  PAGE_WRITE_OK & PAGE_TEST_WRITE & PT_PAR_ODD |
                  PAG.PT_ACCESS & ~MCL.VMA_WRITE & PAGE_EXEC_PAGED_REF & PT_PAR_ODD |
                  PAGE_EXEC_REF & PAGE_UNPAGED_REF & ~PAGE_TEST_PRIVATE;
    PAGE_FAIL_A = (MCL.PAGE_ILL_ENTRY |
                  PAGE_TEST_PRIVATE & PAGE_UNPAGED_REF & PAGE_EXEC_REF) |
                  ~CON.KI10_PAGING_MODE & ~PT_MATCH & PAGED_REF |
                  CSH.PAGE_REFILL_ERROR & PAGED_REF |
                  PAGED_REF & ~PT_PAR_ODD & PT_MATCH;
    e79q15 = MCL.VMA_WRITE & PAGE_EXEC_PAGED_REF & PAG.PT_ACCESS |
             PAG.PT_ACCESS & PAGE_USER_PAGED_REF;
    PAG.PAGE_FAIL = PAGED_REF & ~PAG.PT_ACCESS & PT_MATCH |
                    PAGE_FAIL_A |
                    ~PAGE_WRITE_OK & PAGE_TEST_WRITE |
                    PAGE_TEST_PRIVATE & ~PAG.PT_PUBLIC &
                    e79q15;
    PF_CODE_2X = PAGE_TEST_PRIVATE & ~PAG.PT_PUBLIC & e79q15 |
                 PAGE_FAIL_A;
    e85q6 = PAGED_REF & ~PT_PAR_ODD & PT_MATCH;
    PAG.PF_HOLD_01_IN = PF_CODE_2X;
    PAG.PF_HOLD_02_IN = ~PF_CODE_2X & PAG.PT_ACCESS;
    PAG.PF_HOLD_03_IN = (MCL.VMA_ADR_ERR | PAG.PT_WRITABLE | e85q6) &
                        (MCL.VMA_ADR_ERR | ~PF_CODE_2X | e85q6);
    PAG.PF_HOLD_04_IN = (PAG.PT_SOFTWARE | CSH.PAGE_REFILL_ERROR | MCL.PAGE_ADDRESS_COND) &
                        (CSH.PAGE_REFILL_ERROR | MCL.PAGE_ADDRESS_COND | ~PF_CODE_2X);
    PAG.PF_HOLD_05_IN = MCL.VMA_WRITE & ~CSH.PAGE_REFILL_ERROR |
                        PF_CODE_2X & ~CSH.PAGE_REFILL_ERROR;
  end


  // PAG5 p.110
  always_comb begin
    PAG.MB_18to35_PAR = MB_00to05_PAR_ODD ^
                        MB_06to11_PAR_ODD ^
                        MB_12to17_PAR_ODD ^
                        MB_PAR;
    PAG.MB_00to17_PAR = MB_18to23_PAR_ODD ^
                        MB_24to29_PAR_ODD ^
                        MB_30to35_PAR_ODD ^
                        MB_PAR;
    MB_PAR_ODD = MB_00to05_PAR_ODD ^
                 MB_06to11_PAR_ODD ^
                 MB_12to17_PAR_ODD ^
                 MB_18to23_PAR_ODD ^
                 MB_24to29_PAR_ODD ^
                 MB_30to35_PAR_ODD ^
                 MB_PAR;

    PT_PAR_ODD = ^{PAG.PT_ACCESS, PAG.PT_PUBLIC, PAG.PT_WRITABLE, PAG.PT_SOFTWARE,
                   PAG.PT_CACHE, PAG.PT[14:26], PT_PAR_LEFT, PT_PAR_RIGHT};

    PAG.PT_ADR[25] = PT_ADR_25_A_IN | PT_ADR_25_B_IN | PT_ADR_25_C_IN;
  end
endmodule // pag
