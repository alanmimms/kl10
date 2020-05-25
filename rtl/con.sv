// schematic review: CON1, CON2, CON3, CON4, CON5.
`timescale 1ns/1ns
`include "ebox.svh"

// M8525 CON
module con(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCRM CRM,
           iCSH CSH,
           iCTL CTL,
           iIR IR,
           iMBZ MBZ,
           iMCL MCL,
           iMTR MTR,
           iPI PIC,
           iSCD SCD,
           iVMA VMA,

           iEBUS.mod EBUS);

  bit clk;
  bit DIAG_READ;

  bit NICOND, CONO_APR, WR_EVEN_PAR_DATA, WR_EVEN_PAR_DIR, INSTR_GO;
  bit INT_DISABLE, INT_REQ, MTR_INT_REQ, MEM_CYCLE, FETCH_CYCLE;
  bit DIAG_IR_STROBE, KERNEL_MODE, KERNEL_CYCLE, DIAG_DRAM_STROBE;
  bit NICOND_OR_LOAD_IR_DELAYED, KL10_PAGING_EN, PI_XFER, XFER, PXCT;
  bit SPEC8, MBOX_DATA, FM_DATA, FM_BIT_36, CSH_BIT_36, EBUS_BIT_36;
  bit AR_FROM_MEM, LOAD_AR_EN;
  bit DIAG_CLR_RUN, DIAG_SET_RUN, DIAG_CONTINUE, MAGIC_FUNC_02x;
  bit LOAD_AC_BLOCKS, LOAD_PREV_CONTEXT;
  bit MAGIC_FUNC_01x, MAGIC_FUNC_04x, MAGIC_FUNC_05x, MAGIC_FUNC_010, MAGIC_FUNC_011;

  assign clk = CLK.CON;
  assign CON.RESET = CLK.MR_RESET;

  // COND decoder CON1 p.158
  decoder e8(.en(~CON.RESET),
             .sel(CRAM.COND[0:2]),
             .q({CON.COND_EN_00_07, 
                 CON.COND_EN_10_17,
                 CON.COND_EN_20_27,
                 CON.COND_EN_30_37,
                 CON.SKIP_EN_40_47,
                 CON.SKIP_EN_50_57,
                 CON.SKIP_EN_60_67,
                 CON.SKIP_EN_70_77}));

  decoder e25(.en(CON.COND_EN_10_17),
              .sel(CRAM.COND[3:5]),
              .q({CON.COND_FM_WRITE,
                  CON.COND_PCF_MAGIC,
                  CON.COND_FE_SHRT,
                  CON.COND_AD_FLAGS,
                  CON.COND_LOAD_IR,
                  CON.COND_SPEC_INSTR,
                  CON.COND_SR_MAGIC,
                  CON.COND_SEL_VMA}));

  // E3 is simply additional drivers for active-low versions of same
  // signals as the above, so it is skipped here.

  decoder e26(.en(CON.COND_EN_20_27),
              .sel(CRAM.COND[3:5]),
              .q({CON.COND_DIAG_FUNC,
                  CON.COND_EBOX_STATE,
                  CON.COND_EBUS_CTL,
                  CON.COND_MBOX_CTL,
                  CON.COND_024,
                  CON.COND_LONG_EN,
                  CON.COND_026,
                  CON.COND_027}));

  bit [0:4] e2q0_4;
  decoder e2(.en(CON.COND_EN_30_37),
             .sel(CRAM.COND[3:5]),
             .q({e2q0_4,
                 CON.COND_VMA_DEC,
                 CON.COND_VMA_INC,
                 CON.COND_LOAD_VMA_HELD}));

  assign CON.COND_VMA_MAGIC = |e2q0_4;

  // EBUS
  assign CON.EBUSdriver.driving = DIAG_READ;
  mux e9(.sel(CTL.DIAG[4:6]),
         .en(DIAG_READ),
         .q(CON.EBUSdriver.data[18]),
         .d({CON.WR_EVEN_PAR_ADR,
             CON.CACHE_LOOK_EN,
             ~CON.COND_EN_00_07,
             ~CON.SKIP_EN_40_47,
             ~CON.SKIP_EN_50_57,
             CON.DELAY_REQ,
             CON.AR_36,
             CON.ARX_36}));

  mux e6(.sel(CTL.DIAG[4:6]),
         .en(DIAG_READ),
         .q(CON.EBUSdriver.data[19]),
         .d({WR_EVEN_PAR_DATA,
             CON.CACHE_LOAD_EN,
             ~CON.COND_SEL_VMA,
             CON.COND_VMA_MAGIC,
             CON.COND_LOAD_VMA_HELD,
             ~CON.LOAD_SPEC_INSTR,
             ~CON.VMA_SEL}));

  mux e36(.sel(CTL.DIAG[4:6]),
          .en(DIAG_READ),
          .q(CON.EBUSdriver.data[20]),
          .d({WR_EVEN_PAR_DIR,
              1'b0,
              ~CON.COND_MBOX_CTL,
              CON.EBUS_REL,
              CON.SR}));

  mux e17(.sel(CTL.DIAG[4:6]),
          .en(DIAG_READ),
          .q(CON.EBUSdriver.data[21]),
          .d({1'b0,
              ~CON.KI10_PAGING_MODE,
              ~CON.LONG_EN,
              ~CON.PCplus1_INH,
              CON.NICOND_TRAP_EN,
              CON.NICOND[7:9]}));

  mux e21(.sel(CTL.DIAG[4:6]),
          .en(DIAG_READ),
          .q(CON.EBUSdriver.data[22]),
          .d({1'b0,
              CON.TRAP_EN,
              ~CON.LOAD_IR,
              CON.COND_INSTR_ABORT,
              CON.LOAD_ACCESS_COND,
              ~INSTR_GO,
              CON.LOAD_DRAM,
              CON.COND_ADR_10}));

  mux e48(.sel(CTL.DIAG[4:6]),
          .en(DIAG_READ),
          .q(CON.EBUSdriver.data[23]),
          .d({2'b00,
              CON.AR_LOADED,
              ~CON.ARX_LOADED,
              CON.UCODE_STATE1,
              CON.UCODE_STATE3,
              CON.UCODE_STATE5,
              CON.UCODE_STATE7}));

  mux e56(.sel(CTL.DIAG[4:6]),
          .en(DIAG_READ),
          .q(CON.EBUSdriver.data[24]),
          .d({2'b00,
              CON.PI_CYCLE,
              ~MEM_CYCLE,
              ~CON.FM_WRITE_PAR,
              ~CON.MBOX_WAIT,
              ~CON.FM_XFER,
              ~CON.PI_DISMISS}));

  // CON1 miscellaneous controls
  assign DIAG_READ = CTL.DIAG_READ_FUNC_13x;
  assign CON.LOAD_SPEC_INSTR = NICOND | CON.COND_SPEC_INSTR | CON.RESET;
  assign CON.VMA_SEL[1] = CON.COND_VMA_DEC | MCL.LOAD_VMA;
  assign CON.VMA_SEL[0] = CON.COND_VMA_INC | MCL.LOAD_VMA;
  assign NICOND = CTL.DISP_NICOND;

  // CON2 p.159
  bit e34q3;
  bit e34q15;
  always_ff @(posedge clk) MTR_INT_REQ <= MTR.INTERRUPT_REQ;
  always_ff @(posedge clk) e34q3 <= PIC.READY;
  always_ff @(posedge clk) CON.LONG_EN <= ~MCL.VMA_SECTION_0 & CON.COND_LONG_EN |
                                          ~MCL.MBOX_CYC_REQ & CON.LONG_EN & ~CON.RESET;
  always_ff @(posedge clk) e34q15 <= CRAM.MAGIC[3] & CON.IO_LEGAL & CTL.SPEC_FLAG_CTL;

  assign INT_REQ = (MTR_INT_REQ | e34q3) & (~INT_DISABLE | CON.RESET);

  assign CON.LOAD_IR = FETCH_CYCLE | CON.COND_LOAD_IR | DIAG_IR_STROBE;
  assign CON.COND_INSTR_ABORT = CON.COND_SPEC_INSTR & CRAM.MAGIC[6];
  assign CON.CLR_PRIVATE_INSTR = CLK.PAGE_ERROR | CON.COND_INSTR_ABORT;
  assign CON.LOAD_ACCESS_COND = CON.COND_LOAD_IR | CON.COND_SR_MAGIC;

  assign INSTR_GO = DIAG_CONTINUE | e34q15 & INSTR_GO & ~CON.RESET;
  assign CON.IO_LEGAL = IR.IO_LEGAL | KERNEL_MODE | KERNEL_CYCLE |
                        SCD.USER & SCD.USER_IOT;

  always @(posedge DIAG_CONTINUE) $display($time, " [DIAG CONTINUE]");
  always @(posedge INSTR_GO) $display($time, " [INSTR_GO]");

  bit start0, start1, start2;
  assign start0 = DIAG_CONTINUE |
                  start0 & ~CON.START & ~CON.RESET;

  always_ff @(posedge clk) begin
    start1 <= start0;
    start2 = start1;
    CON.START <= start2;
  end

  always @(posedge CON.START) $display($time, " [KL START]");

  bit run0, run1, run2;
  assign run0 = DIAG_SET_RUN |
                run0 & ~DIAG_CLR_RUN & ~CON.RESET;
  always_ff @(posedge clk) begin
    run1 <= run0;
    run2 <= run1;
    CON.RUN <= run2;
  end

  always @(posedge CON.RUN) $display($time, " [KL RUN]");
  always @(negedge CON.RUN) $display($time, " [RUN flip-flop deassert]");

