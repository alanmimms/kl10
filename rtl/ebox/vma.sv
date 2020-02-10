`timescale 1ns/1ns
`include "ebox.svh"

// M8542 VMA
module vma(iVMA VMA,
           iCLK CLK,
           iCON CON,
           iCTL CTL,
           iCRAM CRAM,
           iEDP EDP,
           iMCL MCL
           );

  logic clk;
  assign clk = CLK.VMA;

  // VMA1 p.354
  logic MISCeq0;
  assign MISCeq0 = ~VMA.VMA[18] & ~VMA.VMA[19] & ~VMA.VMA[12] & ~MCL.ADR_ERR;

  logic VMA20_27eq0;
  assign VMA20_27eq0 = VMA.VMA[20:27] == '0;

  logic VMA28_31eq0;
  assign VMA28_31eq0 = VMA.VMA[28:31] == 0;

  logic LOCAL;
  logic VMA_SECTION_0, VMA_SECTION_01, LOCAL_AC_ADDRESS;
  assign VMA_SECTION_0 = VMA.VMA[12:16] == 0;
  assign VMA_SECTION_01 = VMA.VMA[13:16] == 0;
  assign LOCAL = ~MCL.VMA_EXTENDED | MCL.VMA_FETCH | VMA_SECTION_01;
  assign LOCAL_AC_ADDRESS = ~VMA.VMA_SECTION_01 & LOCAL & MISCeq0 & VMA20_27eq0;

  assign VMA.AC_REF = VMA20_27eq0 &
                      (MISCeq0 | VMA28_31eq0) &
                      MCL.PAGE_UEBR_REF &
                      MCL.VMA_READ_OR_WRITE &
                      LOCAL;


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

  UCR4 e11(.D(VMA.VMA_IN[12:15]),
           .CIN(VMA.CRY_16),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[12:15]),
           .COUT());

  UCR4 e6 (.D({VMA.VMA_IN[16:17], vmaMux[18:19]}),
           .CIN(VMA.CRY_20),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[16:19]),
           .COUT(VMA.CRY_16));

  UCR4 e21(.D(vmaMux[20:23]),
           .CIN(VMA.CRY_24),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[20:23]),
           .COUT(VMA.CRY_20));

  UCR4 e25(.D(vmaMux[24:27]),
           .CIN(VMA.CRY_28),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[24:27]),
           .COUT(VMA.CRY_24));

  UCR4 e64(.D(vmaMux[28:31]),
           .CIN(VMA.CRY_32),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[28:31]),
           .COUT(VMA.CRY_28));

  UCR4 e48(.D(vmaMux[32:35]),
           .CIN('0),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[32:35]),
           .COUT(VMA.CRY_32));

  // VMA3 p.356
  logic match;                  // Note signal name changed from VMA.MATCH 13-35
  assign match = VMA.ADR_BRK[13:35] == VMA.VMA[13:35];

  genvar k;
  generate
    logic ignored2;

    for (k = 12; k < 36; k += 6) begin: adrBrkR
      USR4 r(.S0(1'b0),
             .D(k == 12 ? {1'b0, EDP.AD[k+1:k+3]} : {EDP.AD[k:k+3]}),
             .S3(1'b0),
             .Q(k == 12 ? {ignored2, VMA.ADR_BRK[k+1:k+3]} : {VMA.ADR_BRK[k:k+3]}),
             .SEL({2{~CON.DATAO_APR}}),
             .CLK(clk));
    end
  endgenerate

  generate

    for (k = 12; k < 36; k += 6) begin: fullPC
      USR4 r(.S0(1'b0),
             .D(k == 12 ? {VMA.VMA_SECTION_0, VMA.VMA[k+1:k+3]} : {VMA.VMA[k:k+3]}),
             .S3(1'b0),
             .Q(k == 12 ? {VMA.PC_SECTION_0, VMA.PC[k+1:k+3]} : {VMA.PC[k:k+3]}),
             .SEL(k == 12 ? {2{~CON.DATAO_APR}} : {2{~VMA.LOAD_PC}}),
             .CLK(clk));
    end
  endgenerate


  // VMA4 p.357
  logic ignored3, ignored4;
  generate

    for (k = 12; k < 36; k += 6) begin: heldOrPC
      mix4 m(.SEL(CON.COND_SEL_VMA),
             .D0(k == 12 ? {1'b0, VMA.PC[k+1:k+3]} : VMA.PC[k:k+3]),
             .D1(k == 12 ? {1'b0, VMA.HELD[k+1:k+3]} : VMA.HELD[k:k+3]),
             .B(k == 12 ? {ignored3, VMA.HELD_OR_PC[k+1:k+3]} : VMA.HELD_OR_PC[k:k+3]));

      USR4 r(.S0('0),
             .D(k == 12 ? {1'b0, VMA.VMA[k+1:k+3]} : VMA.VMA[k:k+3]),
             .S3('0),
             .SEL(k == 12 ? {2{~MCL.LOAD_VMA_HELD}} : {2{VMA.LOAD_VMA_HELD}}),
             .CLK(clk),
             .Q(k == 12 ? {ignored4, VMA.HELD[k+1:k+3]} : VMA.HELD[k:k+3]));
    end
  endgenerate

  logic VMAX_EN;
  assign VMAX_EN = ~MCL.VMAX_EN | CON.COND_VMAX_MAGIC;
  mix4 e12a(.SEL(VMA.VMAX_EN),
            .D({VMA.VMA[12], 3'b0}),
            .B(VMA.VMA[12]));

  // Note change of signal name from VMA_nn_IN to VMA_IN[nn].
  generate
    for (k = 13; k < 18; ++k) begin: vmaIN
      mix4 m(.SEL(VMA.VMAX_EN),
             .D({VMA.VMA[k], VMA.PC[k], VMA.PREV_SEC[k], EDP.AD[k]}),
             .B(VMA.VMA_IN[k]));
    end
  endgenerate

  logic ignored5;
  USR4 e32(.S0('0),
           .D({1'b0, EDP.AD[13:15]}),
           .S3('0),
           .SEL({2{~CON.LOAD_PREV_CONTEXT}}),
           .CLK(clk),
           .Q({ignored5, VMA.PREV_SEC[13:15]}));

  logic [16:17] ps;
  
  USR4 e24(.S0('0),
           .D({EDP.AD[16:17], EDP.AD[17:16]}),
           .S3('0),
           .SEL({2{~CON.LOAD_PREV_CONTEXT}}),
           .CLK(clk),
           .Q({VMA.PREV_SEC[16:17], ps}));
  assign VMA.PCS_SECTION_0 = VMA.PREV_SEC[13:15] == '0 && ps == '0;

  // VMA5 p. 358
  logic [4:6] diag;
  assign diag = CTL.DIAG[4:6];
  mux e33(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[15:13], ~MISCeq0, VMA.HELD[15:13], ~VMA.AC_REF}),
          .q(EBUSdriver.data[13]));

  mux e38(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[15:13], ~LOCAL_AC_ADDRESS, VMA.VMA[15:13], ~match}),
          .q(EBUSdriver.data[15]));

  mux  e9(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[19:16], VMA.HELD[19:16]}),
          .q(EBUSdriver.data[17]));
          
  mux e28(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[19:16], VMA.VMA[19:16]}),
          .q(EBUSdriver.data[19]));

  mux e35(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[23:20], VMA.HELD[23:20]}),
          .q(EBUSdriver.data[21]));
          
  mux e34(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[23:20], VMA.VMA[23:20]}),
          .q(EBUSdriver.data[23]));
          
  mux e52(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[27:24], VMA.HELD[27:24]}),
          .q(EBUSdriver.data[25]));
          
  mux e50(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[27:24], VMA.VMA[27:24]}),
          .q(EBUSdriver.data[27]));
          
  mux e61(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[31:28], VMA.HELD[31:28]}),
          .q(EBUSdriver.data[29]));
          
  mux e71(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[31:28], VMA.VMA[31:28]}),
          .q(EBUSdriver.data[31]));
          
  mux e76(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.PC[35:32], VMA.HELD[35:32]}),
          .q(EBUSdriver.data[33]));
          
  mux e60(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({VMA.ADR_BRK[35:32], VMA.VMA[35:32]}),
          .q(EBUSdriver.data[35]));

  mux e22(.en(VMA.READ_VMA),
          .sel(diag[4:6]),
          .d({~VMA.VMA_SECTION0, ~VMA.PC_SECTION_0, ~VMA.PCS_SECTION_0, VMA.PREV_SEC[17:13]}),
          .q(EBUSdriver.data[11]));

  assign EBUSdriver.driving = VMA.READ_VMA;

  // VMA5 DATAO APR, VMA5 LOAD PC, VMA5 LOAD VMA HELD, VMA5 READ VMA A
  // are all unused and are basically just copies of signals from
  // other modules anyway.
endmodule // vma
