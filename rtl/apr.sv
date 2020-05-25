`timescale 1ns/1ns
`include "ebox.svh"

// M8545 APR
module apr(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCTL CTL,
           iEBUS.mod EBUS,
           iEDP EDP,
           iIR IR,
           iMBOX MBOX,
           iMCL MCL,
           iPI PIC,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,

           input bit PWR_WARN
           );
  bit clk;
  bit RESET;
  bit [4:6] DIAG, DS;
  bit READ_110_117;
  bit [6:7] magic;

  assign clk = CLK.APR;
  assign RESET = CLK.MR_RESET;
  assign DIAG = CTL.DIAG[4:6];
  assign DS = ~DIAG & CTL.DIAG_READ_FUNC_11x;
  assign READ_110_117 = CTL.DIAG_READ_FUNC_11x;

  bit SBUS_ERR_IN, SBUS_ERR_IN_EN;
  bit NXM_ERR_INT_EN, NXM_ERR_EN_IN;
  bit SBUS_ERR_INT_EN, SBUS_ERR_EN_IN, SBUS_ERR_EN;
  bit IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN;
  bit MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN;
  bit MB_PAR_ERR_EN, MB_PAR_ERR_IN;
  bit IO_PF_ERR, IO_PF_ERR_IN, IO_PF_ERR_EN;
  bit NXM_ERR, NXM_ERR_IN, NXM_ERR_EN;
  bit SWEEP_BUSY_EN, SWEEP_BUSY;
  bit C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN, C_DIR_P_ERR_EN, C_DIR_P_ERR_IN;
  bit S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN, S_ADR_P_ERR_EN, S_ADR_P_ERR_IN;
  bit PWR_FAIL_INT_EN, PWR_FAIL_EN_IN;
  bit PWR_FAIL, PWR_FAIL_IN;
  bit SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN;
  bit SWEEP_DONE, SWEEP_DONE_IN, SWEEP_DONE_EN;
  bit F02_EN, REG_FUNC_EN;