/*
  bit runStateNC1, runStateNC2, runStateNC3;
  bit [0:7] e39Q;
  assign DIAG_CLR_RUN = e39Q[0];
  assign DIAG_SET_RUN = e39Q[1];
  assign DIAG_CONTINUE = e39Q[2];
  assign DIAG_IR_STROBE = e39Q[4];
  assign DIAG_DRAM_STROBE = e39Q[5];

  decoder e39(.en(CTL.DIAG_CTL_FUNC_01x),
              .sel(EBUS.ds[4:6]),
              .q(e39Q));
*/

  always_comb begin
    DIAG_CLR_RUN = 0;
    DIAG_SET_RUN = 0;
    DIAG_CONTINUE = 0;
    DIAG_IR_STROBE = 0;
    DIAG_DRAM_STROBE = 0;

    case({CTL.DIAG_CTL_FUNC_01x, EBUS.ds[4:6]})
    4'b1000: DIAG_CLR_RUN = 1;
    4'b1001: DIAG_SET_RUN = 1;
    4'b1010: DIAG_CONTINUE = 1;
    4'b1100: DIAG_IR_STROBE = 1;
    4'b1101: DIAG_DRAM_STROBE = 1;
    endcase
  end

  bit e19Q, e27Q;
  mux e19(.sel(CRAM.COND[3:5]),
          .en(1'b1),
          .q(e19Q),
          .d({MCL.VMA_FETCH,
              KERNEL_MODE,
              SCD.USER,
              SCD.PUBLIC,
              MBZ.RD_PSE_WR_REF,
              CON.PI_CYCLE,
              ~CON.EBUS_GRANT,
              ~PI_XFER}));

  mux e27(.sel(CRAM.COND[3:5]),
          .en(1'b1),
          .q(e27Q),
          .d({INT_REQ,
              ~CON.START,
              CON.RUN,
              CON.IO_LEGAL,
              PXCT,
              ~MCL.VMA_SECTION_0,
              VMA.AC_REF,
              ~MTR_INT_REQ}));

  assign CON.COND_ADR_10 = CON.SKIP_EN_60_67 & e19Q |
                           CON.SKIP_EN_70_77 & e27Q & ~CON.RESET;
  
  bit [0:2] e33Q;
  priority_encoder8 e33(.d({CON.PI_CYCLE,
                            ~CON.RUN,
                            MTR_INT_REQ,
                            INT_REQ,
                            CON.UCODE_STATE5,
                            ~VMA.AC_REF,
                            1'b0,
                            ~CON.PI_CYCLE}),
                        .any(),
                        .q(e33Q));

  always_ff @(posedge clk) CON.NICOND_TRAP_EN <= e33Q[0];
  always_ff @(posedge clk) CON.NICOND[7:9] = e33Q[0:2];
  always_ff @(posedge clk) CON.EBUS_GRANT <= PIC.EBUS_CP_GRANT;
  always_ff @(posedge clk) PI_XFER <= PIC.EXT_TRAN_REC;

  // XXX This is a guess
  assign CON.NICOND[10] = CON.NICOND_TRAP_EN;

  bit e34q1, e34q13;
  always_ff @(posedge clk) e34q1 <= NICOND;
  always_ff @(posedge clk) e34q13 <= CON.COND_LOAD_IR;
  
  assign NICOND_OR_LOAD_IR_DELAYED = e34q1 | e34q13;
  assign CON.LOAD_DRAM = DIAG_DRAM_STROBE | NICOND_OR_LOAD_IR_DELAYED;
  assign KERNEL_MODE = ~SCD.USER & ~SCD.PUBLIC;


  // CON3 p. 160.
  always_ff @(posedge clk) CON.CONO_200000 <= CONO_APR & EBUS.data[19];

  bit unusedE14;
  USR4 e14(.CLK(clk),
           .S0(1'b0),
           .D({EBUS.data[18], 1'b0, EBUS.data[19], EBUS.data[20]}),
           .S3(1'b0),
           .SEL({2{CON.CONO_PI}}),
           .Q({CON.WR_EVEN_PAR_ADR,
               unusedE14,
               WR_EVEN_PAR_DATA,
               WR_EVEN_PAR_DIR}));

  USR4 e10(.CLK(clk),
           .S0(1'b0),
           .D({EBUS.data[18:19], EBUS.data[21:22]}),
           .S3(1'b0),
           .SEL({2{CON.CONO_PAG}}),
           .Q({CON.CACHE_LOOK_EN,
               CON.CACHE_LOAD_EN,
               KL10_PAGING_EN,
               CON.TRAP_EN}));

  assign CON.KI10_PAGING_MODE = ~KL10_PAGING_EN;

  bit e43aQ, e43bQ;
  mux #(.N(4)) e43a(.en(~CON.RESET),
                   .sel({MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                   .d({~EBUS.data[18],
                       CRAM.MAGIC[7],
                       {2{~MAGIC_FUNC_02x}}}),
                   .q(e43aQ));
  assign LOAD_AC_BLOCKS = ~e43aQ;

  mux #(.N(4)) e43b(.en(~CON.RESET),
                    .sel({MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                    .d({~EBUS.data[19],
                        CRAM.MAGIC[8],
                        {2{~MAGIC_FUNC_02x}}}),
                    .q(e43bQ));
  assign LOAD_PREV_CONTEXT = ~e43bQ;

  assign CON.DELAY_REQ = CON.COND_DIAG_FUNC & CRAM.MAGIC[0];

  bit unusedE47a, unusedE47b;
  bit [6:7] unusedE47c;
  decoder e47(.en(~CRAM.MAGIC[2] & CON.COND_DIAG_FUNC),
              .sel(CRAM.MAGIC[3:5]),
              .q({unusedE47a,
                  MAGIC_FUNC_01x,
                  MAGIC_FUNC_02x,
                  unusedE47b,
                  MAGIC_FUNC_04x,
                  MAGIC_FUNC_05x,
                  unusedE47c}));

  bit [0:7] e15Q;
  decoder e15(.en(MAGIC_FUNC_01x & ~CTL.CONSOLE_CONTROL),
              .sel(CRAM.MAGIC[6:8]),
              .q(e15Q));

  assign CONO_APR = CON.RESET | e15Q[4];
  assign CON.CONO_APR = CLK.EBOX_SYNC & CONO_APR;
  assign CON.CONO_PI = CLK.EBOX_SYNC & (CON.RESET | e15Q[5]);
  assign CON.CONO_PAG = CON.RESET | e15Q[6];
  assign CON.DATAO_APR = CON.RESET | e15Q[7];

  assign CON.SEL_EN = EBUS.data[20] & CONO_APR;
  assign CON.SEL_DIS = EBUS.data[21] & CONO_APR;
  assign CON.SEL_CLR = EBUS.data[22] & CONO_APR;
  assign CON.SEL_SET = EBUS.data[23] & CONO_APR;

  assign CON.EBUS_REL = CON.COND_EBUS_CTL & CRAM.MAGIC[2] & CLK.EBOX_SYNC;

  USR4 e40(.CLK(clk),
           .S0(1'b0),
           .D({CRAM.MAGIC[5:6],
               (CRAM.MAGIC[3] | CRAM.MAGIC[7]) & (CRAM.MAGIC[2] | CRAM.MAGIC[7]),
               (CRAM.MAGIC[4] | CRAM.MAGIC[8]) & (CRAM.MAGIC[3] | CRAM.MAGIC[7])}),
           .S3(1'b0),
           .SEL({2{~CON.COND_SR_MAGIC}}),
           .Q(CON.SR));

  // CON4 p.161.
  assign CON.PI_DISABLE = ~CON.RUN | CON.EBOX_HALTED;
  assign CON.AR_36 = (~WR_EVEN_PAR_DATA | CON.AR_LOADED) &
                     (~MBOX_DATA | CSH_BIT_36 | ~AR_FROM_MEM) &
                     (~FM_DATA | FM_BIT_36 | ~AR_FROM_MEM) &
                     (~CON.AR_FROM_EBUS | EBUS_BIT_36);
  assign CON.ARX_36 = (~MBOX_DATA | CSH_BIT_36) &
                      (~FM_DATA | FM_BIT_36);

  bit unusedE49;
  USR4 e49(.S0(1'b0),
           .D({CRAM.MAGIC[7], 1'b0, CRAM.MAGIC[2], CRAM.MAGIC[8]}),
           .S3(1'b0),
           .SEL({2{~CON.LOAD_SPEC_INSTR}}),
           .CLK(clk),
           .Q({CON.EBOX_HALTED, unusedE49, CON.PCplus1_INH, SPEC8}));

  always_ff @(posedge clk iff CON.COND_EBUS_STATE | CON.RESET) begin
    CON.UCODE_STATE1 <= (CRAM.MAGIC[2] | CRAM.MAGIC[1]) &
                        (CON.UCODE_STATE1 | CRAM.MAGIC[1]);
    CON.UCODE_STATE3 <= (CRAM.MAGIC[4] | CRAM.MAGIC[3]) &
                        (CON.UCODE_STATE3 | CRAM.MAGIC[3]);
    CON.UCODE_STATE5 <= (CRAM.MAGIC[6] | CRAM.MAGIC[5]) &
                        (CON.UCODE_STATE5 | CRAM.MAGIC[5]);
    CON.UCODE_STATE7 <= (CRAM.MAGIC[8] | CRAM.MAGIC[7]) &
                        (CON.UCODE_STATE7 | CRAM.MAGIC[7]);
  end

  always_ff @(posedge clk) CSH_BIT_36 <= CSH.PAR_BIT_A | CSH.PAR_BIT_B;
  always_ff @(posedge clk) FM_BIT_36 <= APR.FM_BIT_36;
  always_ff @(posedge clk) EBUS_BIT_36 <= EBUS.parity;
  always_ff @(posedge clk) MBOX_DATA <= CON.FM_XFER;
  always_ff @(posedge clk) FM_DATA <= CLK.MB_XFER;

  bit [3:5] e69Q3_5;
  assign LOAD_AR_EN = ~MCL.LOAD_ARX | MCL.LOAD_AR;
  assign AR_FROM_MEM = |e69Q3_5;
  assign CON.AR_LOADED = AR_FROM_MEM;

  always_ff @(posedge clk) e69Q3_5 <= {LOAD_AR_EN, XFER, ~CLK.PAGE_ERROR};
  always_ff @(posedge clk) CON.AR_FROM_EBUS <= CTL.EBUS_XFER & EBUS.parity;
  always_ff @(posedge clk) CON.ARX_LOADED <= XFER & ~CON.FM_XFER & ~CLK.PAGE_ERROR & MCL.LOAD_ARX;

  // CON5 p.162
  bit CLR_PI_CYCLE;

  bit e57q3, e57q2, e57q13, e57q14;
  always_ff @(posedge clk) e57q3 <= CON.COND_SPEC_INSTR & CRAM.MAGIC[0];
  always_ff @(posedge clk) e57q2 <= CON.PI_CYCLE & ~MCL.SKIP_SATISFIED & ~CLR_PI_CYCLE & ~CON.RESET;
  always_ff @(posedge clk) e57q13 <= MCL.MBOX_CYC_REQ;
  always_ff @(posedge clk) e57q14 <= MEM_CYCLE & ~XFER & ~CLK.PAGE_ERROR & ~CON.RESET;

  assign CON.PI_CYCLE = e57q3 | e57q2;
  assign MEM_CYCLE = e57q13 | e57q14;

  assign XFER = CON.FM_XFER | CLK.MB_XFER;

  assign CLR_PI_CYCLE = CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE & CLK.EBOX_SYNC |
                        CTL.SPEC_FLAG_CTL & CRAM.MAGIC[2];
  assign CON.SET_PIH = CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE & CLK.EBOX_SYNC;
  assign CON.PI_DISMISS = CTL.SPEC_FLAG_CTL & CRAM.MAGIC[2] & ~CON.PI_CYCLE & CLK.EBOX_SYNC;

  assign CON.FM_WRITE00_17 = (CRAM.COND[3:5] == 3'b111) & CON.COND_EN_10_17 |
                             MCL.STORE_AR & CON.MBOX_WAIT & VMA.AC_REF;
  assign CON.FM_WRITE18_35 = CON.FM_WRITE00_17;
  assign CON.FM_WRITE_PAR = CON.FM_WRITE18_35 & ~CLK.SBR_CALL & ~clk;

  assign CON.MBOX_WAIT = CRAM.MEM[2] & MEM_CYCLE;
  assign CON.FM_XFER = CRAM.MEM[2] & MEM_CYCLE & VMA.AC_REF;
  assign FETCH_CYCLE = MCL.VMA_FETCH & MEM_CYCLE;
endmodule // con
