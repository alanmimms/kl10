`timescale 1ns/1ns
`include "ebox.svh"
`include "mbox.svh"
// M8545 APR
module apr(iAPR APR,
           iEDP EDP,
           iEBUS EBUS,
           input PWR_WARN,
           input PWR_FAIL
           );

  logic clk;
  logic RESET;
  logic [4:6] DIAG, DS;
  logic READ_110_117;
  logic [6:7] magic;

  assign clk = CLK.APR;
  assign RESET = CLK.MR_RESET;
  assign DIAG = CTL.DIAG[4:6];
  assign DS = ~DIAG & CTL.DIAG_RD_FUNC_11x;
  assign READ_110_117 = CTL.DIAG_RD_FUNC_11x;

module IntEnabler(input clk,
                  input m,
                  output logic e,
                  output logic i);
  always_comb
    e = CON.SEL_EN & EBUS.data[m] |
        i & ~RESET & CON.SEL_DIS & EBUS.data[m];
  always_ff @(posedge clk)
    e <= i;
endmodule

module Event(input clk,
             input m,
             input o,
             output logic e,
             output logic i);
  always_comb
    i = CON.SEL_SET & EBUS.data[m] |
        ~CON.SEL_CLR & e & ~RESET |
        e & ~EBUS.data[m] & ~RESET |
        o;
  always_ff @(posedge clk)
    e <= i;
endmodule


  logic SBUS_ERR_IN, SBUS_ERR_IN_EN;
  logic NXM_ERR_INT_EN, NXM_ERR_EN_IN;
  logic IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN;
  logic MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN;
  logic IO_PF_ERR, IO_PF_ERR_IN;
  logic NXM_ERR, NXM_ERR_IN;
  logic SWEEP_BUSY_EN, SWEEP_BUSY;
  logic C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN;
  logic S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN;
  logic PWR_FAIL_INT_EN, PWR_FAIL_EN_IN;
  logic SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN;
  logic SWEEP_DONE, SWEEP_DONE_IN;
  logic F02_EN;

  assign clk = CLK.APR;
  assign APR.EBUSdriver.driving = '0;       // XXX temporary

  // APR1 p.382
  IntEnabler sbusInt(clk, 6, SBUS_ERR_INT_EN, SBUS_ERR_EN_IN);
  Event sbusErr(clk, 6, MBOX.SBUS_ERR, SBUS_ERR_EN, SBUS_ERR_IN);

  IntEnabler nxmInt(clk, 7, NXM_ERR_INT_EN, NXM_ERR_EN_IN);
  Event nxmErr(clk, 7, MBOX.NXM_ERR, NXM_ERR_EN, NXM_ERR_IN);

  IntEnabler iopfInt(clk, 8, IO_PF_ERR_INT_EN, IO_PF_ERR_EN_IN);
  Event iopfErr(clk, 8, APR.SET_IO_PF_ERR, IO_PF_ERR_EN, IO_PF_ERR_IN);

  IntEnabler mbParInt(clk, 9, MB_PAR_ERR_INT_EN, MB_PAR_ERR_EN_IN);
  Event mbParErr(clk, 9, MBOX.MB_PAR_ERR, MB_PAR_ERR, MB_PAR_ERR_IN);

  // APR2 p.383
  IntEnabler cdirpInt(clk, 10, C_DIR_P_ERR_INT_EN, C_DIR_P_ERR_EN_IN);
  Event cdirpErr(clk, 10, MBX.CSH_ADR_PAR_ERR, C_DIR_P_ERR_EN, C_DIR_P_ERR_IN);

  IntEnabler sadrpInt(clk, 11, S_ADR_P_ERR_INT_EN, S_ADR_P_ERR_EN_IN);
  Event sadrpErr(clk, 11, MBOX.ADR_PAR_ERR, S_ADR_P_ERR_EN, S_ADR_P_ERR_IN);

  IntEnabler pwrfInt(clk, 12, PWR_FAIL_ERR_INT_EN, PWR_FAIL_ERR_EN_IN);
  Event pwrfErr(clk, 12, PWR_WARN, PWR_FAIL_ERR_EN, PWR_FAIL_ERR_IN);

  IntEnabler swpdInt(clk, 13, SWEEP_DONE_INT_EN, SWEEP_DONE_EN_IN);
  Event swpdErr(clk, 13,
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
                              ~MBOX.ADR_PAR_ERR;

  always_ff @(posedge clk) begin
    APR.ANY_EBOX_ERR_FLG <= NXM_ERR_IN | MB_PAR_ERR_IN | S_ADR_P_ERR_IN;
  end


  // APR3 p.384
  logic [0:3] e14SR;
  always_ff @(posedge clk) begin

    if (CON.COND_EBUS_CTL | RESET) begin
      e14SR <= {CRAM.MAGIC[0:1], CRAM.MAGIC[3:4]};
    end
  end

  logic [0:2] e2Latch;
  always_latch begin

    if (e14SR[3]) begin
      e2Latch = CRAM.MAGIC[5] ?
                {CRAM.MAGIC[6], ~APR.AC[9], F02_EN} :
                {CRAM.MAGIC[6:8]};
    end
  end

  always_comb begin
    APR.EBUS_DISABLE_CS = e14SR[3] & e2Latch[0];
    APR.EBUS_F01 = e14SR[3] & e2Latch[1];
    APR.APR_EBOX_SEND_F02 = e14SR[3] & e2Latch[2];
    APR.CONI_OR_DATAI = ~APR.APR_EBOX_SEND_F02;
    APR.CONO_OR_DATAO = e14SR[3] & ~APR.CONI_OR_DATAI;
  end

  logic fm36XORin;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(128), .WIDTH(2), .NBYTES(1))
  fm
  (.clk(clk),
   .din({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
   .dout({APR.FM_EXTENDED, fm36XORin}),
   .addr({APR.FMblk, APR.FMadr}),
   .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // ??? WTF ???
`else
  fm_ext_mem fm_ext(.addra({APR.FMblk, APR.FMadr}),
                    .clka(clk),
                    .dina({SHM.AR_EXTENDED, SHM.AR_PAR_ODD ^ SHM.AR_EXTENDED}),
                    .douta({APR.FM_EXTENDED, fm36XORin}),
                    .wea(~clk & CON.FM_WRITE_PAR & APR.SPARE)); // WTF?
