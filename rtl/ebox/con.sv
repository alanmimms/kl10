`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"
// M8525 CON
module con(input eboxClk,
           iCON CON,

           iCRAM CRAM,
           iCTL CTL,
           iIR IR,
           iPI PI,
           iSCD SCD,
           iAPR APR,

           input [4:6] DIAG,
           iEBUS EBUS,
           tEBUSdriver EBUSdriver,

           input MTR_INTERRUPT_REQ,

           input MR_RESET,
           input CLK_PAGE_ERROR,
           input CLK_EBOX_SYNC,
           input CLK_SBR_CALL,

           input MCL_VMA_SECTION_0,
           input MCL_MBOX_CYC_REQ,
           input MCL_VMA_FETCH,
           input MCL_LOAD_AR,
           input MCL_LOAD_ARX,
           input MCL_LOAD_VMA,
           input MCL_STORE_AR,
           input MCL_SKIP_SATISFIED,

           input CSH_PAR_BIT_A,
           input CSH_PAR_BIT_B,
           input EBUS_PARITY_E,
           input EBUS_PARITY_ACTIVE_E);

  logic CON_CLK;
  logic CON_DIAG_READ;
  logic CON_WR_EVEN_PAR_DATA;
  logic CON_WR_EVEN_PAR_DIR;
  logic CON_INSTR_GO;
  logic CON_INT_DISABLE;
  logic CON_INT_REQ;
  logic CON_ARX_LOADED;
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
  logic CON_AR_FROM_EBUS;
  logic CON_AR_FROM_MEM;
  logic CON_LOAD_AR_EN;
  logic CON_PI_DISMISS;
  logic CON_MBOX_WAIT;
  logic CON_AR_LOADED;

  assign CON_CLK = eboxClk;
  assign CON.RESET = MR_RESET;

  // COND decoder CON1 p.158
  decoder cond_decoder(.en(~CON.RESET),
                       .sel(CRAM.COND[0:2]),
                       .q({CON.COND_EN00_07, 
                           CON.COND_EN10_17,
                           CON.COND_EN20_27,
                           CON.COND_EN30_37,
                           CON.COND_EN40_47,
                           CON.COND_EN50_57,
                           CON.COND_EN60_67,
                           CON.COND_EN70_77}));

  decoder cond10_decoder(.en(CON.COND_EN10_17),
                         .sel(CRAM.COND[3:5]),
                         .q({CON_COND_FM_WRITE,
                             CON.COND_PCF_MAGIC,
                             CON.COND_FE_SHRT,
                             CON_COND_AD_FLAGS,
                             CON.COND_LOAD_IR,
                             CON_COND_SPEC_INSTR,
                             CON_COND_SR_MAGIC,
                             CON.COND_SEL_VMA}));

  decoder cond20_decoder(.en(CON.COND_EN20_27),
                         .sel(CRAM.COND[3:5]),
                         .q({CON.COND_DIAG_FUNC,
                             CON_COND_EBOX_STATE,
                             CON.COND_EBUS_CTL,
                             CON.COND_MBOX_CTL,
                             CON.COND_024,
                             CON_COND_LONG_EN,
                             CON.COND_026,
                             CON.COND_027}));

  logic [0:4] condVMAmagic;
  decoder cond30_decoder(.en(CON.COND_EN30_37),
                         .sel(CRAM.COND[3:5]),
                         .q({condVMAmagic,
                             CON_COND_VMA_DEC,
                             CON_COND_VMA_INC,
                             CON_COND_LOAD_VMA_HELD}));

  assign CON.COND_VMA_MAGIC = |condVMAmagic;

  // EBUS
  assign EBUSdriver.driving = CON_DIAG_READ;
  mux ebus18mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[18]),
                .d({CON.WR_EVEN_PAR_ADR,
                    CON.CACHE_LOOK_EN,
                    ~CON.COND_EN00_07,
                    ~CON.SKIP_EN40_47,
                    ~CON.SKIP_EN50_57,
                    CON.DELAY_REQ,
                    CON.AR_36,
                    CON.ARX_36}));

  mux ebus19mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[19]),
                .d({CON_WR_EVEN_PAR_DATA,
                    CON.CACHE_LOAD_EN,
                    ~CON.COND_SEL_VMA,
                    CON.COND_VMA_MAGIC,
                    CON_COND_LOAD_VMA_HELD,
                    ~CON.LOAD_SPEC_INSTR,
                    ~CON.VMA_SEL}));

  logic ebus20mux_nothing;
  mux ebus20mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[20]),
                .d({CON_WR_EVEN_PAR_DIR,
                    ebus20mux_nothing,
                    ~CON.COND_MBOX_CTL,
                    CON.EBUS_REL,
                    CON.SR}));

  logic ebus21mux_nothing;
  mux ebus21mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[21]),
                .d({ebus21mux_nothing,
                    ~CON.KI10_PAGING_MODE,
                    ~CON.LONG_EN,
                    ~CON.PCplus1_INH,
                    CON.NICOND_TRAP_EN,
                    CON.NICOND[7:9]})); // XXX this is not defined yet

  logic ebus22mux_nothing;
  mux ebus22mux(.sel(DIAG[4:6]),
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

  logic [0:1] ebus23mux_nothing;
  mux ebus23mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[23]),
                .d({ebus23mux_nothing,
                    CON_AR_LOADED,
                    ~CON_ARX_LOADED,
                    CON.UCODE_STATE1,
                    CON.UCODE_STATE3,
                    CON.UCODE_STATE5,
                    CON.UCODE_STATE7}));

  logic [0:1] ebus24mux_nothing;
  mux ebus24mux(.sel(DIAG[4:6]),
                .en(CON_DIAG_READ),
                .q(EBUS.data[24]),
                .d({ebus24mux_nothing,
                    CON.PI_CYCLE,
                    ~CON_MEM_CYCLE,
                    ~CON.FM_WRITE_PAR,
                    ~CON_MBOX_WAIT,
                    ~CON.FM_XFER,
                    ~CON_PI_DISMISS}));

  // CON1 miscellaneous controls
  always_comb begin
    CON_DIAG_READ = CTL.DIAG_READ_FUNC_13x;
    CON.LOAD_SPEC_INSTR = CTL.DISP_NICOND | CON_COND_SPEC_INSTR | CON.RESET;
    CON.VMA_SEL[1] = CON_COND_VMA_DEC | MCL_LOAD_VMA;
    CON.VMA_SEL[0] = CON_COND_VMA_INC | MCL_LOAD_VMA;
  end

  // CON2 p.159
  logic piReadyReg;
  logic legalReg;
  always_ff @(posedge CON_CLK) begin
    CON_MTR_INT_REQ <= MTR_INTERRUPT_REQ;
    piReadyReg <= PI.READY;
    CON.LONG_EN <= (~MCL_VMA_SECTION_0 & CON_COND_LONG_EN) |
                   (~MCL_MBOX_CYC_REQ & CON.LONG_EN & ~CON.RESET);
    legalReg <= CRAM.MAGIC[3] & CON.IO_LEGAL & CTL.SPEC_FLAG_CTL;
  end

  always_comb begin
    CON_INT_REQ = (CON_MTR_INT_REQ | piReadyReg) & (~CON_INT_DISABLE | CON.RESET);

    CON.LOAD_IR = CON_FETCH_CYCLE | CON.COND_LOAD_IR | CON_DIAG_IR_STROBE;
    CON.COND_INSTR_ABORT = CON_COND_SPEC_INSTR & CRAM.MAGIC[6];
    CON.CLR_PRIVATE_INSTR = CLK_PAGE_ERROR | CON.COND_INSTR_ABORT;
    CON.LOAD_ACCESS_COND = CON.COND_LOAD_IR | CON_COND_SR_MAGIC;

    CON_INSTR_GO = legalReg & ~CON_INSTR_GO & ~CON.RESET;
    CON.IO_LEGAL = IR.IO_LEGAL | CON_KERNEL_MODE | CON_KERNEL_CYCLE |
                   (SCD.USER & SCD.USER_IOT);
  end

  logic start0 = '0;
  logic start1, start2;
  always_comb start0 = CON_DIAG_CONTINUE | (~CON.START & ~start0 & ~CON.RESET);
  always_ff @(posedge CON_CLK) begin
    start1 <= start0;
    start2 = start1;
    CON.START <= start2;
  end

  logic run0 = '0;
  logic run1, run2;
  always_comb run0 = CON_DIAG_SET_RUN | (~CON_DIAG_CLR_RUN & ~run0 & ~CON.RESET);
  always_ff @(posedge CON_CLK) begin
    run1 <= run0;
    run2 <= run1;
    CON.RUN <= run2;
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
                       SCD.USER,
                       SCD.PUBLIC,
                       MB21_RD_PSE_WR,
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
                       MCL_VMA_SECTION_0,
                       VMA_AC_REF,
                       ~CON_MTR_INT_REQ}));
  always_comb begin
    CON.COND_ADR_10 = CON.SKIP_EN60_67 & skipEn6x |
                      CON.SKIP_EN70_77 & skipEn7x & CON.RESET;
  end
  
  logic [0:2] nicondPriority;
  priority_encoder nicondEncoder(.d({CON.PI_CYCLE,
                                     CON.RUN,
                                     CON_MTR_INT_REQ,
                                     CON_INT_REQ,
                                     CON.UCODE_STATE5,
                                     CON_VM_AC_REF,
                                     '0,
                                     CON.PI_CYCLE}),
                                    .q(nicondPriority));
  always_ff @(posedge CON_CLK) begin
    CON.NICOND_TRAP_EN <= nicondPriority[0];
    CON.NICOND[7:9] = nicondPriority;
    CON.EBUS_GRANT <= PI.EBUS_CP_GRANT;
    CON_PI_XFER <= PI.EXT_TRAN_REC;
  end

  always_ff @(posedge CON_CLK) begin
    CON_NICOND_OR_LOAD_IR_DELAYED <= CTL.DISP_NICOND | CON.COND_LOAD_IR;
  end
  
  always_comb begin
    CON.LOAD_DRAM = CON_DIAG_DRAM_STROBE | CON_NICOND_OR_LOAD_IR_DELAYED;
    CON_KERNEL_MODE = ~SCD.USER & ~SCD.PUBLIC;
  end


  // CON3 p. 160.
  always_ff @(posedge CON_CLK) begin
    CON.CONO_200000 <= CON.CONO_APR & EBUS.data[19];
  end

  always_ff @(posedge CON_CLK iff CON.CONO_PI) begin
    CON.WR_EVEN_PAR_ADR <= EBUS.data[18];
    CON_WR_EVEN_PAR_DATA <= EBUS.data[19];
    CON_WR_EVEN_PAR_DIR <= EBUS.data[20];
  end

  always_ff @(posedge CON_CLK iff CON.CONO_PAG) begin
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
  decoder func01x(.en(CON_MAGIC_FUNC_01x & ~CTL_CONSOLE_CONTROL),
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
    CON.CONO_APR = CLK_EBOX_SYNC & (CON.RESET | conoAPR);
    CON.CONO_PI = CLK_EBOX_SYNC & (CON.RESET | conoPI);
    CON.CONO_PAG = CON.RESET | conoPAG;
    CON.DATAO_APR = CON.RESET | dataoAPR;
  end

  always_comb begin
    CON.SEL_EN = EBUS.data[20] & CON.CONO_APR;
    CON.SEL_DIS = EBUS.data[21] & CON.CONO_APR;
    CON.SEL_CLR = EBUS.data[22] & CON.CONO_APR;
    CON.SEL_SET = EBUS.data[23] & CON.CONO_APR;

    CON.EBUS_REL = ~(CON.COND_EBUS_CTL & CRAM.MAGIC[2] & CLK_EBOX_SYNC);
  end

  always_ff @(posedge CON_CLK iff CON_COND_SR_MAGIC) begin
    CON.SR <= {CRAM.MAGIC[5:6],
               (CRAM.MAGIC[3] | CRAM.MAGIC[7]) & (CRAM.MAGIC[2] | CRAM.MAGIC[7]),
               (CRAM.MAGIC[4] | CRAM.MAGIC[8]) & (CRAM.MAGIC[3] | CRAM.MAGIC[7])};
  end

  // CTL4 p.161.
  always_comb begin
    CON.PI_DISABLE = ~CON.RUN | CON.EBOX_HALTED;
    CON.AR_36 = (CON_WR_EVEN_PAR_DATA | CON_AR_LOADED) &
                (CON_MBOX_DATA | CON_CSH_BIT_36 | CON_AR_FROM_MEM) &
                (CON_FM_DATA | CON_FM_BIT_36 | CON_AR_FROM_MEM) &
                (CON_AR_FROM_EBUS | CON_EBUS_BIT_36);
    CON.ARX_36 = (CON_MBOX_DATA | CON_CSH_BIT_36) &
                 (CON_FM_DATA | CON_FM_BIT_36);
  end

  always_ff @(posedge CON_CLK iff CON.LOAD_SPEC_INSTR) begin
    CON_KERNEL_CYCLE <= CRAM.MAGIC[1];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    CON_PXCT <= CRAM.MAGIC[4];
    CON_INT_DISABLE <= CRAM.MAGIC[5];

    CON.EBOX_HALTED <= CRAM.MAGIC[7];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    CON_SPEC8 <= CRAM.MAGIC[8]; // XXX not used?
  end

  always_ff @(posedge CON_CLK iff CON.COND_EBUS_STATE | CON.RESET) begin
    CON.UCODE_STATE1 <= (CRAM.MAGIC[2] | CRAM.MAGIC[1]) & (CON.UCODE_STATE1 | CRAM.MAGIC[1]);
    CON.UCODE_STATE3 <= (CRAM.MAGIC[4] | CRAM.MAGIC[3]) & (CON.UCODE_STATE3 | CRAM.MAGIC[3]);
    CON.UCODE_STATE5 <= (CRAM.MAGIC[6] | CRAM.MAGIC[5]) & (CON.UCODE_STATE5 | CRAM.MAGIC[5]);
    CON.UCODE_STATE7 <= (CRAM.MAGIC[8] | CRAM.MAGIC[7]) & (CON.UCODE_STATE7 | CRAM.MAGIC[7]);
  end

  always_ff @(posedge CON_CLK) begin
    CON_CSH_BIT_36 <= CSH_PAR_BIT_A | CSH_PAR_BIT_B;
    CON_FM_BIT_36 <= APR.FM_BIT_36;
    CON_EBUS_BIT_36 <= EBUS_PARITY_E;
    CON_MBOX_DATA <= CON.FM_XFER;
    CON_FM_DATA <= CON.MB_XFER;
  end

  always_comb begin
    CON_LOAD_AR_EN = MCL_LOAD_ARX | MCL_LOAD_AR;
    // WIRE-OR of negated signals! XXX (there are more I need to go fix)
    CON_AR_FROM_MEM = ~(~CON_LOAD_AR_EN | ~CON_XFER | ~CLK_PAGE_ERROR);
  end
  

  always_ff @(posedge CON_CLK) begin
    CON_AR_FROM_EBUS <= CTL.EBUS_XFER & EBUS_PARITY_ACTIVE_E;
    CON_ARX_LOADED <= CON_XFER & ~CON.FM_XFER & ~CLK_PAGE_ERROR & MCL_LOAD_ARX;
    CON_AR_LOADED <= CON_AR_FROM_MEM | CON_AR_FROM_EBUS;
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
    CON_CLR_PI_CYCLE = (CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE & CLK_EBOX_SYNC) |
                       specFlagMagic2;
    CON_PI_DISMISS = specFlagMagic2 & ~CON.PI_CYCLE & ~CLK_EBOX_SYNC;

    waitingACStore = MCL_STORE_AR & CON_MBOX_WAIT & VMA_AC_REF;
    cond345_1s = CRAM.COND[3:5] === 3'b111;
    CON.FM_WRITE00_17 = (cond345_1s & CON.COND_EN10_17) | waitingACStore;
    CON.FM_WRITE18_35 = CON.FM_WRITE00_17;
    CON.FM_WRITE_PAR = ~CLK_SBR_CALL & ~CON_CLK;

    CON_MBOX_WAIT = CRAM.MEM[2] & CON_MEM_CYCLE;
    CON.FM_XFER = CRAM.MEM[2] & CON_MEM_CYCLE & VMA_AC_REF;
    CON_FETCH_CYCLE = MCL_VMA_FETCH & CON_MEM_CYCLE;
  end

  always_ff @(posedge CON_CLK) begin
    CON.PI_CYCLE <= (CON_COND_SPEC_INSTR & CRAM.MAGIC[0]) |
                    (~MCL_SKIP_SATISFIED & ~CON_CLR_PI_CYCLE & ~CON.RESET & CON.PI_CYCLE);
    CON_MEM_CYCLE <= MCL_MBOX_CYC_REQ |
                     (CON_MEM_CYCLE & ~CON_XFER & ~CLK_PAGE_ERROR & ~CON.RESET);
  end
endmodule // con
