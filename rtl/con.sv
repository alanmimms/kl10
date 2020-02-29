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
           iPI PI,
           iSCD SCD,
           iVMA VMA,

           iEBUS EBUS);

  bit conCLK;
  bit DIAG_READ;

  bit WR_EVEN_PAR_DATA;
  bit WR_EVEN_PAR_DIR;
  bit INSTR_GO;
  bit INT_DISABLE;
  bit INT_REQ;
  bit MTR_INT_REQ;
  bit MEM_CYCLE;
  bit FETCH_CYCLE;
  bit DIAG_IR_STROBE;
  bit KERNEL_MODE;
  bit KERNEL_CYCLE;
  bit DIAG_DRAM_STROBE;
  bit NICOND_OR_LOAD_IR_DELAYED;
  bit KL10_PAGING_EN;
  bit PI_XFER;
  bit XFER;
  bit PXCT;
  bit SPEC8;
  bit MBOX_DATA;
  bit FM_DATA;
  bit FM_BIT_36;
  bit CSH_BIT_36;
  bit EBUS_BIT_36;
  bit AR_FROM_MEM;
  bit LOAD_AR_EN;
  bit PI_DISMISS;

  bit DIAG_CLR_RUN;
  bit DIAG_SET_RUN;
  bit DIAG_CONTINUE;
  bit MAGIC_FUNC_02x;
  bit LOAD_AC_BLOCKS;
  bit LOAD_PREV_CONTEXT;
  bit MAGIC_FUNC_01x;
  bit MAGIC_FUNC_04x;
  bit MAGIC_FUNC_05x;
  bit MAGIC_FUNC_010;
  bit MAGIC_FUNC_011;


  assign conCLK = CLK.CON;
  assign CON.RESET = CLK.MR_RESET;

  initial begin
    CON.AR_LOADED = '0;
    CON.ARX_LOADED = '0;

    CON.START = '0;
    CON.RUN = '0;

    CON.AR_FROM_EBUS = '0;
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

  bit [0:4] condVMAmagic;
  decoder cond30_decoder(.en(CON.COND_EN_30_37),
                         .sel(CRAM.COND[3:5]),
                         .q({condVMAmagic,
                             CON.COND_VMA_DEC,
                             CON.COND_VMA_INC,
                             CON.COND_LOAD_VMA_HELD}));

  assign CON.COND_VMA_MAGIC = |condVMAmagic;

  // EBUS
  assign CON.EBUSdriver.driving = DIAG_READ;
  mux ebus18mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
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
                .en(DIAG_READ),
                .q(EBUS.data[19]),
                .d({WR_EVEN_PAR_DATA,
                    CON.CACHE_LOAD_EN,
                    ~CON.COND_SEL_VMA,
                    CON.COND_VMA_MAGIC,
                    CON.COND_LOAD_VMA_HELD,
                    ~CON.LOAD_SPEC_INSTR,
                    ~CON.VMA_SEL}));

  bit ebus20mux_nothing = '0;
  mux ebus20mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
                .q(EBUS.data[20]),
                .d({WR_EVEN_PAR_DIR,
                    ebus20mux_nothing,
                    ~CON.COND_MBOX_CTL,
                    CON.EBUS_REL,
                    CON.SR}));

  bit ebus21mux_nothing = '0;
  mux ebus21mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
                .q(EBUS.data[21]),
                .d({ebus21mux_nothing,
                    ~CON.KI10_PAGING_MODE,
                    ~CON.LONG_EN,
                    ~CON.PCplus1_INH,
                    CON.NICOND_TRAP_EN,
                    CON.NICOND[7:9]}));

  bit ebus22mux_nothing = '0;
  mux ebus22mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
                .q(EBUS.data[22]),
                .d({ebus22mux_nothing,
                    CON.TRAP_EN,
                    ~CON.LOAD_IR,
                    CON.COND_INSTR_ABORT,
                    CON.LOAD_ACCESS_COND,
                    ~INSTR_GO,
                    CON.LOAD_DRAM,
                    CON.COND_ADR_10}));

  bit [0:1] ebus23mux_nothing = '0;
  mux ebus23mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
                .q(EBUS.data[23]),
                .d({ebus23mux_nothing,
                    CON.AR_LOADED,
                    ~CON.ARX_LOADED,
                    CON.UCODE_STATE1,
                    CON.UCODE_STATE3,
                    CON.UCODE_STATE5,
                    CON.UCODE_STATE7}));

  bit [0:1] ebus24mux_nothing = '0;
  mux ebus24mux(.sel(CTL.DIAG[4:6]),
                .en(DIAG_READ),
                .q(EBUS.data[24]),
                .d({ebus24mux_nothing,
                    CON.PI_CYCLE,
                    ~MEM_CYCLE,
                    ~CON.FM_WRITE_PAR,
                    ~CON.MBOX_WAIT,
                    ~CON.FM_XFER,
                    ~PI_DISMISS}));

  // CON1 miscellaneous controls
  always_comb begin
    DIAG_READ = CTL.DIAG_READ_FUNC_13x;
    CON.LOAD_SPEC_INSTR = CTL.DISP_NICOND | CON.COND_SPEC_INSTR | CON.RESET;
    CON.VMA_SEL[1] = CON.COND_VMA_DEC | MCL.LOAD_VMA;
    CON.VMA_SEL[0] = CON.COND_VMA_INC | MCL.LOAD_VMA;
  end

  // CON2 p.159
  bit piReadyReg;
  bit legalReg;
  always_ff @(posedge conCLK) begin
    MTR_INT_REQ <= MTR.INTERRUPT_REQ;
    piReadyReg <= PI.READY;
    CON.LONG_EN <= (~MCL.VMA_SECTION_0 & CON.COND_LONG_EN) |
                   (~MCL.MBOX_CYC_REQ & CON.LONG_EN & ~CON.RESET);
    legalReg <= CRAM.MAGIC[3] & CON.IO_LEGAL & CTL.SPEC_FLAG_CTL;
  end

  always_comb begin
    INT_REQ = (MTR_INT_REQ | piReadyReg) & (~INT_DISABLE | CON.RESET);

    CON.LOAD_IR = FETCH_CYCLE | CON.COND_LOAD_IR | DIAG_IR_STROBE;
    CON.COND_INSTR_ABORT = CON.COND_SPEC_INSTR & CRAM.MAGIC[6];
    CON.CLR_PRIVATE_INSTR = CLK.PAGE_ERROR | CON.COND_INSTR_ABORT;
    CON.LOAD_ACCESS_COND = CON.COND_LOAD_IR | CON.COND_SR_MAGIC;

    INSTR_GO = legalReg & ~INSTR_GO & ~CON.RESET;
    CON.IO_LEGAL = IR.IO_LEGAL | KERNEL_MODE | KERNEL_CYCLE |
                   (SCD.USER & SCD.USER_IOT);
  end

  bit start0 = '0;
  bit start1, start2;
  always_comb start0 = DIAG_CONTINUE | (~CON.START & ~start0 & ~CON.RESET);
  always_ff @(posedge conCLK) begin
    start1 <= start0;
    start2 = start1;
    CON.START <= start2;
  end

  bit run0 = '0;
  bit run1, run2;
  always_comb run0 = DIAG_SET_RUN | (~DIAG_CLR_RUN & ~run0 & ~CON.RESET);
  always_ff @(posedge conCLK) begin
    run1 <= run0;
    run2 <= run1;
    CON.RUN <= run2;
  end

  bit runStateNC1, runStateNC2, runStateNC3;
  decoder runStateDecoder(.en(CTL.DIAG_CTL_FUNC_01x),
                          .sel(EBUS.ds[4:6]),
                          .q({DIAG_CLR_RUN,
                              DIAG_SET_RUN,
                              DIAG_CONTINUE,
                              runStateNC1,
                              DIAG_IR_STROBE,
                              DIAG_DRAM_STROBE,
                              runStateNC2,
                              runStateNC3}));

  bit skipEn6x, skipEn7x;
  mux skipEn6x_mux(.sel(CRAM.COND[3:5]),
                   .en('1),
                   .q(skipEn6x),
                   .d({MCL.VMA_FETCH,
                       KERNEL_MODE,
                       SCD.USER,
                       SCD.PUBLIC,
                       MBZ.RD_PSE_WR,
                       CON.PI_CYCLE,
                       ~CON.EBUS_GRANT,
                       ~PI_XFER}));
  mux skipEn7x_mux(.sel(CRAM.COND[3:5]),
                   .en('1),
                   .q(skipEn7x),
                   .d({INT_REQ,
                       ~CON.START,
                       CON.RUN,
                       CON.IO_LEGAL,
                       PXCT,
                       MCL.VMA_SECTION_0,
                       VMA.AC_REF,
                       ~MTR_INT_REQ}));
  always_comb begin
    CON.COND_ADR_10 = CON.SKIP_EN_60_67 & skipEn6x |
                      CON.SKIP_EN_70_77 & skipEn7x & CON.RESET;
  end
  
  bit [0:2] nicondPriority;
  priority_encoder8 nicondEncoder(.d({CON.PI_CYCLE,
                                      CON.RUN,
                                      MTR_INT_REQ,
                                      INT_REQ,
                                      CON.UCODE_STATE5,
                                      ~VMA.AC_REF,
                                      '0,
                                      CON.PI_CYCLE}),
                                  .q(nicondPriority));
  always_ff @(posedge conCLK) begin
    CON.NICOND_TRAP_EN <= nicondPriority[0];
    CON.NICOND[7:9] = nicondPriority;
    CON.EBUS_GRANT <= PI.EBUS_CP_GRANT;
    PI_XFER <= PI.EXT_TRAN_REC;
  end
  // XXX This is a guess
  assign CON.NICOND[10] = CON.NICOND_TRAP_EN;

  always_ff @(posedge conCLK) begin
    NICOND_OR_LOAD_IR_DELAYED <= CTL.DISP_NICOND | CON.COND_LOAD_IR;
  end
  
  always_comb begin
    CON.LOAD_DRAM = DIAG_DRAM_STROBE | NICOND_OR_LOAD_IR_DELAYED;
    KERNEL_MODE = ~SCD.USER & ~SCD.PUBLIC;
  end


  // CON3 p. 160.
  always_ff @(posedge conCLK) begin
    CON.CONO_200000 <= CON.CONO_APR & EBUS.data[19];
  end

  initial begin
    CON.WR_EVEN_PAR_ADR = '0;
/*
    WR_EVEN_PAR_DATA = '0;
    WR_EVEN_PAR_DIR = '0;
*/
  end

  always_ff @(posedge conCLK, posedge CLK.CROBAR) begin

    if (CON.CONO_PI) begin
      CON.WR_EVEN_PAR_ADR <= EBUS.data[18];
      WR_EVEN_PAR_DATA <= EBUS.data[19];
      WR_EVEN_PAR_DIR <= EBUS.data[20];
    end else if (CLK.CROBAR) begin
      CON.WR_EVEN_PAR_ADR <= '0;
      WR_EVEN_PAR_DATA <= '0;
      WR_EVEN_PAR_DIR <= '0;
    end
  end

  always_ff @(posedge conCLK iff CON.CONO_PAG) begin
    CON.CACHE_LOOK_EN <= EBUS.data[18];
    CON.CACHE_LOAD_EN <= EBUS.data[19];
    KL10_PAGING_EN <= EBUS.data[21];
    CON.TRAP_EN <= EBUS.data[22];
  end

  assign CON.KI10_PAGING_MODE = ~KL10_PAGING_EN;

  mux #(.N(4)) acbmux(.en(~CON.RESET),
                      .sel({MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({~EBUS.data[18],
                          CRAM.MAGIC[7],
                          MAGIC_FUNC_02x,
                          MAGIC_FUNC_02x}),
                      .q(LOAD_AC_BLOCKS));
  mux #(.N(4)) pcxmux(.en(~CON.RESET),
                      .sel({MAGIC_FUNC_02x, CRAM.MAGIC[6]}),
                      .d({~EBUS.data[19],
                          CRAM.MAGIC[8],
                          ~MAGIC_FUNC_02x,
                          ~MAGIC_FUNC_02x}),
                      .q(LOAD_PREV_CONTEXT));

  assign CON.DELAY_REQ = CON.COND_DIAG_FUNC & CRAM.MAGIC[3];

  bit func0xxNC1, func0xxNC2, func0xxNC3, func0xxNC4;
  decoder func0xx(.en(~CRAM.MAGIC[2] & CON.COND_DIAG_FUNC),
                  .sel(CRAM.MAGIC[3:5]),
                  .q({func0xxNC1,
                      MAGIC_FUNC_01x,
                      MAGIC_FUNC_02x,
                      func0xxNC2,
                      MAGIC_FUNC_04x,
                      MAGIC_FUNC_05x,
                      func0xxNC3,
                      func0xxNC4}));

  bit func01xNC1, func01xNC2;
  bit conoAPR, conoPI, conoPAG, dataoAPR;
  decoder func01x(.en(MAGIC_FUNC_01x & ~CTL.CONSOLE_CONTROL),
                  .sel(CRAM.MAGIC[6:8]),
                  .q({MAGIC_FUNC_010,
                      MAGIC_FUNC_011,
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

  // CON4 p.161.
  always_comb begin
    CON.PI_DISABLE = ~CON.RUN | CON.EBOX_HALTED;
    CON.AR_36 = (~WR_EVEN_PAR_DATA | CON.AR_LOADED) &
                (~MBOX_DATA | CSH_BIT_36 | ~AR_FROM_MEM) &
                (~FM_DATA | FM_BIT_36 | ~AR_FROM_MEM) &
                (~CON.AR_FROM_EBUS | EBUS_BIT_36);
    CON.ARX_36 = (~MBOX_DATA | CSH_BIT_36) &
                 (~FM_DATA | FM_BIT_36);
  end

  always_ff @(posedge conCLK iff CON.LOAD_SPEC_INSTR) begin
    KERNEL_CYCLE <= CRAM.MAGIC[1];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    PXCT <= CRAM.MAGIC[4];
    INT_DISABLE <= CRAM.MAGIC[5];

    CON.EBOX_HALTED <= CRAM.MAGIC[7];
    CON.PCplus1_INH <= CRAM.MAGIC[2];
    SPEC8 <= CRAM.MAGIC[8]; // XXX not used?
  end

  always_ff @(posedge conCLK iff CON.COND_EBUS_STATE | CON.RESET) begin
    CON.UCODE_STATE1 <= (CRAM.MAGIC[2] | CRAM.MAGIC[1]) & (CON.UCODE_STATE1 | CRAM.MAGIC[1]);
    CON.UCODE_STATE3 <= (CRAM.MAGIC[4] | CRAM.MAGIC[3]) & (CON.UCODE_STATE3 | CRAM.MAGIC[3]);
    CON.UCODE_STATE5 <= (CRAM.MAGIC[6] | CRAM.MAGIC[5]) & (CON.UCODE_STATE5 | CRAM.MAGIC[5]);
    CON.UCODE_STATE7 <= (CRAM.MAGIC[8] | CRAM.MAGIC[7]) & (CON.UCODE_STATE7 | CRAM.MAGIC[7]);
  end

  always_ff @(posedge conCLK) begin
    CSH_BIT_36 <= CSH.PAR_BIT_A | CSH.PAR_BIT_B;
    FM_BIT_36 <= APR.FM_BIT_36;
    EBUS_BIT_36 <= EBUS.parity;
    MBOX_DATA <= CON.FM_XFER;
    FM_DATA <= CLK.MB_XFER;
  end

  always_comb begin
    LOAD_AR_EN = MCL.LOAD_ARX | MCL.LOAD_AR;
    // WIRE-OR of negated signals! XXX (there are more I need to go fix)
    AR_FROM_MEM = ~(~LOAD_AR_EN | ~XFER | ~CLK.PAGE_ERROR);
  end
  

  always_ff @(posedge conCLK) begin
    CON.AR_FROM_EBUS <= CTL.EBUS_XFER & EBUS.parity;
    CON.ARX_LOADED <= XFER & ~CON.FM_XFER & ~CLK.PAGE_ERROR & MCL.LOAD_ARX;
    CON.AR_LOADED <= AR_FROM_MEM | CON.AR_FROM_EBUS;
  end

  // CON5 p.162
  bit cond345_1s;
  bit specFlagMagic2;
  bit waitingACStore;
  bit PI_CYCLE_IN;
  bit MEM_CYCLE_IN;
  bit CLR_PI_CYCLE;
  always_comb begin
    PI_CYCLE_IN = CON.PI_CYCLE;
    MEM_CYCLE_IN = MEM_CYCLE;
    XFER = CON.FM_XFER | CLK.MB_XFER;

    specFlagMagic2 = (CTL.SPEC_FLAG_CTL & CRAM.MAGIC[2]);
    CLR_PI_CYCLE = (CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE & CLK.EBOX_SYNC) |
                       specFlagMagic2;
    PI_DISMISS = specFlagMagic2 & ~CON.PI_CYCLE & ~CLK.EBOX_SYNC;

    waitingACStore = MCL.STORE_AR & CON.MBOX_WAIT & VMA.AC_REF;
    cond345_1s = CRAM.COND[3:5] == 3'b111;
    CON.FM_WRITE00_17 = (cond345_1s & CON.COND_EN_10_17) | waitingACStore;
    CON.FM_WRITE18_35 = CON.FM_WRITE00_17;
    CON.FM_WRITE_PAR = ~CLK.SBR_CALL & ~conCLK;

    CON.MBOX_WAIT = CRAM.MEM[2] & MEM_CYCLE;
    CON.FM_XFER = CRAM.MEM[2] & MEM_CYCLE & VMA.AC_REF;
    FETCH_CYCLE = MCL.VMA_FETCH & MEM_CYCLE;
  end

  always_ff @(posedge conCLK) begin
    CON.PI_CYCLE <= (CON.COND_SPEC_INSTR & CRAM.MAGIC[0]) |
                    (~MCL.SKIP_SATISFIED & ~CLR_PI_CYCLE & ~CON.RESET & CON.PI_CYCLE);
    MEM_CYCLE <= MCL.MBOX_CYC_REQ |
                     (MEM_CYCLE & ~XFER & ~CLK.PAGE_ERROR & ~CON.RESET);
  end
endmodule // con