`endif

  always_comb begin
    APR.FM_36 = fm36XORin ^ APR.FM_EXTENDED;
    APR.FM_ODD_PARITY = |CRAM.ADB | EDP.FM_PARITY;
  end

  always_ff @(posedge clk) begin
    if (CON.DATAO_APR) begin
      {APR.FETCH_COMP,
       APR.READ_COMP,
       APR.WRITE_COMP,
       APR.USER_COMP} <= EBUS.data[9:12];
    end
  end


  // APR4 p.385
  logic [9:12] ACplus1, ACplus2, ACplus3, ACplusMAGIC;

  mux e49(.en('1),
          .sel(CRAM.FMADR),
          .d({APR.AC[9], ACplus1[9], SHM.XR[10], VMA.VMA[32],
              ACplus2[9], ACplus3[9], ACplusMAGIC[9], CRAM.MAGIC[5]}),
          .q(APR.FMadr[0]));

  mux e54(.en('1),
          .sel(CRAM.FMADR),
          .d({APR.AC[10], ACplus1[10], SHM.XR[4], VMA.VMA[33],
              ACplus2[10], ACplus3[10], ACplusMAGIC[10], CRAM.MAGIC[6]}),
          .q(APR.FMadr[1]));

  mux e65(.en('1),
          .sel(CRAM.FMADR),
          .d({APR.AC[11], ACplus1[11], SHM.XR[2], VMA.VMA[34],
              ACplus2[11], ACplus3[11], ACplusMAGIC[11], CRAM.MAGIC[7]}),
          .q(APR.FMadr[2]));

  mux e59(.en('1),
          .sel(CRAM.FMADR),
          .d({APR.AC[12], ACplus1[12], SHM.XR[1], VMA.VMA[35],
              ACplus2[12], ACplus3[12], ACplusMAGIC[12], CRAM.MAGIC[8]}),
          .q(APR.FMadr[3]));

  logic AC7, AC67, AC37, AC567, AC01;
  always_comb begin
    AC67 = APR.AC[10] ^ APR.AC[11];
    AC37 = APR.AC[11] ^ APR.AC[12];
    AC7 = ~(~AC67 | ~AC37);
    AC567 = APR.AC[10] ^ ~ACplus3[10];
    AC01 = ~APR.AC[10] & ~APR.AC[11];
    F02_EN = AC567 | AC01;

    ACplus1[9] = APR.AC[9] ^ APR.AC7;
    ACplus1[10] = APR.AC[10] ^ AC37;
    ACPlus1[11] = APR.AC[11] ^ APR.AC[12];
    ACplus1[12] = ~APR.AC[12];

    ACplus2[9] = APR.AC[9] ^ AC67;
    ACplus2[10] = APR.AC[10] & APR.AC[11];
    ACplus2[11] = ~APR.AC[11];
    ACplus2[12] = APR.AC[12];

    ACplus3[9] = APR.AC[9] ^ AC567;
    ACplus3[10] = ACplus1[10] ^ ACplus1[11];
    ACplus3[11] = ACplus1[11];
    ACplus3[12] = ~APR.AC[12];
  end

  mc10181 e61(.S(CRAM.MAGIC[1:4]),
              .M(CRAM.MAGIC[0]),
              .CIN('0),
              .A(APR.AC),
              .B(CRAM.MAGIC[5:8]),
              .COUT(),
              .CG(), CP(),
              .F(ACplusMAGIC));


  // APR5 p.386
  logic ignoredE67;
  mux4x2 e67(.SEL(MCL.XR_PREVIOUS),
             .D0({1'bX, APR.CURRENT_BLOCK}),
             .D1({1'bX, APR.PREV_BLOCK}),
             .B({ignoredE67, APR.XR_BLOCK}));

  mux e73(.en('0),
          .sel({APR.CURRENT_BLOCK[0], APR.CURRENT_BLOCK[0], APR.XR_BLOCK[0],
                APR.VMA_BLOCK[0], APR.CURRENT_BLOCK[0], APR.CURRENT_BLOCK[0],
                APR.CURRENT_BLOCK[0], CRAM.MAGIC[2]}),
          .q(APR.FMblk[0]));

  mux e72(.en('0),
          .sel({APR.CURRENT_BLOCK[2], APR.CURRENT_BLOCK[2], APR.XR_BLOCK[2],
                APR.VMA_BLOCK[2], APR.CURRENT_BLOCK[2], APR.CURRENT_BLOCK[2],
                APR.CURRENT_BLOCK[2], CRAM.MAGIC[3]}),
          .q(APR.FMblk[1]));

  mux e71(.en('0),
          .sel({APR.CURRENT_BLOCK[1], APR.CURRENT_BLOCK[1], APR.XR_BLOCK[1],
                APR.VMA_BLOCK[1], APR.CURRENT_BLOCK[1], APR.CURRENT_BLOCK[1],
                APR.CURRENT_BLOCK[1], CRAM.MAGIC[4]}),
          .q(APR.FMblk[0]));

  logic ignoreE68, ignoreE63;
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
           .SEL(CON.COND_MBOX_CTL | RESET),
           .Q({APR.MBOX_CTL[3], APR.MBOX_CTL[6],
               APR.WR_PT_SEL_0, APR.WR_PT_SEL_1}),
           .CLK(clk));

  logic [0:3] e24out;
  mux2x4 e24(.sel(MCL.VMA_PREV_EN),
             .D0({1'b0, APR.CURRENT_BLOCK}),
             .D1({1'b0, APR.PREV_BLOCK}),
             .B(e24out));

  logic ignoreE29;
  USR4 e29(.S0(1'bX),
           .D(e24out),
           .S3(1'bX),
           .SEL(MCL.LOAD_VMA_CONTEXT),
           .CLK(clk),
           .Q({ignoreE29, APR.VMA_BLOCK}));

  always_comb begin
    APR.SET_PAGE_FAIL = CRAM.MAGIC[1] & CON.COND_MBOX_CTL;
    APR.SET_IO_PF_ERR = CRAM.MAGIC[2] & CON.COND_MBOX_CTL;
    APR.PT_DIR_WR = CRAM.MAGIC[4] & CON.COND_MBOX_CTL;
    APR.PT_WR = CRAM.MAGIC[5] & CON.COND_MBOX_CTL;
  end


  // APR6 p.387
  mux2x4 e37(.EN(~DS[4]),
             .SEL(DS[5:6]),
             .D0({SWEEP_BUS_EN, 3'b000}),
             .D1({SBUS_ERR_IN, APR.CURRENT_BLOCK[0], SBUS_ERR_EN_IN}),
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
              APR.FMblk[0], ~APR.SET_PAGE_FAIL, ~APR.PT_DIR_WR, ~APR.PT_WR}),
          .q(APR.EBUSdriver.data[8]));

  mux e19(.en(READ_110_117),
          .sel(DS),
          .d({MB_PAR_ERR_IN, APR.PREV_BLOCK[0], MB_PAR_ERR_EN_IN,
              APR.FETCH_COMP, APR.FMblk[1], APR.EBUS_RETURN, ~APR.EBUS_REQ,
              APR.EBUS_DEMAND}),
          .q(APR.EBUSdriver.data[9]));

  mux e17(.en(READ_110_117),
          .sel(DS),
          .d({C_DIR_P_ERR_IN, APR.PREV_BLOCK[1], C_DIR_P_ERR_EN_IN,
              APR.READ_COMP, APR.FMblk[2], APR.EBOX_DISABLE_CS,
              APR.EBUS_F01, APR.EBOX_SEND_F02}),
          .q(APR.EBUSdriver.data[10]));

  mux e22(.en(READ_110_117),
          .sel(DS),
          .d({S_ADR_P_ERR, APR.PREV_BLOCK[2], S_ADR_P_ERR_EN_IN,
              APR.WRITE_COMP, APR.FMadr[0], ~APR.WR_BAD_ADR_PAR,
              ~CON.FM_WRITE_PAR}),
          .q(APR.EBUSdriver.data[11]));

  mux e21(.en(READ_110_117),
          .sel(DS),
          .d({PWR_FAIL_IN, SHM.AR_EXTENDED, PWR_FAIL_EN_IN, APR.USER_COMP,
              APR.FMadr[1], APR.EBOX_CCA, APR.EBOX_UBR, APR.EBOX_EBR}),
          .q(APR.EBUSdriver.data[12]));

  mux e11(.en(READ_110_117),
          .sel(DS),
          .d({SWEEP_DONE_IN, APR.FM_EXTENDED, SWEEP_DONE_EN, 1'b0,
              APR.FMadr[2], APR.EBOX_ERA, APR.EN_REFILL_RAM_WR, APR.EBOX_SPARE}),
          .q(APR.EBUSdriver.data[13]));

  mux2x4 e34(.EN(~DS[5]),
             .SEL({DS[4], DS[6]}),
             .D0({APR_INTERRUPT, ACplusMAGIC[9], APR.FMadr[3],
                  APR.EBOX_SBUS_DIAG}),
             .D1({PI.APR_PIA[0], ACplusMAGIC[10], F02_EN, ~MCL.MEM_REG_FUNC}),
             .B0(APR.EBUSdriver.data[14]),
             .B1(APR.EBUSdriver.data[15]));

  mux2x4 e39(.EN(~DS[5]),
             .SEL({DS[4], DS[6]}),
             .D0({PI.APR_PIA[1], ACplusMAGIC[11], APR.FM_36, ~APR.EBOX_LOAD_REG}),
             .D1({PI.APR_PIA[0], ACplusMAGIC[12], APR.FM_ODD_PARITY,
                  ~APR.EBOX_READ_REG}),
             .B0(APR.EBUSdriver.data[16]),
             .B1(APR.EBUSdriver.data[17]));

  // XXX find all references above to CRAM.MAGIC[6] and [7] and
  // substitute magic[6], magic[7] because of the XOR below.
  assign magic = CRAM.MAGIC[6:7] ^ {2{~RESET}};
  // APR6 not complete.

endmodule // apr