// I wanted to use nested modules for this but they broke xelab (SIGSEGV)
`define APRInt(clk, m, e, i) \
  assign i = CON.SEL_EN & EBUS.data[m] | i & ~RESET & CON.SEL_DIS & EBUS.data[m]; \
  always_ff @(posedge clk) e <= i;

`define APREvent(clk, m, o, e, i) \
  assign i = CON.SEL_SET & EBUS.data[m] | ~CON.SEL_CLR & e & ~RESET | e & ~EBUS.data[m] & ~RESET | o; \
  always_ff @(posedge clk) e <= i;

   // APR1 p.382
  `APRInt(clk, 6, SBUS_ERR_INT_EN, SBUS_ERR_EN_IN);
  `APREvent(clk, 6, MBOX.SBUS_ERR, SBUS_ERR_EN, SBUS_ERR_IN);

  `APRInt(clk, 7, NXM_ERR_INT_EN, NXM_ERR_EN_IN);
  `APREvent(clk, 7, MBOX.NXM_ERR, NXM_ERR_EN, NXM_ERR_IN);

  `APRInt(clk, 8, IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN);
  `APREvent(clk, 8, APR.SET_IO_PF_ERR, IO_PF_ERR_EN, IO_PF_ERR_IN);

  `APRInt(clk, 9, MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN);
  `APREvent(clk, 9, MBOX.MB_PAR_ERR, MB_PAR_ERR_EN, MB_PAR_ERR_IN);

  // APR2 p.383
  `APRInt(clk, 10, C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN);
  `APREvent(clk, 10, MBOX.CSH_ADR_PAR_ERR, C_DIR_P_ERR_EN, C_DIR_P_ERR_IN);

  `APRInt(clk, 11, S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN);
  `APREvent(clk, 11, MBOX.MBOX_ADR_PAR_ERR, S_ADR_P_ERR_EN, S_ADR_P_ERR_IN);

  `APRInt(clk, 12, PWR_FAIL_INT_EN, PWR_FAIL_EN_IN);
  `APREvent(clk, 12, PWR_WARN, PWR_FAIL, PWR_FAIL_IN);

  `APRInt(clk, 13, SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN);
  `APREvent(clk, 13,
                   ~APR.SWEEP_BUSY & APR.SWEEP_BUSY,
                   SWEEP_DONE_EN, SWEEP_DONE_IN);

  assign APR.APR_INTERRUPT = APR.SBUS_ERR & SBUS_ERR_INT_EN |
                             APR.NXM_ERR & NXM_ERR_INT_EN |
                             IO_PF_ERR & IO_PF_ERR_INT_EN |
                             APR.MB_PAR_ERR & MB_PAR_ERR_INT_EN |
                             APR.C_DIR_P_ERR & C_DIR_P_ERR_INT_EN |
                             APR.S_ADR_P_ERR & S_ADR_P_ERR_INT_EN |
                             PWR_FAIL & PWR_FAIL_INT_EN |
                             SWEEP_DONE & SWEEP_DONE_INT_EN;
  assign APR.WR_BAD_ADR_PAR = ~APR.S_ADR_P_ERR &
                              CON.WR_EVEN_PAR_ADR &
                              ~MBOX.MBOX_ADR_PAR_ERR;

  always_ff @(posedge clk) APR.ANY_EBOX_ERR_FLG <= NXM_ERR_IN | MB_PAR_ERR_IN | S_ADR_P_ERR_IN;

  // APR3 p.384
  bit [0:3] e14SR;
  always_ff @(posedge clk) if (CON.COND_EBUS_CTL | RESET) e14SR <= {CRAM.MAGIC[0:1], CRAM.MAGIC[3:4]};

  bit [0:2] e2Latch;
  always_latch if (e14SR[3]) e2Latch <= CRAM.MAGIC[5] ?
                                        {CRAM.MAGIC[6], ~APR.AC[9], F02_EN} :
                                        {CRAM.MAGIC[6:8]};

  assign APR.EBUS_DISABLE_CS = e14SR[3] & e2Latch[0];
  assign APR.EBUS_F01 = e14SR[3] & e2Latch[1];
  assign APR.EBOX_SEND_F02 = e14SR[3] & e2Latch[2];
  assign APR.CONI_OR_DATAI = ~APR.EBOX_SEND_F02;
  assign APR.CONO_OR_DATAO = e14SR[3] & ~APR.CONI_OR_DATAI;

  bit fm36XORin;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(128), .WIDTH(2), .NBYTES(1))
  fm
    (.clk(clk),
     .din({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
     .dout({APR.FM_EXTENDED, fm36XORin}),
     .addr({APR.FM_BLOCK, APR.FM_ADR}),
     .oe(1'b1),
     .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // ??? WTF ???
`else
  fm_ext_mem fm_ext(.addra({APR.FM_BLOCK, APR.FM_ADR}),
                    .clka(clk),
                    .dina({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
                    .douta({APR.FM_EXTENDED, fm36XORin}),
                    .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // WTF?
`endif

  assign APR.FM_BIT_36 = fm36XORin ^ APR.FM_EXTENDED;
  assign APR.FM_ODD_PARITY = |CRAM.ADB | EDP.FM_PARITY;

  always_ff @(posedge clk) if (CON.DATAO_APR) begin
    {APR.FETCH_COMP,
     APR.READ_COMP,
     APR.WRITE_COMP,
     APR.USER_COMP} <= EBUS.data[9:12];
  end


  // APR4 p.385
  assign APR.AC = IR.AC;
  
  bit [9:12] ACplus1, ACplus2, ACplus3, ACplusMAGIC;

  mux e49(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.AC[9], ACplus1[9], SHM.XR[10], VMA.VMA[32],
              ACplus2[9], ACplus3[9], ACplusMAGIC[9], CRAM.MAGIC[5]}),
          .q(APR.FM_ADR[0]));

  mux e54(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.AC[10], ACplus1[10], SHM.XR[4], VMA.VMA[33],
              ACplus2[10], ACplus3[10], ACplusMAGIC[10], CRAM.MAGIC[6]}),
          .q(APR.FM_ADR[1]));

  mux e65(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.AC[11], ACplus1[11], SHM.XR[2], VMA.VMA[34],
              ACplus2[11], ACplus3[11], ACplusMAGIC[11], CRAM.MAGIC[7]}),
          .q(APR.FM_ADR[2]));

  mux e59(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.AC[12], ACplus1[12], SHM.XR[1], VMA.VMA[35],
              ACplus2[12], ACplus3[12], ACplusMAGIC[12], CRAM.MAGIC[8]}),
          .q(APR.FM_ADR[3]));

  bit AC7, AC67, AC37, AC567, AC01;
  assign AC67 = APR.AC[10] ^ APR.AC[11];
  assign AC37 = APR.AC[11] ^ APR.AC[12];
  assign AC7 = ~(~AC67 | ~AC37);
  assign AC567 = APR.AC[10] ^ ~ACplus3[10];
  assign AC01 = ~APR.AC[10] & ~APR.AC[11];
  assign F02_EN = AC567 | AC01;

  assign ACplus1[9] = APR.AC[9] ^ AC7;
  assign ACplus1[10] = APR.AC[10] ^ AC37;
  assign ACplus1[11] = APR.AC[11] ^ APR.AC[12];
  assign ACplus1[12] = ~APR.AC[12];

  assign ACplus2[9] = APR.AC[9] ^ AC67;
  assign ACplus2[10] = APR.AC[10] & APR.AC[11];
  assign ACplus2[11] = ~APR.AC[11];
  assign ACplus2[12] = APR.AC[12];

  assign ACplus3[9] = APR.AC[9] ^ AC567;
  assign ACplus3[10] = ACplus1[10] ^ ACplus1[11];
  assign ACplus3[11] = ACplus1[11];
  assign ACplus3[12] = ~APR.AC[12];

  mc10181 e61(.S(CRAM.MAGIC[1:4]),
              .M(CRAM.MAGIC[0]),
              .CIN(1'b0),
              .A(APR.AC),
              .B(CRAM.MAGIC[5:8]),
              .COUT(),
              .CG(), .CP(),
              .F(ACplusMAGIC));


  // APR5 p.386
  bit ignoredE67;
  mux4x2 e67(.SEL(MCL.XR_PREVIOUS),
             .D0({1'bX, APR.CURRENT_BLOCK}),
             .D1({1'bX, APR.PREV_BLOCK}),
             .B({ignoredE67, APR.XR_BLOCK}));

  mux e73(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.CURRENT_BLOCK[0], APR.CURRENT_BLOCK[0], APR.XR_BLOCK[0],
              APR.VMA_BLOCK[0], APR.CURRENT_BLOCK[0], APR.CURRENT_BLOCK[0],
              APR.CURRENT_BLOCK[0], CRAM.MAGIC[2]}),
          .q(APR.FM_BLOCK[0]));

  mux e72(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.CURRENT_BLOCK[1], APR.CURRENT_BLOCK[1], APR.XR_BLOCK[1],
              APR.VMA_BLOCK[1], APR.CURRENT_BLOCK[1], APR.CURRENT_BLOCK[1],
              APR.CURRENT_BLOCK[1], CRAM.MAGIC[3]}),
          .q(APR.FM_BLOCK[1]));

  mux e71(.en(1'b1),
          .sel(CRAM.FMADR),
          .d({APR.CURRENT_BLOCK[2], APR.CURRENT_BLOCK[2], APR.XR_BLOCK[2],
              APR.VMA_BLOCK[2], APR.CURRENT_BLOCK[2], APR.CURRENT_BLOCK[2],
              APR.CURRENT_BLOCK[2], CRAM.MAGIC[4]}),
          .q(APR.FM_BLOCK[2]));

  bit ignoreE68, ignoreE63;
  USR4 e68(.S0(1'bX),
           .D({EBUS.data[6:8], 1'bX}),
           .S3(1'bX),
           .CLK(clk),
           .SEL({2{CON.LOAD_AC_BLOCKS}}),
           .Q({APR.CURRENT_BLOCK, ignoreE68}));

  USR4 e63(.S0(1'bX),
           .D({EBUS.data[9:11], 1'bX}),
           .S3(1'bX),
           .CLK(clk),
           .SEL({2{CON.LOAD_AC_BLOCKS}}),
           .Q({APR.PREV_BLOCK, ignoreE63}));

  USR4  e8(.S0(1'bX),
           .D({CRAM.MAGIC[3], CRAM.MAGIC[6:8]}),
           .S3(1'bX),
           .SEL({2{CON.COND_MBOX_CTL | RESET}}),
           .Q({APR.MBOX_CTL[3], APR.MBOX_CTL[6],
               APR.WR_PT_SEL_0, APR.WR_PT_SEL_1}),
           .CLK(clk));

  bit [0:3] e24out;
  mux4x2 e24(.SEL(MCL.VMA_PREV_EN),
             .D0({1'b0, APR.CURRENT_BLOCK}),
             .D1({1'b0, APR.PREV_BLOCK}),
             .B(e24out));

  bit ignoreE29;
  USR4 e29(.S0(1'bX),
           .D(e24out),
           .S3(1'bX),
           .SEL({2{MCL.LOAD_VMA_CONTEXT}}),
           .CLK(clk),
           .Q({ignoreE29, APR.VMA_BLOCK}));

  assign APR.SET_PAGE_FAIL = CRAM.MAGIC[1] & CON.COND_MBOX_CTL;
  assign APR.SET_IO_PF_ERR = CRAM.MAGIC[2] & CON.COND_MBOX_CTL;
  assign APR.PT_DIR_WR = CRAM.MAGIC[4] & CON.COND_MBOX_CTL;
  assign APR.PT_WR = CRAM.MAGIC[5] & CON.COND_MBOX_CTL;


  // APR6 p.387
  mux2x4 e37(.EN(~DS[4]),
             .SEL(DS[5:6]),
             .D0({SWEEP_BUSY_EN, 3'b000}),
             .D1({SBUS_ERR_IN, APR.CURRENT_BLOCK[0], SBUS_ERR_EN_IN, 1'b0}),
             .B0(APR.EBUSdriver.data[1]),
             .B1(APR.EBUSdriver.data[6]));

  mux e13(.en(READ_110_117),
          .sel(DS),
          .d({NXM_ERR, APR.CURRENT_BLOCK[1], NXM_ERR_EN_IN, 1'b0,
              APR.MBOX_CTL[3], APR.MBOX_CTL[6],
              APR.WR_PT_SEL_0, APR.WR_PT_SEL_1}),
          .q(APR.EBUSdriver.data[7]));

  mux e19(.en(READ_110_117),
          .sel(DS),
          .d({IO_PF_ERR_IN, APR.CURRENT_BLOCK[2], IO_PF_ERR_EN_IN, 1'b0,
              APR.FM_BLOCK[0], ~APR.SET_PAGE_FAIL, ~APR.PT_DIR_WR, ~APR.PT_WR}),
          .q(APR.EBUSdriver.data[8]));

  mux e18(.en(READ_110_117),
          .sel(DS),
          .d({MB_PAR_ERR_IN, APR.PREV_BLOCK[0], MB_PAR_ERR_EN_IN,
              APR.FETCH_COMP, APR.FM_BLOCK[1], APR.EBUS_RETURN, ~APR.EBUS_REQ,
              APR.EBUS_DEMAND}),
          .q(APR.EBUSdriver.data[9]));

  mux e17(.en(READ_110_117),
          .sel(DS),
          .d({C_DIR_P_ERR_IN, APR.PREV_BLOCK[1], C_DIR_P_ERR_EN_IN,
              APR.READ_COMP, APR.FM_BLOCK[2], APR.EBUS_DISABLE_CS,
              APR.EBUS_F01, APR.EBOX_SEND_F02}),
          .q(APR.EBUSdriver.data[10]));

  mux e22(.en(READ_110_117),
          .sel(DS),
          .d({APR.S_ADR_P_ERR, APR.PREV_BLOCK[2], S_ADR_P_ERR_EN_IN,
              APR.WRITE_COMP, APR.FM_ADR[0], ~APR.WR_BAD_ADR_PAR,
              APR.ANY_EBOX_ERR_FLG, ~CON.FM_WRITE_PAR}),
          .q(APR.EBUSdriver.data[11]));

  mux e21(.en(READ_110_117),
          .sel(DS),
          .d({PWR_FAIL_IN, SHM.AR_EXTENDED, PWR_FAIL_EN_IN, APR.USER_COMP,
              APR.FM_ADR[1], APR.EBOX_CCA, APR.EBOX_UBR, APR.EBOX_EBR}),
          .q(APR.EBUSdriver.data[12]));

  mux e11(.en(READ_110_117),
          .sel(DS),
          .d({SWEEP_DONE_IN, APR.FM_EXTENDED, SWEEP_DONE_EN, 1'b0,
              APR.FM_ADR[2], APR.EBOX_ERA, APR.EN_REFILL_RAM_WR, APR.EBOX_SPARE}),
          .q(APR.EBUSdriver.data[13]));

  mux2x4 e34(.EN(~DS[5]),
             .SEL({DS[4], DS[6]}),
             .D0({APR.APR_INTERRUPT, ACplusMAGIC[9], APR.FM_ADR[3],
                  APR.EBOX_SBUS_DIAG}),
             .D1({PIC.APR_PIA[0], ACplusMAGIC[10], F02_EN, ~MCL.MEM_REG_FUNC}),
             .B0(APR.EBUSdriver.data[14]),
             .B1(APR.EBUSdriver.data[15]));

  mux2x4 e39(.EN(~DS[5]),
             .SEL({DS[4], DS[6]}),
             .D0({PIC.APR_PIA[1], ACplusMAGIC[11], APR.FM_BIT_36, ~APR.EBOX_LOAD_REG}),
             .D1({PIC.APR_PIA[0], ACplusMAGIC[12], APR.FM_ODD_PARITY,
                  ~APR.EBOX_READ_REG}),
             .B0(APR.EBUSdriver.data[16]),
             .B1(APR.EBUSdriver.data[17]));

  assign magic = CRAM.MAGIC[6:7] ^ {2{~RESET}};
  bit [0:3] e4out, e7out;
  bit ignoreE6a, ignoreE6b, ignoreE6c;
  USR4  e4(.S0(1'b0),
           .D({CRAM.MAGIC[1:2], {2{MCL.MEM_REG_FUNC}}}),
           .S3(1'b0),
           .SEL({2{MCL.REQ_EN}}),
           .CLK(clk),
           .Q(e4out));

  USR4  e7(.S0(1'b0),
           .D({magic[7], magic[6], ~CRAM.MAGIC[7], ~CRAM.MAGIC[8]}),
           .S3(1'b0),
           .SEL({2{MCL.REQ_EN}}),
           .Q(e7out),
           .CLK(clk));

  decoder e6(.sel(e7out[1:3]),
             .en(REG_FUNC_EN),
             .q({APR.EBOX_EBR, APR.EBOX_UBR, APR.EBOX_SPARE, ignoreE6a,
                 APR.EBOX_SBUS_DIAG, ignoreE6b, APR.EN_REFILL_RAM_WR,
                 ignoreE6c}));

  assign REG_FUNC_EN = e4out[3];
  assign APR.EBOX_LOAD_REG = e4out[0] & e4out[2];
  assign APR.EBOX_READ_REG = MCL.EBOX_MAP | e4out[1] & e4out[2];
  assign APR.EBOX_CCA = e7out[0] & e7out[1] & e7out[3] & REG_FUNC_EN;
  assign APR.EBOX_ERA = e7out[1] & e7out[2] & e7out[3] & REG_FUNC_EN;
endmodule // apr
