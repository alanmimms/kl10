`timescale 1ns/1ns
`include "ebox.svh"

// M8544 MCL
module mcl(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCRC CRC,
           iCTL CTL,
           iEBUS.mod EBUS,
           iEDP EDP,
           iIR IR,
           iPI PIC,
           iMCL MCL,
           iSCD SCD,
           iVMA VMA
);

  bit clk;
  assign clk = CLK.MCL;

  // MCL1 p.371
  bit [4:6] DS;
  bit DIAG_READ;
  bit MEM_AREAD, MEM_WR_CYCLE, MEM_RPW_CYCLE, MEM_COND_FETCH;
  bit MEM_AD_FUNC, MEM_EA_CALC, MEM_LOAD_AR, MEM_LOAD_ARX;
  bit MEM_RW_CYCLE, MEM_WRITE, MEM_UNCOND_FETCH;
  bit LOAD_AD_FUNC, LOAD_VMA_HELD;
  bit AREAD_EA, RW_OR_RPW_CYCLE, MEM_COND_JUMP;
  bit USER_EN, PUBLIC_EN, VMA_EXT_EN;
  bit VMA_AD, VMAslashAD, AD_FUNC_08, AD_FUNC_09;
  bit AREAD_3_6_7, AREAD_001, AREAD_x11, Aeq0x0, Aeq001, AREAD_1xx;
  bit EA_PREVIOUS, EA_EXTENDED, FETCH_EN, FETCH_EN_IN;
  bit USER, USER_IOT, PUBLIC, KERNEL_CYCLE;
  bit UPT_EN, EPT_EN, SPEC_EXEC;
  bit PAGE_ILL_ENTRY, USER_COMP;
  bit WRITE_01;
  bit REG_FUNC, MAP_FUNC, SPEC_SP_MEM_CYCLE, AD_LONG_EN, VMA_LONG_EN;
  bit AREAD_EN, XR_SHORT, PXCT, ADR_ERR, SP_MEM_CYCLE;
  bit VMA_PREVIOUS, PC_SECTION_0, PCS_SECTION_0, VMA_SECTION_0;
  bit EBOX_CACHE, EBOX_PAGING_EN;
  bit PAGED_FETCH, PHYS_REF;
  bit MEM_ARL_IND, MEM_MB_WAIT, MEM_RESTORE_VMA, MEM_B_WRITE;
  bit VMA_PAUSE, VMA_WRITE, XP_SHORT, EBOX_REG_FUNC;
  bit PXCT_B09, PXCT_B10, PXCT_B11, PXCT_B12, MEM_REG_FUNC;

  bit RESET;                  // XXX not yet initialized

  assign DS = CTL.DIAG[4:6];
  assign DIAG_READ = EDP.DIAG_READ_FUNC_10x;

  assign AREAD_EA = MEM_AREAD & ~Aeq001;
  assign RW_OR_RPW_CYCLE = MEM_RW_CYCLE | MEM_RPW_CYCLE;
  assign MEM_COND_JUMP = CRAM.MAGIC[5] & MEM_COND_FETCH;
  assign MCL.REQ_EN = (WRITE_01 | ~MEM_B_WRITE) &
                      (CRAM.MEM[0] | CRAM.MEM[1] | RESET);
  assign LOAD_AD_FUNC = MEM_RESTORE_VMA | MEM_AD_FUNC;
  assign LOAD_VMA_HELD = CON.COND_LOAD_VMA_HELD | CRAM.MEM[2];

  bit ignoredE70;
  decoder e70(.en(~CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({ignoredE70, MEM_ARL_IND, MEM_MB_WAIT,
                  MEM_RESTORE_VMA, MEM_AREAD, MEM_B_WRITE,
                  MEM_COND_FETCH, MEM_REG_FUNC}));

  // E64 is redundant acive low drive of mostly the same signals.
  // It is elided here.

  decoder e72(.en(CRAM.MEM[0]),
              .sel(CRAM.MEM[1:3]),
              .q({MEM_AD_FUNC, MEM_EA_CALC, MEM_LOAD_AR,
                  MEM_LOAD_ARX, MEM_RW_CYCLE, MEM_RPW_CYCLE,
                  MEM_WRITE, MEM_UNCOND_FETCH}));

  mux  e6(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[1], VMA.HELD_OR_PC[7], MCL.VMA_READ, VMA_PAUSE,
              VMA_WRITE, MCL.LOAD_AR, MCL.LOAD_ARX, MCL.STORE_AR}),
          .q(MCL.EBUSdriver.data[18]));

  mux e11(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[2], VMA.HELD_OR_PC[8], MEM_ARL_IND, ~MCL.REQ_EN,
              MCL.VMA_USER, MCL.VMA_PUBLIC, ~MCL.VMA_PREVIOUS, ~MCL.VMA_EXTENDED}),
          .q(MCL.EBUSdriver.data[19]));

  mux e16(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[3], VMA.HELD_OR_PC[9], MCL.PAGE_TEST_PRIVATE, MCL.VMA_UPT,
              MCL.PAGE_UEBR_REF, MCL.PAGE_ADDRESS_COND, PAGE_ILL_ENTRY, MCL.VMA_FETCH}),
          .q(MCL.EBUSdriver.data[20]));

  mux e26(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[4], VMA.HELD_OR_PC[10], MCL.XR_PREVIOUS, MCL.VMA_ADR_ERR,
              ~MCL.VMAX_EN, MCL.VMAX_SEL, ~MCL.PAGED_FETCH}),
          .q(MCL.EBUSdriver.data[21]));

  mux e36(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[5], VMA.HELD_OR_PC[11], MCL.VMA_AD, MCL.VMA_INC,
              ~MCL.LOAD_VMA_CONTEXT, MCL._23_BIT_EA, MCL._18_BIT_EA,
              MCL.MBOX_CYC_REQ}),
          .q(MCL.EBUSdriver.data[22]));

  mux e27(.en(DIAG_READ),
          .sel(DS),
          .d({VMA.HELD_OR_PC[6], VMA.HELD_OR_PC[12], XP_SHORT, MCL.SHORT_STACK,
              ~MCL.EBOX_CACHE, ~MCL.EBOX_MAY_BE_PAGED, EBOX_REG_FUNC,
              ~MCL.EBOX_MAP}),
          .q(MCL.EBUSdriver.data[23]));

  // MCL2 p.372
  bit [0:3] gatedMagic, e13SR;
  bit [1:4] gatedAD;

  assign gatedMagic = {4{MEM_EA_CALC}} & CRAM.MAGIC[0:3];
  assign gatedAD = {4{MEM_AD_FUNC}} & EDP.AD[1:4];
  assign MCL.VMA_READ = |e13SR[0:1];
  assign MCL.VMA_READ_OR_WRITE = e13SR[0] | e13SR[1] | e13SR[3];
  assign MCL.LOAD_AR = e13SR[0];
  assign MCL.LOAD_ARX = e13SR[1];
  assign MCL.VMA_PAUSE = e13SR[2];
  assign MCL.VMA_WRITE = e13SR[3];
  assign MCL.STORE_AR = e13SR[2] & ~MCL.LOAD_AR & ~MCL.LOAD_ARX & MCL.VMA_WRITE;

  always_ff @(posedge clk) if (MCL.REQ_EN) begin
    e13SR[0] <= gatedMagic[0] | gatedAD[1] | AREAD_1xx   | MEM_LOAD_AR | RW_OR_RPW_CYCLE;
    e13SR[1] <= gatedMagic[1] | gatedAD[2] | FETCH_EN    | MEM_LOAD_ARX;
    e13SR[2] <= gatedMagic[2] | gatedAD[3] | AREAD_x11   | MEM_RPW_CYCLE;
    e13SR[3] <= gatedMagic[3] | gatedAD[4] | AREAD_3_6_7 | MEM_B_WRITE |
                RW_OR_RPW_CYCLE | MEM_WRITE;
  end

  assign USER_EN = MCL.VMA_PREV_EN & USER_IOT |
                   USER & (KERNEL_CYCLE | FETCH_EN) & ~SPEC_EXEC |
                   SPEC_SP_MEM_CYCLE & CRAM.MAGIC[1] & ~SPEC_EXEC |
                   LOAD_AD_FUNC & EDP.AD[5];
  assign PUBLIC_EN = ~MCL.VMA_PREV_EN & (KERNEL_CYCLE | FETCH_EN) & PUBLIC |
                     SCD.PCP & ~USER & MCL.VMA_PREV_EN |
                     USER & PUBLIC & MCL.VMA_PREV_EN |
                     LOAD_AD_FUNC & EDP.AD[6];

  bit [0:3] e14SR;
  always_ff @(posedge clk) if (MCL.LOAD_VMA_CONTEXT)
    e14SR <= {USER_EN, PUBLIC_EN, MCL.VMA_PREV_EN, VMA_EXT_EN};

  assign MCL.VMA_EXEC = e14SR[0];
  assign MCL.VMA_USER = e14SR[0] & ~REG_FUNC;
  assign MCL.VMA_PUBLIC = e14SR[1] & ~REG_FUNC;
  assign MCL.VMA_PREVIOUS = e14SR[2] & ~REG_FUNC;
  assign MCL.VMA_EXTENDED = e14SR[3];


  // MCL3 p.373
  bit e5pin3;

  assign UPT_EN = SPEC_SP_MEM_CYCLE & USER_EN & CRAM.MAGIC[4];
  assign EPT_EN = SPEC_SP_MEM_CYCLE & ~USER_EN & CRAM.MAGIC[5];
  assign SPEC_EXEC = SPEC_SP_MEM_CYCLE & CRAM.MAGIC[2];

  assign e5pin3 = (APR.FETCH_COMP & MCL.VMA_FETCH |
                   APR.WRITE_COMP & VMA_WRITE |
                   APR.READ_COMP & ~MCL.VMA_FETCH & MCL.VMA_READ) &
                  (~MCL.VMA_USER | USER_COMP) &
                  (MCL.VMA_USER | ~USER_COMP) &
                  ~SCD.ADR_BRK_PREVENT & ~MAP_FUNC & ~REG_FUNC;

  assign MCL.PAGE_ADDRESS_COND = VMA.MATCH_13_35 & e5pin3 |
                                 MCL.VMA_ADR_ERR & ~RESET;

  assign PAGE_ILL_ENTRY = e5pin3 & VMA.MATCH_13_35 & EBOX_PAGING_EN |
                          SCD.PRIVATE_INSTR & PUBLIC |
                          MCL.VMA_ADR_ERR;
  assign USER_COMP = APR.USER_COMP;
  assign MCL.PAGE_TEST_PRIVATE = MCL.VMA_PUBLIC & EBOX_PAGING_EN & ~MCL.VMA_FETCH;

  bit [1:12] heldSR;
  always_ff @(posedge clk) if (LOAD_VMA_HELD) begin
    heldSR[1:4] <= {MCL.LOAD_AR, MCL.LOAD_ARX, MCL.VMA_PAUSE, MCL.VMA_WRITE};
    heldSR[5:8] <= {MCL.VMA_USER, MCL.VMA_PUBLIC,
                    MCL.VMA_PREVIOUS, MCL.VMA_EXTENDED};
    heldSR[9:12] <= {MCL.VMA_FETCH, MCL.EBOX_MAP,
                     ~MCL.EBOX_CACHE, ~MCL.EBOX_MAY_BE_PAGED};
  end

  assign VMA.HELD_OR_PC[1:4] = CON.COND_SEL_VMA ?
                               heldSR[1:4] :
                               {SCD.CRY0, SCD.CRY1, SCD.FOV, SCD.FPD};
  assign VMA.HELD_OR_PC[5:8] = CON.COND_SEL_VMA ?
                               heldSR[5:8] :
                               {SCD.USER, SCD.USER_IOT, SCD.PUBLIC, SCD.ADR_BRK_INH};
  assign VMA.HELD_OR_PC[9:12] = CON.COND_SEL_VMA ?
                                heldSR[9:12] :
                                {SCD.TRAP_REQ_2, SCD.TRAP_REQ_1, SCD.FXU, SCD.DIV_CHK};


  // MCL4 p.374
  bit [0:2] SR;
  always_ff @(posedge clk) if (CON.LOAD_ACCESS_COND | MEM_AREAD | RESET) SR <= CRAM.MAGIC[0:2];

  bit e46pin3;
  bit e48B0, e48B1;
  mux2x4 e48(.EN(1'b1),
             .SEL(SR[1:2]),
             .D0({RESET, PXCT_B10, PXCT_B11, PXCT_B12}),
             .D1({PXCT_B09, PXCT_B11, PXCT_B12, PXCT_B12}),
             .B0(e48B0),
             .B1(e48B1));

  assign e46pin3 = AD_LONG_EN & MEM_EA_CALC |
                   EA_EXTENDED & CRAM.MAGIC[7] & MEM_EA_CALC |
                   ~MCL.SHORT_STACK & CRAM.MAGIC[8] & MEM_EA_CALC |
                   AD_LONG_EN & AREAD_EN;
  assign VMA_EXT_EN = VMA_AD & ~SR[0] |
                      AD_FUNC_08 |
                      e46pin3;
  assign VMA_LONG_EN = e46pin3 |
                       MEM_REG_FUNC |
                       LOAD_AD_FUNC |
                       VMA_AD |
                       MEM_EA_CALC & CRAM.MAGIC[5];
  assign MCL.VMAX_SEL[0] = MCL.VMA_PREV_EN & ~VMA_PREVIOUS |
                           CRAM.SH[0] & ~MCL.LOAD_VMA |
                           VMA_LONG_EN |
                           PXCT_B12 & CRAM.MAGIC[5] & MEM_EA_CALC;
  assign MCL.VMAX_SEL[1] = AREAD_001 |
                           MEM_EA_CALC & CRAM.MAGIC[5] & ~PXCT_B12 |
                           VMA_LONG_EN |
                           ~MCL.LOAD_VMA & CRAM.SH[0] |
                           MCL.LOAD_VMA & ~MEM_AREAD & ~MEM_EA_CALC;
  assign XR_SHORT = ~MCL.VMA_PREV_EN & VMA_SECTION_0 |
                    VMA_PREVIOUS & VMA_SECTION_0 & MCL.VMA_PREV_EN |
                    ~VMA_PREVIOUS & PCS_SECTION_0 & MCL.VMA_PREV_EN |
                    ~APR.FM_EXTENDED;
  assign MCL.SHORT_STACK = ~APR.FM_EXTENDED |
                           PC_SECTION_0 & ~PXCT_B12 |
                           PXCT_B12 & PCS_SECTION_0 |
                           ~APR.FM_EXTENDED;
  assign VMA_AD = MEM_EA_CALC | LOAD_AD_FUNC | VMA_AD | RESET | AREAD_EA;
  assign VMAslashAD = &CRAM.VMA;     // XXX find all earlier refs to VMA_AD and fixup
  assign MCL.VMA_INC = MCL.SKIP_SATISFIED & ~CON.PI_CYCLE;
  assign MCL.LOAD_VMA_CONTEXT = SPEC_SP_MEM_CYCLE | MCL.LOAD_VMA;
  assign MCL.LOAD_VMA = (~MEM_COND_JUMP | ~IR.TEST_SATISFIED) &
                        (CRAM.VMA[0] | CRAM.VMA[1] | RESET);
  assign MCL.VMA_PREV_EN = e48B0 & VMAslashAD |
                           AREAD_EA & PXCT_B10 |
                           EDP.AD[7] & LOAD_AD_FUNC |
                           MEM_EA_CALC &
                           (e48B1 & CRAM.MAGIC[5] |
                            MCL.XR_PREVIOUS & CRAM.MAGIC[5] |
                            EA_PREVIOUS & CRAM.MAGIC[7] |
                            PXCT_B12 & CRAM.MAGIC[8]);

  mux e47(.en(1'b1),
          .sel({PXCT_B09, SR[1:2]}),
          .d({3'b000, PXCT_B11, PXCT_B09, PXCT_B11, PXCT_B12, PXCT_B11}),
          .q(MCL.XR_PREVIOUS));

  bit e50SR;
  always_ff @(posedge clk) if (CON.LOAD_SPEC_INSTR) begin
    PXCT <= CRAM.MAGIC[4];
    KERNEL_CYCLE <= CRAM.MAGIC[1];
    e50SR <= APR.AC[9:12];
  end

  assign {PXCT_B09, PXCT_B10, PXCT_B11, PXCT_B12} = {4{PXCT}} & e50SR;


  // MCL5 p.375
  bit adrErr;
  assign adrErr = ~LOAD_AD_FUNC &
                  ~MEM_REG_FUNC &
                  VMA_LONG_EN &
                  ((EDP.AD[6:11] !== '0) | ~EDP.AD[12]);

  always_ff @(posedge clk) if (MCL.LOAD_VMA) begin
    ADR_ERR <= adrErr;
    MCL.VMA_ADR_ERR <= VMA.VMA[12] | adrErr;
  end

  bit syncNotReg;
  assign syncNotReg = ~REG_FUNC | CLK.EBOX_SYNC;
  assign WRITE_01 = MEM_B_WRITE & IR.DRAM_B[1];
  assign MCL.MBOX_CYC_REQ = CRAM.MEM[0] & syncNotReg | // CRAM.MEM[0] equivalent to MCL1 MEM 00 A
                            MEM_AREAD & ~Aeq0x0 & syncNotReg |
                            MEM_COND_FETCH & ~CON.PI_CYCLE & syncNotReg |
                            CLK.EBOX_SYNC & (WRITE_01 |
                                             MEM_REG_FUNC |
                                             MCL.SKIP_SATISFIED |
                                             FETCH_EN_IN);
  assign FETCH_EN_IN = IR.JRST0 & MEM_AREAD |
                       MEM_COND_FETCH & CRAM.MAGIC[0] |
                       SPEC_SP_MEM_CYCLE & CRAM.MAGIC[0] |
                       MEM_COND_FETCH & ~CON.PI_CYCLE;
  assign FETCH_EN = MCL.SKIP_SATISFIED | AREAD_001 | AD_FUNC_09 | MEM_UNCOND_FETCH;
  assign MCL.VMAX_EN = ~(SPEC_SP_MEM_CYCLE & RESET |
                         CRAM.MAGIC[3] & RESET);
  assign MCL._18_BIT_EA = MEM_AREAD & ~IR.DRAM_A[0] & ~IR.DRAM_A[1];
  assign MCL._23_BIT_EA = MEM_AREAD & ~AD_LONG_EN;
  assign AD_LONG_EN = CRAM.SH[1] | CRAM.SH[0] & ~XR_SHORT;
  assign MCL.SKIP_SATISFIED = MEM_COND_FETCH & CRAM.MAGIC[5] & IR.TEST_SATISFIED;
  assign SP_MEM_CYCLE = CTL.SPEC_SP_MEM_CYCLE;
  assign RESET = CLK.MR_RESET;

  assign Aeq0x0 = IR.DRAM_A == 3'b000 || IR.DRAM_A == 3'b010;
  assign Aeq001 = IR.DRAM_A == 3'b001;
  assign AREAD_001 = Aeq001 && MEM_AREAD;
  assign AREAD_x11 = IR.DRAM_A == 3'b111 && MEM_AREAD;
  assign AREAD_3_6_7 = (IR.DRAM_A == 3'b011 ||
                        IR.DRAM_A == 3'b110 ||
                        IR.DRAM_A == 3'b111) &
                       MEM_AREAD;

  always_ff @(posedge clk) if (MEM_AREAD) begin
    EA_PREVIOUS <= MCL.VMA_PREV_EN;
    EA_EXTENDED <= VMA_EXT_EN;
  end


  // MCL6 p.376
  bit [0:3] e33SR;
  assign AD_FUNC_08 = EDP.AD[8] & LOAD_AD_FUNC;
  assign AD_FUNC_09 = EDP.AD[9] & LOAD_AD_FUNC;
  assign VMA_SECTION_0 = ~CTL.DIAG_FORCE_EXTEND & VMA.VMA_SECTION_0;
  assign PC_SECTION_0 = ~CTL.DIAG_FORCE_EXTEND & VMA.PC_SECTION_0;
  assign PCS_SECTION_0 = ~CTL.DIAG_FORCE_EXTEND & VMA.PCS_SECTION_0;

  assign USER = SCD.USER;
  assign USER_IOT = SCD.USER_IOT;
  assign PUBLIC = SCD.PUBLIC;

  assign EBOX_CACHE = e33SR[0] & ~REG_FUNC;
  assign EBOX_PAGING_EN = e33SR[1];
  assign MCL.EBOX_MAY_BE_PAGED = EBOX_PAGING_EN & ~REG_FUNC;
  assign MCL.VMA_EPT = e33SR[2];
  assign MCL.VMA_UPT = e33SR[3];
  assign MCL.PAGE_UEBR_REF = MCL.VMA_EPT | MCL.VMA_UPT;
  assign MCL.EBOX_MAP = MAP_FUNC;
  assign PAGED_FETCH = MCL.VMA_FETCH & ~MCL.PAGE_UEBR_REF & MCL.EBOX_MAY_BE_PAGED;
  assign PHYS_REF = CRAM.MAGIC[8] & SPEC_SP_MEM_CYCLE;

  always_ff @(posedge clk) if (MCL.LOAD_VMA_CONTEXT) begin
    e33SR[0] = ~CON.CACHE_LOAD_EN |
               SPEC_SP_MEM_CYCLE & CRAM.MAGIC[7] |
               LOAD_AD_FUNC & EDP.AD[11];
    e33SR[1] = CON.TRAP_EN |
               SPEC_SP_MEM_CYCLE & CRAM.MAGIC[08] |
               LOAD_AD_FUNC & EDP.AD[12];
    e33SR[2] = EPT_EN;
    e33SR[3] = UPT_EN;
    MCL.PAGE_UEBR_REF_A <= PHYS_REF | EPT_EN | UPT_EN; // XXX find wrong references
  end

  always_ff @(posedge clk) if (MCL.REQ_EN) begin
    MAP_FUNC <= MEM_REG_FUNC & CRAM.MAGIC[3] | LOAD_AD_FUNC & EDP.AD[12];
    REG_FUNC <= MEM_REG_FUNC & CRAM.MAGIC[0];
    MCL.VMA_FETCH <= FETCH_EN;
  end
endmodule // mcl
