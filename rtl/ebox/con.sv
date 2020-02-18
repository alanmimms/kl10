`timescale 1ns/1ns
`include "ebox.svh"
`include "mbox.svh"

// M8525 CON
module con(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCRM CRM,
           iCTL CTL,
           iIR IR,
           iMBZ MBZ,
           iMCL MCL,
           iMTR MTR,
           iPI PI,
           iSCD SCD,
           iVMA VMA,

           iEBUS EBUS,

           input CSH_PAR_BIT_A,
           input CSH_PAR_BIT_B);

  logic conCLK;
  logic CON_DIAG_READ;

  logic CON_WR_EVEN_PAR_DATA;
  logic CON_WR_EVEN_PAR_DIR;
  logic CON_INSTR_GO;
  logic CON_INT_DISABLE;
  logic CON_INT_REQ;
  logic CON_MTR_INT_REQ;
  logic CON_MEM_CYCLE;
  logic CON_FETCH_CYCLE;
  logic CON_DIAG_IR_STROBE;
  logic CON_KERNEL_MODE;
  logic CON_KERNEL_CYCLE;
  logic CON_DIAG_DRAM_STROBE;
  logic CON_NICOND_OR_LOAD_IR_DELAYED;
  logic CON_KL10_PAGING_EN;
  logic CON_PI_XFER;
  logic CON_XFER;
  logic CON_PXCT;
  logic CON_SPEC8;
  logic CON_MBOX_DATA;
  logic CON_FM_DATA;
  logic CON_FM_BIT_36;
  logic CON_CSH_BIT_36;
  logic CON_EBUS_BIT_36;
  logic CON_AR_FROM_MEM;
  logic CON_LOAD_AR_EN;
  logic CON_PI_DISMISS;

  logic CON_DIAG_CLR_RUN;
  logic CON_DIAG_SET_RUN;
  logic CON_DIAG_CONTINUE;
  logic CON_MAGIC_FUNC_02x;
  logic CON_LOAD_AC_BLOCKS;
  logic CON_LOAD_PREV_CONTEXT;
  logic CON_MAGIC_FUNC_01x;
  logic CON_MAGIC_FUNC_04x;
  logic CON_MAGIC_FUNC_05x;
  logic CON_MAGIC_FUNC_010;
  logic CON_MAGIC_FUNC_011;


  assign conCLK = CLK.CON;
  assign CON.RESET = CLK.MR_RESET;

  initial begin
    CON.AR_LOADED = '0;
    CON.ARX_LOADED = '0;
  end

  // COND decoder CON1 p.158
  decoder cond_decoder(.en(~CON.RESET),
                       .sel(CRAM.COND[0:2]),
                       .q({CON.COND_EN_00_07, 
                           CON.COND_EN_10_17,
                           CON.COND_EN_20_27,
                           CON.COND_EN_30_37,
                           CON.SKIP_EN_40_47,
                           CON.SKIP_EN_50_57,
                           CON.SKIP_EN_60_67,
                           CON.SKIP_EN_70_77}));

  decoder cond10_decoder(.en(CON.COND_EN_10_17),
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

  decoder cond20_decoder(.en(CON.COND_EN_20_27),
                         .sel(CRAM.COND[3:5]),
                         .q({CON.COND_DIAG_FUNC,
                             CON.COND_EBOX_STATE,
                             CON.COND_EBUS_CTL,
                             CON.COND_MBOX_CTL,
                             CON.COND_024,
                             CON.COND_LONG_EN,
                             CON.COND_026,
                             CON.COND_027}));

  logic [0:4] condVMAmagic;
  decoder cond30_decoder(.en(CON.COND_EN_30_37),
                         .sel(CRAM.COND[3:5]),
                         .q({condVMAmagic,
                             CON.COND_VMA_DEC,
                             CON.COND_VMA_INC,
                             CON.COND_LOAD_VMA_HELD}));

  assign CON.COND_VMA_MAGIC = |condVMAmagic;

  // EBUS
  assign CON.EBUSdriver.driving = CON_DIAG_READ;
  mux ebus18mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[18]),
                .d({CON.WR_EVEN_PAR_ADR,
                    CON.CACHE_LOOK_EN,
                    ~CON.COND_EN_00_07,
                    ~CON.SKIP_EN_40_47,
                    ~CON.SKIP_EN_50_57,
                    CON.DELAY_REQ,
                    CON.AR_36,
                    CON.ARX_36}));

  mux ebus19mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[19]),
                .d({CON_WR_EVEN_PAR_DATA,
                    CON.CACHE_LOAD_EN,
                    ~CON.COND_SEL_VMA,
                    CON.COND_VMA_MAGIC,
                    CON.COND_LOAD_VMA_HELD,
                    ~CON.LOAD_SPEC_INSTR,
                    ~CON.VMA_SEL}));

  logic ebus20mux_nothing = '0;
  mux ebus20mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[20]),
                .d({CON_WR_EVEN_PAR_DIR,
                    ebus20mux_nothing,
                    ~CON.COND_MBOX_CTL,
                    CON.EBUS_REL,
                    CON.SR}));

  logic ebus21mux_nothing = '0;
  mux ebus21mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[21]),
                .d({ebus21mux_nothing,
                    ~CON.KI10_PAGING_MODE,
                    ~CON.LONG_EN,
                    ~CON.PCplus1_INH,
                    CON.NICOND_TRAP_EN,
                    CON.NICOND[7:9]}));

  logic ebus22mux_nothing = '0;
  mux ebus22mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[22]),
                .d({ebus22mux_nothing,
                    CON.TRAP_EN,
                    ~CON.LOAD_IR,
                    CON.COND_INSTR_ABORT,
                    CON.LOAD_ACCESS_COND,
                    ~CON_INSTR_GO,
                    CON.LOAD_DRAM,
                    CON.COND_ADR_10}));

  logic [0:1] ebus23mux_nothing = '0;
  mux ebus23mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[23]),
                .d({ebus23mux_nothing,
                    CON.AR_LOADED,
                    ~CON.ARX_LOADED,
                    CON.UCODE_STATE1,
                    CON.UCODE_STATE3,
                    CON.UCODE_STATE5,
                    CON.UCODE_STATE7}));

  logic [0:1] ebus24mux_nothing = '0;
  mux ebus24mux(.sel(CTL.DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[24]),
                .d({ebus24mux_nothing,
                    CON.PI_CYCLE,
                    ~CON_MEM_CYCLE,
                    ~CON.FM_WRITE_PAR,
                    ~CON.MBOX_WAIT,
                    ~CON.FM_XFER,
                    ~CON_PI_DISMISS}));

  // CON1 miscellaneous controls
  always_comb begin
    CON_DIAG_READ = CTL.DIAG_READ_FUNC_13x;
    CON.LOAD_SPEC_INSTR = CTL.DISP_NICOND | CON.COND_SPEC_INSTR | CON.RESET;
    CON.VMA_SEL[1] = CON.COND_VMA_DEC | MCL.LOAD_VMA;
    CON.VMA_SEL[0] = CON.COND_VMA_INC | MCL.LOAD_VMA;
  end

  // CON2 p.159
  logic piReadyReg;
  logic legalReg;
  always_ff @(posedge conCLK) begin
    CON_MTR_INT_REQ <= MTR.INTERRUPT_REQ;
    piReadyReg <= PI.READY;
    CON.LONG_EN <= (~MCL.VMA_SECTION_0 & CON.COND_LONG_EN) |
                   (~MCL.MBOX_CYC_REQ & CON.LONG_EN & ~CON.RESET);
    legalReg <= CRAM.MAGIC[3] & CON.IO_LEGAL & CTL.SPEC_FLAG_CTL;
  end

  always_comb begin
    CON_INT_REQ = (CON_MTR_INT_REQ | piReadyReg) & (~CON_INT_DISABLE | CON.RESET);

    CON.LOAD_IR = CON_FETCH_CYCLE | CON.COND_LOAD_IR | CON_DIAG_IR_STROBE;
    CON.COND_INSTR_ABORT = CON.COND_SPEC_INSTR & CRAM.MAGIC[6];
    CON.CLR_PRIVATE_INSTR = CLK.PAGE_ERROR | CON.COND_INSTR_ABORT;
    CON.LOAD_ACCESS_COND = CON.COND_LOAD_IR | CON.COND_SR_MAGIC;

    CON_INSTR_GO = legalReg & ~CON_INSTR_GO & ~CON.RESET;
    CON.IO_LEGAL = IR.IO_LEGAL | CON_KERNEL_MODE | CON_KERNEL_CYCLE |
                   (SCD.USER & SCD.USER_IOT);
  end

  logic start0 = '0;
  logic start1, start2;
  always_comb start0 = CON_DIAG_CONTINUE | (~CON.START & ~start0 & ~CON.RESET);
  always_ff @(posedge conCLK) begin
    start1 <= start0;
    start2 = start1;
    CON.START <= start2;
  end

  logic run0 = '0;
  logic run1, run2;
  always_comb run0 = CON_DIAG_SET_RUN | (~CON_DIAG_CLR_RUN & ~run0 & ~CON.RESET);
  always_ff @(posedge conCLK) begin
    run1 <= run0;
    run2 <= run1;
    CON.RUN <= run2;
  end

  logic runStateNC1, runStateNC2, runStateNC3;
  decoder runStateDecoder(.en(CTL.DIAG_CTL_FUNC_01x),
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
                   .d({MCL.VMA_FETCH,
                       CON_KERNEL_MODE,
                       SCD.USER,
                       SCD.PUBLIC,
                       MBZ.RD_PSE_WR,
                       CON.PI_CYCLE,
                       ~CON.EBUS_GRANT,
                       ~CON_PI_XFER}));
  mux skipEn7x_mux(.sel(CRAM.COND[3:5]),
                   .en('1),
                   .q(skipEn7x),
                   .d({CON_INT_REQ,
                       ~CON.START,
                       CON.RUN,
                       CON.IO_LEGAL,
                       CON_PXCT,
                       MCL.VMA_SECTION_0,
                       VMA.AC_REF,
                       ~CON_MTR_INT_REQ}));
  always_comb begin
    CON.COND_ADR_10 = CON.SKIP_EN_60_67 & skipEn6x |
                      CON.SKIP_EN_70_77 & skipEn7x & CON.RESET;
  end
  
  logic [0:2] nicondPriority;
  priority_encoder8 nicondEncoder(.d({CON.PI_CYCLE,
                                      CON.RUN,
                                      CON_MTR_INT_REQ,
                                      CON_INT_REQ,
                                      CON.UCODE_STATE5,
                                      ~VMA.AC_REF,
                                      '0,
                                      CON.PI_CYCLE}),
                                  .q(nicondPriority));
  always_ff @(posedge conCLK) begin
    CON.NICOND_TRAP_EN <= nicondPriority[0];
    CON.NICOND[7:9] = nicondPriority;
    CON.EBUS_GRANT <= PI.EBUS_CP_GRANT;
    CON_PI_XFER <= PI.EXT_TRAN_REC;
  end
  // XXX This is a guess
  assign CON.NICOND[10] = CON.NICOND_TRAP_EN;

  always_ff @(posedge conCLK) begin
    CON_NICOND_OR_LOAD_IR_DELAYED <= CTL.DISP_NICOND | CON.COND_LOAD_IR;
  end
  
  always_comb begin
    CON.LOAD_DRAM = CON_DIAG_DRAM_STROBE | CON_NICOND_OR_LOAD_IR_DELAYED;
    CON_KERNEL_MODE = ~SCD.USER & ~SCD.PUBLIC;
  end


  // CON3 p. 160.
  always_ff @(posedge conCLK) begin
    CON.CONO_200000 <= CON.CONO_APR & EBUS.data[19];
  end

  always_ff @(posedge conCLK iff CON.CONO_PI) begin
    CON.WR_EVEN_PAR_ADR <= EBUS.data[18];
    CON_WR_EVEN_PAR_DATA <= EBUS.data[19];
    CON_WR_EVEN_PAR_DIR <= EBUS.data[20];
  end

  always_ff @(posedge conCLK iff CON.CONO_PAG) begin
    CON.CACHE_LOOK_EN <= EBUS.data[18];
    CON.CACHE_LOAD_EN <= EBUS.data[19];
    CON_KL10_PAGING_EN <= EBUS.data[21];
    CON.TRAP_EN <= EBUS.data[22];
  end

  assign CON.KI10_PAGING_MODE = ~CON_KL10_PAGING_EN;

  mux #(.N(4)) acbmux(.en(~CON.RESET),
                      .sel({CON_MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({~EBUS.data[18],
                          CRAM.MAGIC[7],
                          CON_MAGIC_FUNC_02x,
                          CON_MAGIC_FUNC_02x}),
                      .q(CON_LOAD_AC_BLOCKS));
  mux #(.N(4)) pcxmux(.en(~CON.RESET),
                      .sel({CON_MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({~EBUS.data[19],
                          CRAM.MAGIC[8],
                          ~CON_MAGIC_FUNC_02x,
                          ~CON_MAGIC_FUNC_02x}),
                      .q(CON_LOAD_PREV_CONTEXT));

  assign CON.DELAY_REQ = CON.COND_DIAG_FUNC & CRAM.MAGIC[3];

  logic func0xxNC1, func0xxNC2, func0xxNC3, func0xxNC4;
  decoder func0xx(.en(~CRAM.MAGIC[2] & CON.COND_DIAG_FUNC),
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
  decoder func01x(.en(CON_MAGIC_FUNC_01x & ~CTL.CONSOLE_CONTROL),
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
    CON.CONO_APR = CLK.EBOX_SYNC & (CON.RESET | conoAPR);
    CON.CONO_PI = CLK.EBOX_SYNC & (CON.RESET | conoPI);
    CON.CONO_PAG = CON.RESET | conoPAG;
    CON.DATAO_APR = CON.RESET | dataoAPR;
  end

  always_comb begin
    CON.SEL_EN = EBUS.data[20] & CON.CONO_APR;
    CON.SEL_DIS = EBUS.data[21] & CON.CONO_APR;
    CON.SEL_CLR = EBUS.data[22] & CON.CONO_APR;
    CON.SEL_SET = EBUS.data[23] & CON.CONO_APR;

    CON.EBUS_REL = ~(CON.COND_EBUS_CTL & CRAM.MAGIC[2] & CLK.EBOX_SYNC);
  end

  always_ff @(posedge conCLK iff CON.COND_SR_MAGIC) begin
    CON.SR <= {CRAM.MAGIC[5:6],
               (CRAM.MAGIC[3] | CRAM.MAGIC[7]) & (CRAM.MAGIC[2] | CRAM.MAGIC[7]),
               (CRAM.MAGIC[4] | CRAM.MAGIC[8]) & (CRAM.MAGIC[3] | CRAM.MAGIC[7])};
  end

  // CTL4 p.161.
  always_comb begin
    CON.PI_DISABLE = ~CON.RUN | CON.EBOX_HALTED;
    CON.AR_36 = (CON_WR_EVEN_PAR_DATA | CON.AR_LOADED) &
                (CON_MBOX_DATA | CON_CSH_BIT_36 | CON_AR_FROM_MEM) &
                (CON_FM_DATA | CON_FM_BIT_36 | CON_AR_FROM_MEM) &
                (CON.AR_FROM_EBUS | CON_EBUS_BIT_36);
    CON.ARX_36 = (CON_MBOX_DATA | CON_CSH_BIT_36) &
                 (CON_FM_DATA | CON_FM_BIT_36);
  end

  always_ff @(posedge conCLK iff CON.LOAD_SPEC_INSTR) begin
    CON_KERNEL_CYCLE <= CRAM.MAGIC[1];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    CON_PXCT <= CRAM.MAGIC[4];
    CON_INT_DISABLE <= CRAM.MAGIC[5];

    CON.EBOX_HALTED <= CRAM.MAGIC[7];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    CON_SPEC8 <= CRAM.MAGIC[8]; // XXX not used?
  end

  always_ff @(posedge conCLK iff CON.COND_EBUS_STATE | CON.RESET) begin
    CON.UCODE_STATE1 <= (CRAM.MAGIC[2] | CRAM.MAGIC[1]) & (CON.UCODE_STATE1 | CRAM.MAGIC[1]);
    CON.UCODE_STATE3 <= (CRAM.MAGIC[4] | CRAM.MAGIC[3]) & (CON.UCODE_STATE3 | CRAM.MAGIC[3]);
    CON.UCODE_STATE5 <= (CRAM.MAGIC[6] | CRAM.MAGIC[5]) & (CON.UCODE_STATE5 | CRAM.MAGIC[5]);
    CON.UCODE_STATE7 <= (CRAM.MAGIC[8] | CRAM.MAGIC[7]) & (CON.UCODE_STATE7 | CRAM.MAGIC[7]);
  end

  always_ff @(posedge conCLK) begin
    CON_CSH_BIT_36 <= CSH_PAR_BIT_A | CSH_PAR_BIT_B;
    CON_FM_BIT_36 <= APR.FM_BIT_36;
    CON_EBUS_BIT_36 <= EBUS.parity;
    CON_MBOX_DATA <= CON.FM_XFER;
    CON_FM_DATA <= CON.MB_XFER;
  end

  always_comb begin
    CON_LOAD_AR_EN = MCL.LOAD_ARX | MCL.LOAD_AR;
    // WIRE-OR of negated signals! XXX (there are more I need to go fix)
    CON_AR_FROM_MEM = ~(~CON_LOAD_AR_EN | ~CON_XFER | ~CLK.PAGE_ERROR);
  end
  

  always_ff @(posedge conCLK) begin
    CON.AR_FROM_EBUS <= CTL.EBUS_XFER & EBUS.parity;
    CON.ARX_LOADED <= CON_XFER & ~CON.FM_XFER & ~CLK.PAGE_ERROR & MCL.LOAD_ARX;
    CON.AR_LOADED <= CON_AR_FROM_MEM | CON.AR_FROM_EBUS;
  end

  // CON5 p.162
  logic cond345_1s;
  logic specFlagMagic2;
  logic waitingACStore;
  logic CON_PI_CYCLE_IN;
  logic CON_MEM_CYCLE_IN;
  logic CON_CLR_PI_CYCLE;
  always_comb begin
    CON_PI_CYCLE_IN = CON.PI_CYCLE;
    CON_MEM_CYCLE_IN = CON_MEM_CYCLE;
    CON_XFER = CON.FM_XFER | CON.MB_XFER;

    specFlagMagic2 = (CTL.SPEC_FLAG_CTL & CRAM.MAGIC[2]);
    CON_CLR_PI_CYCLE = (CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE & CLK.EBOX_SYNC) |
                       specFlagMagic2;
    CON_PI_DISMISS = specFlagMagic2 & ~CON.PI_CYCLE & ~CLK.EBOX_SYNC;

    waitingACStore = MCL.STORE_AR & CON.MBOX_WAIT & VMA.AC_REF;
    cond345_1s = CRAM.COND[3:5] == 3'b111;
    CON.FM_WRITE00_17 = (cond345_1s & CON.COND_EN_10_17) | waitingACStore;
    CON.FM_WRITE18_35 = CON.FM_WRITE00_17;
    CON.FM_WRITE_PAR = ~CLK.SBR_CALL & ~conCLK;

    CON.MBOX_WAIT = CRAM.MEM[2] & CON_MEM_CYCLE;
    CON.FM_XFER = CRAM.MEM[2] & CON_MEM_CYCLE & VMA.AC_REF;
    CON_FETCH_CYCLE = MCL.VMA_FETCH & CON_MEM_CYCLE;
  end

  always_ff @(posedge conCLK) begin
    CON.PI_CYCLE <= (CON.COND_SPEC_INSTR & CRAM.MAGIC[0]) |
                    (~MCL.SKIP_SATISFIED & ~CON_CLR_PI_CYCLE & ~CON.RESET & CON.PI_CYCLE);
    CON_MEM_CYCLE <= MCL.MBOX_CYC_REQ |
                     (CON_MEM_CYCLE & ~CON_XFER & ~CLK.PAGE_ERROR & ~CON.RESET);
  end
endmodule // con
