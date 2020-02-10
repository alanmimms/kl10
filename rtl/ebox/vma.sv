`timescale 1ns/1ns
`include "ebox.svh"

// M8542 VMA
module vma(iVMA VMA,
           iCON CON,
           iCTL CTL,
           iCRAM CRAM,
           iEDP EDP,
           iMCL MCL
);

  // VMA1 p.354
  logic MISCeq0;
  assign MISCeq0 = ~VMA.VMA[18] & ~VMA.VMA[19] & ~VMA.VMA[12] & ~MCL.ADR_ERR;

  logic VMA20_27eq0;
  assign VMA20_27eq0 = VMA.VMA[20:27] == '0;

  logic VMA28_31eq0;
  assign VMA28_31eq0 = VMA.VMA[28:31] == 0;

  logic LOCAL;
  assign LOCAL = ~MCL.VMA_EXTENDED | MCL.VMA_FETCH | VMA_SECTION_01;

  assign VMA.AC_REF = VMA20_27eq0 &
                      (MISCeq0 | VMA28_31eq0) &
                      MCL.PAGE_UEBR_REF &
                      MCL.VMA_READ_OR_WRITE &
                      LOCAL;

  assign VMA.VMA_SECTION_0 = VMA.VMA[12:16] == 0;
  assign VMA.VMA_SECTION_01 = VMA.VMA[13:16] == 0;
  assign VMA.LOCAL_AC_ADDRESSS = ~VMA.VMA_SECTION_01 & LOCAL & MISCeq0 & VMA20_27eq0;

  assign VMA.SPEC_VMA_MAGIC = CON.COND_VMA_MAGIC;

  always_comb begin
    VMA.VMA_G = CSH.GATE_VMA_27_33 ? VMA.VMA[27:33] : '0;
  end

  logic [0:1] ignored1;
  mc10181 vma0(.S({4{VMA.SPEC_VMA_MAGIC}}),
               .M(VMA.SPEC_VMA_MAGIC),
               .CIN(VMA.AD_CRY_20),
               .A({2'b0, VMA.PC[18:19]}),
               .B(4'b0),
               .F({ignored, VMA.AD[18:19]}),
               .COUT(), .CG(), .CP());

  mc10181 vma1(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
               .M(VMA.SPEC_VMA_MAGIC),
               .CIN(VMA.AD_CRY_24),
               .A(VMA.PC[20:23]),
               .B(4'b0),
               .F(VMA.AD[20:23]),
               .COUT(),
               .CG(VMA.AD_CG_20_23),
               .CP(VMA.AD_CP_20_23));

  mc10181 vma2(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
               .M(VMA.SPEC_VMA_MAGIC),
               .CIN(VMA.AD_CRY_28),
               .A(VMA.PC[24:27]),
               .B({3'b0, CRAM.MAGIC[0]}),
               .F(VMA.AD[24:27]),
               .COUT(),
               .CG(VMA.AD_CG_24_27),
               .CP(VMA.AD_CP_24_27));

  mc10181 vma3(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
               .M(VMA.SPEC_VMA_MAGIC),
               .CIN(VMA.AD_CRY_32),
               .A(VMA.PC[28:31]),
               .B(CRAM.MAGIC[1:4]),
               .F(VMA.AD[28:31]),
               .COUT(VMA.AD_CRY_28),
               .CG(VMA.AD_CG_28_31),
               .CP(VMA.AD_CP_28_31));

  mc10181 vma4(.S({CON.COND_VMA_MAGIC, 2'b11, CON.COND_VMA_MAGIC}),
               .M(VMA.SPEC_VMA_MAGIC),
               .CIN(MCL.VMA_INC),
               .A(SCD.TRAP_MIX[32:35]),
               .B(VMA.PC[32:35]),
               .F(VMA.AD[32:35]),
               .COUT(VMA.AD_CRY_32),
               .CG(), .CP());

  mc10179 vmaCG0(.G({VMA.AD_CG_20_23, VMA.AD_CG_20_23, VMA.AD_CG_24_27, VMA.AD_CG_28_31}),
                 .P({VMA.AD_CP_20_23, VMA.AD_CP_20_23, VMA.AD_CP_24_27, VMA.AD_CP_28_31}),
                 .CIN(VMA.AD_CRY_32),
                 .C8OUT(VMA.AD_CRY_20),
                 .C2OUT(VMA.AD_CRY_24),
                 .GG(), .PG());

  // VMA2 p. 355
  logic [18:35] vmaMux;
  always_comb begin
    vmaMux = MCL.VMA_AD ? VMA.AD[18:35] : EDP.AD[18:35];
  end

  UniversalCounter4 e11(.D(VMA.VMA_IN[12:15]),
                        .CIN(VMA.CRY_16),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[12:15]),
                        .COUT());

  UniversalCounter4 e6 (.D({VMA.VMA_IN[16:17], vmaMux[18:19]}),
                        .CIN(VMA.CRY_20),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[16:19]),
                        .COUT(VMA.CRY_16));

  UniversalCounter4 e21(.D(vmaMux[20:23]),
                        .CIN(VMA.CRY_24),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[20:23]),
                        .COUT(VMA.CRY_20));

  UniversalCounter4 e25(.D(vmaMux[24:27]),
                        .CIN(VMA.CRY_28),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[24:27]),
                        .COUT(VMA.CRY_24));

  UniversalCounter4 e64(.D(vmaMux[28:31]),
                        .CIN(VMA.CRY_32),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[28:31]),
                        .COUT(VMA.CRY_28));

  UniversalCounter4 e48(.D(vmaMux[32:35]),
                        .CIN('0),
                        .SEL(~CON.VMA_SEL),
                        .CLK(VMA.CLK),
                        .Q(VMA.VMA[32:35]),
                        .COUT(VMA.CRY_32));

  // VMA3 p.356
  logic match;
  match = VMA.ADR_BRK[13:35] == VMA.VMA[13:35];

  

endmodule // vma
