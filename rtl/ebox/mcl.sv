`timescale 1ns/1ns
`include "ebox.svh"

// M8544 MCL
module mcl(iEBUS EBUS,
           iCRAM CRAM,
           iMCL MCL,
           iVMA VMA
);

  assign MCL.EBUSdriver.driving = '0; // XXX temporary
  assign MCL.ADR_ERR = '0;            // XXX temporary

  // MCL1 p.371
  logic [4:6] DS;
  logic DIAG_READ;
  logic AREAD_EA, Aeq001;
  logic MEM_AREAD, MEM_WR_CYCLE, MEM_RPW_CYCLE, MEM_COND_FETCH;
  logic MEM_AD_FUNC, MEM_EA_CALC, MEM_LOAD_AR, MEM_LOAD_ARX;
  logic MEM_RW_CYCLE, MEM_RPW_CYCLE, MEM_WRITE, MEM_UNCOND_FETCH;
  logic VMA_READ, VMA_READ_OR_WRITE;

  assign DS = CTL.DIAG[4:6];
  assign DIAG_READ = CTL.DIAG_READ_FUNC_10x;

  logic ignoredE70;
  decoder e70(.en(~CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({ignoredE70, MEM_ARL_IND, MEM_MB_WAIT,
                  MEM_RESTORE_VMA, MEM_AREAD, MEM_B_WRITE,
                  MEM_COND_FETCH, MEM_REG_FUNC}));

  // E64 is redundant acive low drive of mostly the same signals.
  // It is elided.

  decoder e72(.en(~CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({MEM_AD_FUNC, MEM_EA_CALC, MEM_LOAD_AR,
                  MEM_LOAD_ARX, MEM_RW_CYCLE, MEM_RPW_CYCLE,
                  MEM_WRITE, MEM_UNCOND_FETCH}));

  assign AREAD_EA = MEM_AREAD & ~Aeq001;

  mux  e6(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[1], VMA.HELD_OR_PC[7], VMA_READ, VMA_PAUSE,
              VMA_WRITE, MCL.LOAD_AR, MCL.LOAD_ARX, MCL.STORE_AR}),
          .q(MCL.EBUSdriver.data[18]));

  mux e11(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[2], VMA.HELD_OR_PC[8], MEM_ARL_IND, ~REQ_EN,
              VMA_USER, VMA_PUBLIC, ~VMA_PREVIOUS, ~VMA_EXTENDED}),
          .q(MCL.EBUSdriver.data[19]));

  mux e16(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[3], VMA.HELD_OR_PC[9], PAGE_TEST_PRIVATE, VMA_UPT,
              MCL.PAGE_UEBR_REF, PAGE_ADDRESS_COND, PAGE_ILL_ENTRY, MCL.VMA_FETCH}),
          .q(MCL.EBUSdriver.data[20]));

  mux e26(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[4], VMA.HELD_OR_PC[10], XR_PREVIOUS, VMA_ADR_EPR,
              ~MCL.VMAX_EN, MCL.VMAX_SEL, ~MCL.PAGED_FETCH}),
          .q(MCL.EBUSdriver.data[21]));

  mux e36(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[5], VMA.HELD_OR_PC[11], MCL.VMA_AD, MCL.VMA_INC,
              ~MCL.LOAD_VMA_CONTEXT, MCL._23_BIT_EA, MCL._18_BIT_EA,
              MCL.MBOX_CYC_REQ}),
          .q(MCL.EBUSdriver.data[22]));

  mux e27(.en(DIAG_READ),
          .sel(ds),
          .d({VMA.HELD_OR_PC[6], VMA.HELD_OR_PC[12], XP_SHORT, MCL.SHORT_STACK,
              ~MCL.EBOX_CACHE, ~MCL.EBOX_MAY_BE_PAGED, EBOX_REG_FUNC,
              ~MCL.EBOX_MAP}),
          .q(MCL.EBUSdriver.data[23]));

  // MCL2 p.372
  logic [0:3] gatedMagic, gatedAD, e13SR;

  always_comb begin
    gatedMagic = {4{MEM_EA_CALC}} & CRAM.MAGIC[0:3];
    gatedAD = {4{MEM_AD_FUNC}} & EDP.AD[1:4];
    VMA_READ = |e13SR[0:1];
    VMA_READ_OR_WRITE = e13SR[0] | e13SR[1] | e13SR[3];
    MCL.LOAD_AR = e13SR[0];
    MCL.LOAD_ARX = e13SR[1];
    MCL.VMA_PAUSE = e13SR[2];
    MCL.VMA_WRITE = e13SR[3];
    MCL.STORE_AR = e13SR[2] & ~MCL.LOAD_AR & ~MCL.LOAD_ARX & MCL.VMA_WRITE;
  end

  always_ff @(posedge clk) begin

    if (REQ_EN) begin
      e13SR[0] <= gatedMagic | gatedAD | AREAD_1xx | MEM_LOAD_AR | RW_OR_RPW_CYCLE;
      e13SR[1] <= gatedMagic | gatedAD | FETCH_EN | MEM_LOAD_ARX;
      e13SR[2] <= gatedMagic | gatedAD | AREAD_x11 | MEM_RPW_CYCLE;
      e13SR[3] <= gatedMagic | gatedAD | AREAD_3_6_7 | MEM_B_WRITE |
                  RW_OR_RPW_CYCLE | MEM_WRITE;
    end
  end

  always_comb begin
    USER_EN = MCL.VMA_PREV_EN & USER_IOT |
              USER & (KERNEL_CYCLE | FETCH_EN) & ~SPEC_EXEC |
              SPEC_SP_MEM_CYCLE & CRAM.MAGIC[1] & ~SPEC_EXEC |
              LOAD_AD_FUNC & EDP.AD[5];
    PUBLIC_EN = ~MCL.VMA_PREV_EN & (KERNEL_CYCLE | FETCH_EN) & PUBLIC |
                PCP & ~USER & MCL.VMA_PREV_EN |
                USER & PUBLIC & MCL.VMA_PREV_EN |
                LOAD_AD_FUNC & EDP.AD[6];
  end

  logic [0:3] e14SR;
  always_ff @(posedge clk) begin

    if (MCL.LOAD_VMA_CONTEXT) begin
      e14SR <= {USER_EN PUBLIC_EN, MCL.VMA_PREV_EN, MCL.VMA_EXT_EN};
    end
  end

  always_comb begin
    MCL.VMA_USER = e14SR[0] & ~REG_FUNC;
    MCL.VMA_PUBLIC = e14SR[1] & ~REG_FUNC;
    MCL.VMA_PREVIOUS = e14SR[2] & ~REG_FUNC;
    MCL.VMA_EXTENDED = e14SR[3];
    MCL.VMA_USER = e14SR[3] & ~REG_FUNC;
  end


  // MCL3 p.373
  logic UPT_EN, EPT_EN, SPEC_EXEC;

  always_comb begin
    UPT_EN = SPEC_SP_MEM_CYCLE & USER_EN & CRAM.MAGIC[4];
    EPT_EN = SPEC_SP_MEM_CYCLE & ~USER_EN & CRAM.MAGIC[5];
    SPEC_EXEC = SPEC_SP_MEM_CYCLE & CRAM.MAGIC[2];
  end
endmodule // mcl
