`timescale 1ns/1ns
`include "ebox.svh"

// M8542 VMA
module vma(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCSH CSH,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iMCL MCL,
           iPAG PAG,
           iPI PIC,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA
);

  bit clk;
  assign clk = CLK.VMA;

  // VMA1 p.354
  bit MISCeq0;
  assign MISCeq0 = ~VMA.VMA[18] & ~VMA.VMA[19] & ~VMA.VMA[12] & ~MCL.ADR_ERR;

  bit VMA20_27eq0;
  assign VMA20_27eq0 = VMA.VMA[20:27] == '0;

  bit VMA28_31eq0;
  assign VMA28_31eq0 = VMA.VMA[28:31] == 0;

  bit LOCAL;
  bit VMA_SECTION_0, VMA_SECTION_01, LOCAL_AC_ADDRESS;
  bit PC_SECTION_0;
  assign VMA_SECTION_0 = VMA.VMA[13:16] == 0;
  assign VMA_SECTION_01 = VMA.VMA[13:16] == 0;
  assign LOCAL = ~MCL.VMA_EXTENDED | MCL.VMA_FETCH | VMA_SECTION_01;
  assign LOCAL_AC_ADDRESS = ~VMA_SECTION_01 & LOCAL & MISCeq0 & VMA20_27eq0;

  assign VMA.AC_REF = VMA20_27eq0 &
                      (MISCeq0 | VMA28_31eq0) &
                      MCL.PAGE_UEBR_REF &
                      MCL.VMA_READ_OR_WRITE &
                      LOCAL;


  bit SPEC_VMA_MAGIC;
  assign SPEC_VMA_MAGIC = CON.COND_VMA_MAGIC;

  bit VMA_G;
  // XXX this goes nowhere. Why?
  assign VMA_G = CSH.GATE_VMA_27_33 ? VMA.VMA[27:33] : '0;

  bit AD_CRY_20, AD_CRY_24, AD_CRY_28, AD_CRY_32;
  bit AD_CG_20_23, AD_CP_20_23, AD_CG_24_27, AD_CP_24_27, AD_CG_28_31, AD_CP_28_31;
  bit [18:35] VMA_AD;
  bit [0:1] ignored01;
  mc10181 e1 (.S({4{SPEC_VMA_MAGIC}}),
              .M(SPEC_VMA_MAGIC),
              .CIN(AD_CRY_20),
              .A({2'b0, VMA.PC[18:19]}),
              .B(4'b0),
              .F({ignored01, VMA_AD[18:19]}),
              .COUT(), .CG(), .CP());

  mc10181 e48(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
              .M(SPEC_VMA_MAGIC),
              .CIN(AD_CRY_24),
              .A(VMA.PC[20:23]),
              .B(4'b0),
              .F(VMA_AD[20:23]),
              .COUT(),
              .CG(AD_CG_20_23),
              .CP(AD_CP_20_23));

  mc10181 e59(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
              .M(SPEC_VMA_MAGIC),
              .CIN(AD_CRY_28),
              .A(VMA.PC[24:27]),
              .B({3'b0, CRAM.MAGIC[0]}),
              .F(VMA_AD[24:27]),
              .COUT(),
              .CG(AD_CG_24_27),
              .CP(AD_CP_24_27));

  mc10181 e85(.S({CON.COND_VMA_MAGIC, 1'b0, CON.COND_VMA_MAGIC, 1'b0}),
              .M(SPEC_VMA_MAGIC),
              .CIN(AD_CRY_32),
              .A(VMA.PC[28:31]),
              .B(CRAM.MAGIC[1:4]),
              .F(VMA_AD[28:31]),
              .COUT(AD_CRY_28),
              .CG(AD_CG_28_31),
              .CP(AD_CP_28_31));

  mc10181 e84(.S({CON.COND_VMA_MAGIC, 2'b11, CON.COND_VMA_MAGIC}),
              .M(SPEC_VMA_MAGIC),
              .CIN(MCL.VMA_INC),
              .A(SCD.TRAP_MIX[32:35]),
              .B(VMA.PC[32:35]),
              .F(VMA_AD[32:35]),
              .COUT(AD_CRY_32),
              .CG(), .CP());

  mc10179 vmaCG0(.G({AD_CG_20_23, AD_CG_20_23, AD_CG_24_27, AD_CG_28_31}),
                 .P({AD_CP_20_23, AD_CP_20_23, AD_CP_24_27, AD_CP_28_31}),
                 .CIN(AD_CRY_32),
                 .C8OUT(AD_CRY_20),
                 .C2OUT(AD_CRY_24),
                 .GG(), .PG());

  // VMA2 p. 355
  bit [12:17] VMA_IN;
  bit CRY_16, CRY_20, CRY_24, CRY_28, CRY_32;
  bit [18:35] vmaMux;
  assign vmaMux = MCL.VMA_AD ? EDP.AD[18:35] : VMA_AD[18:35];

  UCR4 e11(.RESET(1'b0),
           .D(VMA_IN[12:15]),
           .CIN(CRY_16),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[12:15]),
           .COUT());

  UCR4 e6 (.RESET(1'b0),
           .D({VMA_IN[16:17], vmaMux[18:19]}),
           .CIN(CRY_20),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[16:19]),
           .COUT(CRY_16));

  UCR4 e21(.RESET(1'b0),
           .D(vmaMux[20:23]),
           .CIN(CRY_24),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[20:23]),
           .COUT(CRY_20));

  UCR4 e25(.RESET(1'b0),
           .D(vmaMux[24:27]),
           .CIN(CRY_28),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[24:27]),
           .COUT(CRY_24));

  UCR4 e64(.RESET(1'b0),
           .D(vmaMux[28:31]),
           .CIN(CRY_32),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[28:31]),
           .COUT(CRY_28));

  UCR4 e58(.RESET(1'b0),
           .D(vmaMux[32:35]),
           .CIN(1'b0),
           .SEL(~CON.VMA_SEL),
           .CLK(clk),
           .Q(VMA.VMA[32:35]),
           .COUT(CRY_32));

  // VMA3 p.356
  assign VMA.MATCH_13_35 = VMA.ADR_BRK[13:35] == VMA.VMA[13:35];

  genvar k;
  generate
    bit ignored2;

    for (k = 12; k < 36; k += 6) begin: adrBrkR
      USR4 r(.S0(1'b0),
             .D(k == 12 ? {1'b0, EDP.AD[k+1:k+3]} : {EDP.AD[k:k+3]}),
             .S3(1'b0),
             .Q(VMA.ADR_BRK[k:k+3]),
             .SEL({2{~CON.DATAO_APR}}),
             .CLK(clk));
    end
  endgenerate

  generate

    USR4 VMA3r12(.S0(1'b0),
                 .D({VMA_SECTION_0, VMA.VMA[13:15]}),
                 .S3(1'b0),
                 .Q({PC_SECTION_0, VMA.PC[13:15]}),
                 .SEL({2{~CON.DATAO_APR}}),
                 .CLK(clk));

    for (k = 12; k < 36; k += 6) begin: fullPC
      USR4 VMA3r(.S0(1'b0),
                 .D(VMA.VMA[k:k+3]),
                 .S3(1'b0),
                 .Q(VMA.PC[k:k+3]),
                 .SEL({2{~VMA.LOAD_PC}}),
                 .CLK(clk));
    end
  endgenerate


  // VMA4 p.357
  bit ignored3, ignored4;
  generate

    // k = 12 case is persnickety enough that it's easier to just code it here.
    mux4x2 VMA4m12(.SEL(CON.COND_SEL_VMA),
                   .D0({1'b0, VMA.PC[13:15]}),
                   .D1({1'b0, VMA.HELD[13:15]}),
                   .B({ignored3, VMA.HELD_OR_PC[13:15]}));

    USR4 VMA4r12(.S0(1'b0),
                 .D({1'b0, VMA.VMA[13:15]}),
                 .S3(1'b0),
                 .SEL({2{~MCL.LOAD_VMA_HELD}}),
                 .CLK(clk),
                 .Q({ignored4, VMA.HELD[13:15]}));

    for (k = 18; k < 36; k += 6) begin: heldOrPC
      mux4x2 m(.SEL(CON.COND_SEL_VMA),
               .D0(VMA.PC[k:k+3]),
               .D1(VMA.HELD[k:k+3]),
               .B(VMA.HELD_OR_PC[k:k+3]));

      USR4 r(.S0(1'b0),
             .D(VMA.VMA[k:k+3]),
             .S3(1'b0),
             .SEL({2{VMA.LOAD_VMA_HELD}}),
             .CLK(clk),
             .Q(VMA.HELD[k:k+3]));
    end
  endgenerate

  bit VMAX_EN, ignored6;
  assign VMAX_EN = ~MCL.VMAX_EN | CON.COND_VMAX_MAGIC;

  // E12 top half
  always_comb if (VMAX_EN && MCL.VMAX_SEL == 2'b00) VMA_IN[12] = VMA.VMA[12];

  // Note change of signal name from VMA_nn_IN to VMA_IN[nn].
  // E12 bottom half, E17, E19
  generate
    for (k = 13; k < 18; k += 2) begin: vmaIN
      assign EDP.ARMM_VMA[k] = VMA_IN[k];
      always_comb if (VMAX_EN) case (MCL.VMAX_SEL)
                               2'b00: VMA_IN[k] = VMA.VMA[k];
                               2'b01: VMA_IN[k] = VMA.PC[k];
                               2'b10: VMA_IN[k] = VMA.PREV_SEC[k];
                               2'b11: VMA_IN[k] = EDP.AD[k];
                               endcase
    end
  endgenerate

  bit ignored5;
  USR4 e32(.S0(1'b0),
           .D({1'b0, EDP.AD[13:15]}),
           .S3(1'b0),
           .SEL({2{~CON.LOAD_PREV_CONTEXT}}),
           .CLK(clk),
           .Q({ignored5, VMA.PREV_SEC[13:15]}));

  bit [16:17] ps;
  
  USR4 e24(.S0(1'b0),
           .D({EDP.AD[16:17], EDP.AD[17], EDP.AD[16]}),
           .S3(1'b0),
           .SEL({2{~CON.LOAD_PREV_CONTEXT}}),
           .CLK(clk),
           .Q({VMA.PREV_SEC[16:17], ps}));
  bit PCS_SECTION_0;
  assign PCS_SECTION_0 = VMA.PREV_SEC[13:15] == '0 && ps == '0;

  // VMA5 p. 358

  function bit [2:0] rev3(input bit [0:2] pdp);
    rev3[2] = pdp[0];
    rev3[1] = pdp[1];
    rev3[0] = pdp[2];
  endfunction

  function bit [3:0] rev4(input bit [0:3] pdp);
    rev4[3] = pdp[0];
    rev4[2] = pdp[1];
    rev4[1] = pdp[2];
    rev4[0] = pdp[3];
  endfunction

  function bit [4:0] rev5(input bit [0:4] pdp);
    rev5[4] = pdp[0];
    rev5[3] = pdp[1];
    rev5[2] = pdp[2];
    rev5[1] = pdp[3];
    rev5[0] = pdp[4];
  endfunction

  bit [4:6] diag;
  bit READ_VMA;
  assign diag = CTL.DIAG[4:6];
  assign READ_VMA = CTL.DIAG_READ_FUNC_15x;
  mux e33(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev3(VMA.PC[13:15]), ~MISCeq0, rev3(VMA.HELD[13:15]), ~VMA.AC_REF}),
          .q(VMA.EBUSdriver.data[13]));

  mux e38(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev3(VMA.ADR_BRK[13:15]), ~LOCAL_AC_ADDRESS,
              rev3(VMA.VMA[13:15]), ~VMA.MATCH_13_35}),
          .q(VMA.EBUSdriver.data[15]));

  mux  e9(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.PC[16:19]), rev4(VMA.HELD[16:19])}),
          .q(VMA.EBUSdriver.data[17]));
          
  mux e28(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.ADR_BRK[16:19]), rev4(VMA.VMA[16:19])}),
          .q(VMA.EBUSdriver.data[19]));

  mux e35(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.PC[20:23]), rev4(VMA.HELD[20:23])}),
          .q(VMA.EBUSdriver.data[21]));
          
  mux e34(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.ADR_BRK[20:23]), rev4(VMA.VMA[20:23])}),
          .q(VMA.EBUSdriver.data[23]));
          
  mux e52(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.PC[24:27]), rev4(VMA.HELD[24:27])}),
          .q(VMA.EBUSdriver.data[25]));
          
  mux e50(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.ADR_BRK[24:27]), rev4(VMA.VMA[24:27])}),
          .q(VMA.EBUSdriver.data[27]));
          
  mux e61(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.PC[28:31]), rev4(VMA.HELD[28:31])}),
          .q(VMA.EBUSdriver.data[29]));
          
  mux e71(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.ADR_BRK[28:31]), rev4(VMA.VMA[28:31])}),
          .q(VMA.EBUSdriver.data[31]));
          
  mux e76(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.PC[32:35]), rev4(VMA.HELD[32:35])}),
          .q(VMA.EBUSdriver.data[33]));
          
  mux e60(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({rev4(VMA.ADR_BRK[32:35]), rev4(VMA.VMA[32:35])}),
          .q(VMA.EBUSdriver.data[35]));

  mux e22(.en(READ_VMA),
          .sel(diag[4:6]),
          .d({~VMA_SECTION_0, ~PC_SECTION_0, ~PCS_SECTION_0, rev5(VMA.PREV_SEC[13:17])}),
          .q(VMA.EBUSdriver.data[11]));

  assign VMA.EBUSdriver.driving = READ_VMA;

  // VMA5 DATAO APR, VMA5 LOAD PC, VMA5 LOAD VMA HELD, VMA5 READ VMA A
  // are all unused and are basically just copies of signals from
  // other modules anyway.
endmodule // vma
