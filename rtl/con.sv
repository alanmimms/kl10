`timescale 1ns/1ns
// M8525 CON
module con(input eboxClk,
           input MR_RESET,
           input CTL_DIAG_READ_FUNC_13x,
           input CTL_DISP_NICOND,

           input [4:6] DIAG,

           output logic CON_LONG_ENABLE,
           output logic CON_PI_CYCLE,
           output logic CON_PCplus1_INH,
           output logic CON_FM_XFER,
           output logic CON_COND_EN00_07,
           output logic CON_COND_DIAG_FUNC,

           output logic CON_COND_EN00_07,
           output logic CON_COND_EN37_37,
           output logic CON_COND_EN47_47,
           output logic CON_COND_EN57_57,

           output logic CON_COND_PCF_MAGIC,
           output logic CON_COND_FE_SHRT,
           output logic CON_COND_AD_FLAGS,
           output logic CON_COND_SEL_VMA,

           output logic [0:3] CON_SR,

           output CON_fmWrite00_17,
           output CON_fmWrite18_35);

  logic CON_CLK;
  logic CON_RESET;
  logic CON_COND_EN10_17;
  logic CON_COND_EN20_27;
  logic CON_COND_EN60_67;
  logic CON_COND_EN70_77;
  logic CON_DIAG_READ;

  assign CON_CLK = eboxClk;
  assign CON_RESET = MR_RESET;

  // COND decoder CON1 p.158
  decoder cond_decoder(.en(~CON_RESET),
                       .sel(CRAM.COND[0:2]),
                       .q({CON_COND_EN00_07, 
                           CON_COND_EN10_17,
                           CON_COND_EN20_27,
                           CON_COND_EN30_37,
                           CON_COND_EN40_47,
                           CON_COND_EN50_57,
                           CON_COND_EN60_67,
                           CON_COND_EN70_77}));

  decoder cond10_decoder(.en(CON_COND_EN10_17),
                         .sel(CRAM.COND[3:5]),
                         .q({CON_COND_FM_WRITE,
                             CON_COND_PCF_MAGIC,
                             CON_COND_FE_SHRT,
                             CON_COND_AD_FLAGS,
                             CON_COND_LOAD_IR,
                             CON_COND_SPEC_INSTR,
                             CON_COND_SR_MAGIC,
                             CON_COND_SEL_VMA}));

  decoder cond20_decoder(.en(CON_COND_EN20_27),
                         .sel(CRAM.COND[3:5]),
                         .q({CON_COND_DIAG_FUNC,
                             CON_COND_EBOX_STATE,
                             CON_COND_EBUS_CTL,
                             CON_COND_MBOX_CTL,
                             CON_COND_024,
                             CON_COND_LONG_EN,
                             CON_COND_026,
                             CON_COND_027}));

  decoder cond30_decoder(.en(CON_COND_EN30_37),
                         .sel(CRAM.COND[3:5]),
                         .q({CON_COND_VMA_MAGIC,
                             CON_COND_VMA_MAGIC,
                             CON_COND_VMA_MAGIC,
                             CON_COND_VMA_MAGIC,
                             CON_COND_VMA_MAGIC,
                             CON_COND_VMA_DEC,
                             CON_COND_VMA_INC,
                             CON_COND_LOAD_VMA_HELD}));

  // EBUS
  mux ebus18mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[18]),
                .d({CON_WR_EVEN_PAR_ADR,
                    CON_CACHE_LOOK_EN,
                    CON_COND_EN00_07,
                    CON_SKIP_EN40_47,
                    CON_SKIP_EN50_57,
                    CON_DELAY_REQ,
                    CON_AR_36,
                    CON_ARX_36}));

  mux ebus19mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[19]),
                .d({CON_WR_EVEN_PAR_DATA,
                    CON_CACHE_LOAD_EN,
                    CON_COND_SEL_VMA,
                    CON_COND_VMA_MAGIC,
                    CON_COND_LOAD_VMA_HELD,
                    CON_LOAD_SPEC_INSTR,
                    CON_VMA_SEL}));

  logic ebus20mux_nothing;
  mux ebus20mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[20]),
                .d({CON_WR_EVEN_PAR_DIR,
                    ebus20mux_nothing,
                    CON_COND_MBOX_CTL,
                    CON_EBUS_REL,
                    CON_SR}));

  logic ebus21mux_nothing;
  mux ebus21mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[21]),
                .d({ebus21mux_nothing,
                    CON_KI10_PAGING_MODE,
                    CON_LONG_EN,
                    CON_PCplus1_INH,
                    CON_NICOND_TRAP_EN,
                    CON_NICOND[7:9]})); // XXX this is not defined yet

  logic ebus22mux_nothing;
  mux ebus22mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[22]),
                .d({ebus22mux_nothing,
                    CON_TRAP_EN,
                    CON_LOAD_IR,
                    CON_COND_INSTR_ABORT,
                    CON_LOAD_ACCESS_COND,
                    CON_INSTR_GO,
                    CON_LOAD_DRAM,
                    CON_COND_ADR_10}));

  logic [0:2] ebus23mux_nothing;
  mux ebus23mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[23]),
                .d({ebus23mux_nothing,
                    CON_AR_LOADED,
                    CON_ARX_LOADED,
                    CON_UCODE_STATE1,
                    CON_UCODE_STATE3,
                    CON_UCODE_STATE5,
                    CON_UCODE_STATE7}));

  logic [0:2] ebus24mux_nothing;
  mux ebus24mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[24]),
                .d({ebus24mux_nothing,
                    CON_PI_CYCLE,
                    CON_MEM_CYCLE,
                    CON_FM_WRITE_PAR,
                    CON_MBOX_WAIT,
                    CON_FM_XFER,
                    CON_PI_DISMISS}));

  // CON1 miscellaneous controls
  always_comb begin
    CON_DIAG_READ = CTL_DIAG_READ_FUNC_13x;
    CON_LOAD_SPEC_INSTR = CTL_DISP_NICOND | CON_COND_SPEC_INSTR | CON_RESET;
    CON_VMA_SEL[1] = CON_COND_VMA_DEC | MCL_LOAD_VMA;
    CON_VMA_SEL[0] = CON_COND_VMA_INC | MCL_LOAD_VMA;
  end

  // CON2 p.159
  logic pi2ReadyReg;
  logic legalReg;
  always_ff @(posedge CON_CLK) begin
    CON_MTR_INT_REQ <= MTR_INTERRUPT_REQ;
    pi2ReadyReg <= PI2_READY;
    CON_LONG_EN <= (MCL_VMA_SECTION_0 & CON_COND_LONG_EN) |
                   (MCL_MBOX_CYC_REQ & CON_LONG_EN & CON_RESET);
    legalReg <= CRAM.MAGIC[3] & CON_IO_LEGAL & CTL_SPEC_FLAG_CTL;
  end

  always_comb begin
    CON_INT_REQ = (CON_MTR_INT_REQ | pi2ReadyReg) & (CON_INT_DISABLE | CON_RESET);

    CON_LOAD_IR = CON_FETCH_CYCLE | CON_COND_LOAD_IR | CON_DIAG_IR_STROBE;
    CON_COND_INSTR_ABORT = CON_COND_SPEC_INSTR & CRAM.MAGIC[6];
    CON_CLR_PRIVATE_INSTR = CLK_PAGE_ERROR | CON_COND_INSTR_ABORT;
    CON_LOAD_ACCESS_COND = CON_COND_LOAD_IR | CON_COND_SR_MAGIC;

    CON_INSTR_GO = legalReg & CON_INSTR_GO & CON_RESET;
    CON_IO_LEGAL = IR_IO_LEGAL | CON_KERNEL_MODE | CON_KERNEL_CYCLE |
                   (SCD_USER & SCD_USER_IOT);
  end

  logic start0 = '0, start1, start2;
  always_comb start0 = CON_DIAG_CONTINUE | (CON_START & start0 & CON_RESET);
  always_ff @(posedge CON_CLK) begin
    start1 <= start0;
    start2 = start1;
    CON_START <= start2;
  end

  logic run0 = '0, run1, run2;
  always_comb run0 = CON_DIAG_SET_RUN | (CON_DIAG_CLR_RUN & run0 & CON_RESET);
  always_ff @(posedge CON_CLK) begin
    run1 <= run0;
    run2 <= run1;
    CON_RUN <= run2;
  end

  logic runStateNC1, runStateNC2, runStateNC3;
  decoder runStateDecoder(.en(DIAG_CONTROL_FUNC_01x),
                          .sel(EBUS.ds[4:6]),
                          .q({CON_DIAG_CLR_RUN,
                              CON_DIAG_SET_RUN,
                              CON_DIAG_CONTINUE,
                              runStateNC1,
                              CON_DIAG_IR_STROBE,
                              CON_DIAG_DRAM_STROBE,
                              runStateNC2,
                              runStateNC3}));

  logic skipEn6x, skipEn7x;
  mux skipEn6x_mux(.sel(CRAM.COND[3:5]),
                   .en('1),
                   .q(skipEn6x),
                   .d({MCL_VMA_FETCH,
                       CON_KERNEL_MODE,
                       SCD_USER,
                       SCD_PUBLIC,
                       MB21_RD_PSE_WR,
                       CON_PI_CYCLE,
                       CON_EBUS_GRANT,
                       CON_PI_XFER}));
  mux skipEn7x_mux(.sel(CRAM.COND[3:5]),
                   .en('1),
                   .q(skipEn7x),
                   .d({CON_INT_REQ,
                       CON_START,
                       CON_RUN,
                       CON_IO_LEGAL,
                       CON_PXCT,
                       MCL_VMA_SECTION_0,
                       VMA_AC_REF,
                       MTR_INT_REQ}));
  always_comb begin
    CON_COND_ADR_10 = CON_SKIP_EN60_67 & skipEn6x |
                      CON_SKIP_EN70_77 & skipEn7x & CON_RESET;
  end
  
  logic longEnComb;
  assign longEnComb = MCL_VMA_SECTION_0 & CON_COND_LONG_EN |
                      MCL_MBOX_CYC_REQ & CON_LONG_EN & CON_RESET;
  always_ff @(posedge CON_CLK) begin
    CON_LONG_EN <= longEnComb;
  end
  
  logic nicondPriority;
  priority_encoder nicondEncoder(.d({CON_PI_CYCLE,
                                     CON_RUN,
                                     CON_MTR_INT_REQ,
                                     CON_INT_REQ,
                                     CON_UCODE_STATE5,
                                     CON_VM_AC_REF,
                                     '0,
                                     CON_PI_CYCLE}),
                                    .q(nicondPriority));
  always_ff @(posedge CON_CLK) begin
    CON_NICOND_TRAP_EN <= nicondPriority[0];
    CON_NICOND[7:9] = nicondPriority;
    CON_EBUS_GRANT <= PI_EBUS_CP_GRANT;
    CON_PI_XFER <= PI_EXT_TRAN_REC;
  end

  always_ff @(posedge CON_CLK) begin
    CON_NICOND_OR_LOAD_IR_DELAYED <= CON_NICOND | CON_COND_LOAD_IR;
  end
  
  always_comb begin
    CON_LOAD_DRAM = CON_DIAG_DRAM_STROBE | CON_NICOND_OR_LOAD_IR_DELAYED;
    CON_KERNEL_MODE = ~SCD_USER & ~SCD_PUBLIC;
  end


  // CON3 p. 160.
  always_ff @(posedge CON_CLK) begin
    CON_CONO_200000 <= CON_CONO_APR & EBUS.data[19];
  end

  always_latch @(posedge CON_CLK iff CON_CONO_PI) begin
    CON_WR_EVEN_PAR_ADR <= EBUS.data[18];
    CON_WR_EVENPAR_DATA <= EBUS.data[19];
    CON_WR_EVEN_PAR_DIR <= EBUS.data[20];
  end

  always_latch @(posedge CON_CLK iff CON_CONO_PAG) begin
    CON_CACHE_LOOK_EN <= EBUS.data[18];
    CON_CACHE_LOAD_EN <= EBUS.data[19];
    CON_KL10_PAGING_EN <= EBUS.data[21];
    CON_TRAP_EN <= EBUS.data[22];
  end

  assign CON_KI10_PAGING_MODE = ~CON_KL10_PAGING_EN;

  mux #(.N(4)) acbmux(.en(~CON_RESET),
                      .sel({CON_MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({EBUS.data[18],
                          CRAM.MAGIC[7],
                          CON_MAGIC_FUNC_02x,
                          CON_MAGIC_FUNC_02x}),
                      .q(CON_LOAD_AC_BLOCKS));
  mux #(.N(4)) pcxmux(.en(~CON_RESET),
                      .sel({CON_MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({EBUS.data[19],
                          CRAM.MAGIC[8],
                          CON_MAGIC_FUNC_02x,
                          CON_MAGIC_FUNC_02x}),
                      .q(CON_LOAD_PREV_CONTEXT));

  assign CON_DELAY_REQ = CON_COND_DIAG_FUNC & CRAM.MAGIC[3];

  logic func0xxNC1, func0xxNC2, func0xxNC3, func0xxNC4;
  decoder func0xx(.en(CRAM.MAGIC[2] & CON_COND_DIAG_FUNC),
                  .sel(CRAM.MAGIC[3:5]),
                  .q({func0xxNC1,
                      CON_MAGIC_FUNC_01x,
                      CON_MAGIC_FUNC_02x,
                      func0xxNC2,
                      CON_MAGIC_FUNC_04x,
                      CON_MAGIC_FUNC_05x,
                      func0xxNC3,
                      func0xxNC4}));

  logic func01xNC1, func01xNC2;
  logic conoAPR, conoPI, conoPAG, dataoAPR;
  decoder func01x(.en(CON_MAGIC_FUNC_01x & CTL_CONSOLE_CONTROL),
                  .sel(CRAM.MAGIC[6:8]),
                  .q({CON_MAGIC_FUNC_010,
                      CON_MAGIC_FUNC_011,
                      func01xNC1,
                      func01xNC2,
                      conoAPR,
                      conoPI,
                      conoPAG,
                      dataoAPR}));

  always_comb begin
    CON_CONO_APR = CLK_EBOX_SYNC & (CON_RESET | conoAPR);
    CON_CONO_PI = CLK_EBOX_SYNC & (CON_RESET | conoPI);
    CON_CONO_PAG = CON_RESET | conoPAG;
    CON_DATAO_APR = CON_RESET | dataoAPR;
  end

  always_comb begin
    CON_SEL_EN = EBUS.data[20] & CON_CONO_APR;
    CON_SEL_DIS = EBUS.data[21] & CON_CONO_APR;
    CON_SEL_CLR = EBUS.data[22] & CON_CONO_APR;
    CON_SEL_SET = EBUS.data[23] & CON_CONO_APR;

    CON_EBUS_REL = ~(CON_COND_EBUS_CTL & CRAM.MAGIC[2] & CLK_EBOX_SYNC);
  end

  always_ff @(posedge CON_CLK iff CON_COND_SR_MAGIC) begin
    CON_SR <= {CRAM.MAGIC[5:6],
               (CRAM.MAGIC[3] | CRAM.MAGIC[7]) & (CRAM.MAGIC[2] | CRAM.MAGIC[7]),
               (CRAM.MAGIC[4] | CRAM.MAGIC[8]) & (CRAM.MAGIC[3] | CRAM.MAGIC[7])});
  end

  // CTL4 p.161.
  XXX TBD
endmodule // con
