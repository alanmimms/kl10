`timescale 1ns/1ns
`include "ebox.svh"

// M8524 SCD
module scd(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
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


  // SCAD CONTROL
  // CRAM SCAD    SCAD                            CRY
  //  4  2  1   FUNCTION  BOOLE  S8  S4  S2  S1  IN
  //  0  0  0       A       0     0   0   0   0   0
  //  0  0  1     A-B-1     0     1   0   0   1   0
  //  0  1  0      A+B      0     0   1   1   0   0
  //  0  1  1      A-1      0     0   1   1   1   0
  //  1  0  0      A+1      0     0   0   0   0   1
  //  1  0  1      A-B      0     1   0   0   1   1
  //  1  1  0       OR      0     0   1   0   0   0
  //  1  1  1      AND      0     1   1   1   0   1

  bit SET_AD_FLAGS, LOAD_FLAGS, PUBLIC_PAGE, PCF_MAGIC, INSTR_FETCH;
  bit USER_EN, USER_IOT_EN, CLR_PUBLIC, LEAVE_USER, PUBLIC_EN, PRIVATE_INSTR_EN;
  bit JFCL, DISP_FLAG_CTL, SPEC_PORTAL, TRAP_REQ_1, TRAP_REQ_2;

  // SCD1 p. 138
  bit SCAD_S1, SCAD_S0, SCAD_CRY_IN;
  bit SCAD_CRY_02_OUT, SCAD_CRY_06_OUT;
  bit EXP_TEST;
  bit TRAP_CYC_1_OR_2;
  bit [0:9] SCAD;
  assign SCAD_S1 =     ~CRAM.SCAD[0] &  CRAM.SCAD[1] &  CRAM.SCAD[2];
  assign SCAD_S0 =     ~CRAM.SCAD[0] & ~CRAM.SCAD[1] &  CRAM.SCAD[2];
  assign SCAD_CRY_IN =  CRAM.SCAD[0] & ~CRAM.SCAD[1] &  CRAM.SCAD[2];
  assign SCD.SCADeq0 = SCAD == '0;  // E54, E37

  bit ignoredE82;
  mc10181 e82(.S({CRAM.SCAD[2], CRAM.SCAD[1], SCAD_S1, SCAD_S0}),
              .M(1'b0),
              .A({1'b0, SCD.SCADA[0], SCD.SCADA[0], SCD.SCADA[1]}),
              .B({1'b0, SCD.SCADB[0], SCD.SCADB[0], SCD.SCADB[1]}),
              .CIN(SCAD_CRY_02_OUT),
              .CG(), .CP(), .COUT(),
              .F({ignoredE82, SCD.SCAD_SIGN, SCAD[0], SCAD[1]}));

  mc10181 e84(.S({CRAM.SCAD[2], CRAM.SCAD[1], SCAD_S1, SCAD_S0}),
              .M(1'b0),
              .A(SCD.SCADA[2:5]),
              .B(SCD.SCADB[2:5]),
              .CIN(SCAD_CRY_06_OUT),
              .CG(), .CP(),
              .COUT(SCAD_CRY_02_OUT),
              .F(SCAD[2:5]));

  mc10181 e66(.S({CRAM.SCAD[2], CRAM.SCAD[1], SCAD_S1, SCAD_S0}),
              .M(1'b0),
              .A(SCD.SCADA[6:9]),
              .B(SCD.SCADB[6:9]),
              .CIN(SCAD_CRY_IN),
              .CG(), .CP(),
              .COUT(SCAD_CRY_06_OUT),
              .F(SCAD[6:9]));

  bit [2:9] SCADA_EXP;
  // E53, E76, E51
  assign SCADA_EXP[2:9] = EDP.AR[1:8] ^ EDP.AR[0];

  mux2x4 E83(.SEL(CRAM.SCADB),
             .EN(1'b1),
             .D0({SCD.SC[0], 3'b0}),
             .D1({SCD.SC[1], 1'b0, EDP.AR[0], CRAM.MAGIC[0]}),
             .B0(SCD.SCADB[0]),
             .B1(SCD.SCADB[1]));

  mux2x4 E79(.SEL(CRAM.SCADB),
             .EN(1'b1),
             .D0({SCD.SC[2], 1'b0, EDP.AR[1], CRAM.MAGIC[1]}),
             .D1({SCD.SC[3], 1'b0, EDP.AR[2], CRAM.MAGIC[2]}),
             .B0(SCD.SCADB[2]),
             .B1(SCD.SCADB[3]));

  mux2x4 E75(.SEL(CRAM.SCADB),
             .EN(1'b1),
             .D0({SCD.SC[4], EDP.AR[6], EDP.AR[3], CRAM.MAGIC[3]}),
             .D1({SCD.SC[5], EDP.AR[7], EDP.AR[4], CRAM.MAGIC[4]}),
             .B0(SCD.SCADB[4]),
             .B1(SCD.SCADB[5]));

  mux2x4 E52(.SEL(CRAM.SCADB),
             .EN(1'b1),
             .D0({SCD.SC[6], EDP.AR[8], EDP.AR[5], CRAM.MAGIC[5]}),
             .D1({SCD.SC[7], EDP.AR[9], EDP.AR[6], CRAM.MAGIC[6]}),
             .B0(SCD.SCADB[6]),
             .B1(SCD.SCADB[7]));

  mux2x4 E56(.SEL(CRAM.SCADB),
             .EN(1'b1),
             .D0({SCD.SC[8], EDP.AR[10], EDP.AR[7], CRAM.MAGIC[7]}),
             .D1({SCD.SC[9], EDP.AR[11], EDP.AR[8], CRAM.MAGIC[8]}),
             .B0(SCD.SCADB[8]),
             .B1(SCD.SCADB[9]));

  mux2x4 E77(.SEL(CRAM.SCADA[1:2]),
             .EN(~CRAM.SCADA[0]),
             .D0({SCD.FE[0], 2'b00, CRAM.MAGIC[0]}),
             .D1({SCD.FE[1], 2'b00, CRAM.MAGIC[0]}),
             .B0(SCD.SCADA[0]),
             .B1(SCD.SCADA[1]));

  mux2x4 E81(.SEL(CRAM.SCADA[1:2]),
             .EN(~CRAM.SCADA[0]),
             .D0({SCD.FE[2], 1'b0, SCADA_EXP[2], CRAM.MAGIC[1]}),
             .D1({SCD.FE[1], 1'b0, SCADA_EXP[3], CRAM.MAGIC[2]}),
             .B0(SCD.SCADA[2]),
             .B1(SCD.SCADA[3]));

  mux2x4 E80(.SEL(CRAM.SCADA[1:2]),
             .EN(~CRAM.SCADA[0]),
             .D0({SCD.FE[4], EDP.AR[0], SCADA_EXP[4], CRAM.MAGIC[3]}),
             .D1({SCD.FE[5], EDP.AR[1], SCADA_EXP[5], CRAM.MAGIC[4]}),
             .B0(SCD.SCADA[4]),
             .B1(SCD.SCADA[5]));

  mux2x4 E62(.SEL(CRAM.SCADA[1:2]),
             .EN(~CRAM.SCADA[0]),
             .D0({SCD.FE[6], EDP.AR[2], SCADA_EXP[6], CRAM.MAGIC[5]}),
             .D1({SCD.FE[7], EDP.AR[3], SCADA_EXP[7], CRAM.MAGIC[6]}),
             .B0(SCD.SCADA[6]),
             .B1(SCD.SCADA[7]));

  mux2x4 E57(.SEL(CRAM.SCADA[1:2]),
             .EN(~CRAM.SCADA[0]),
             .D0({SCD.FE[8], EDP.AR[4], SCADA_EXP[8], CRAM.MAGIC[7]}),
             .D1({SCD.FE[9], EDP.AR[5], SCADA_EXP[9], CRAM.MAGIC[8]}),
             .B0(SCD.SCADA[8]),
             .B1(SCD.SCADA[9]));


  // SCD2 p.139
  // Note on model B this is not an input to E64 pin 13.
  assign SCD.SC_36_TO_63 = SCD.SC[4] & |SCD.SC[5:7];
  assign SCD.SC_GE_36 = |SCD.SC[0:3];

  bit clk;
  assign clk = CLK.SCD;

  bit [0:9] SCM;
  always_ff @(posedge clk) SCD.SC_SIGN <= SCM[0];
  always_ff @(posedge clk) SCD.SC <= SCM;

  // FE shift register
  bit RESET, ignoreE68;
  bit [0:1] feSEL;
  assign feSEL = {CRAM.FE | CON.COND_FE_SHRT, CRAM.FE | RESET};
  USR4 e68(.S0(SCD.FE_SIGN),
           .D({{3{SCAD[0]}}, SCAD[1]}),
           .S3(1'b0),
           .SEL(feSEL),
           .CLK(clk),
           .Q({SCD.FE_SIGN, ignoreE68, SCD.FE[0:1]}));

  USR4 e69(.S0(SCD.FE[1] | CRAM.FE),
           .D(SCAD[2:5]),
           .S3(1'b0),
           .SEL(feSEL),
           .CLK(clk),
           .Q(SCD.FE[2:5]));

  USR4 e55(.S0(SCD.FE[5] | CRAM.FE),
           .D(SCAD[6:9]),
           .S3(1'b0),
           .SEL(feSEL),
           .CLK(clk),
           .Q(SCD.FE[6:9]));

  // In each of these where .SEL MSB is CRAM.SC, the schematic shows
  // CRAM SCM SEL 2 H as the signal to use. I cannot find that signal.
  // XXX this is a guess.
  mux2x4 e72(.EN(~RESET),
             .SEL({CRAM.SC, CTL.SPEC_SCM_ALT}),
             .D0({SCD.SC[0], SCD.FE[0], SCAD[0], EDP.AR[18]}),
             .D1({SCD.SC[1], SCD.FE[1], SCAD[1], EDP.AR[18]}),
             .B0(SCM[0]),
             .B1(SCM[1]));

  mux2x4 e73(.EN(~RESET),
             .SEL({CRAM.SC, CTL.SPEC_SCM_ALT}),
             .D0({SCD.SC[2], SCD.FE[2], SCAD[2], EDP.AR[28]}),
             .D1({SCD.SC[3], SCD.FE[3], SCAD[3], EDP.AR[29]}),
             .B0(SCM[2]),
             .B1(SCM[3]));

  mux2x4 e74(.EN(~RESET),
             .SEL({CRAM.SC, CTL.SPEC_SCM_ALT}),
             .D0({SCD.SC[4], SCD.FE[4], SCAD[4], EDP.AR[30]}),
             .D1({SCD.SC[5], SCD.FE[5], SCAD[5], EDP.AR[31]}),
             .B0(SCM[4]),
             .B1(SCM[5]));

  mux2x4 e60(.EN(~RESET),
             .SEL({CRAM.SC, CTL.SPEC_SCM_ALT}),
             .D0({SCD.SC[6], SCD.FE[6], SCAD[6], EDP.AR[32]}),
             .D1({SCD.SC[7], SCD.FE[7], SCAD[7], EDP.AR[33]}),
             .B0(SCM[6]),
             .B1(SCM[7]));

  mux2x4 e61(.EN(~RESET),
             .SEL({CRAM.SC, CTL.SPEC_SCM_ALT}),
             .D0({SCD.SC[8], SCD.FE[8], SCAD[8], EDP.AR[34]}),
             .D1({SCD.SC[9], SCD.FE[9], SCAD[9], EDP.AR[35]}),
             .B0(SCM[8]),
             .B1(SCM[9]));


  // SCD3 p. 140
  bit [4:6] DIAG;
  assign DIAG = CTL.DIAG[4:6];
  assign SCD.EBUSdriver.driving  = CTL.DIAG_READ_FUNC_13x;

  bit NICOND_10;

  mux e13(.en(SCD.EBUSdriver.driving),
          .sel(DIAG),
          .d({TRAP_REQ_2, SCD.OV, VMA.HELD_OR_PC[0], SCD.PCP,
              ~SCD.USER, ~SCD.PUBLIC_EN, SCD.KERNEL_USER_IOT, SCD.ADR_BRK_INH}),
          .q(SCD.EBUSdriver.data[2]));
  
  mux e26(.en(SCD.EBUSdriver.driving),
          .sel(DIAG),
          .d({SCD.TRAP_CYC_2, SCD.CRY0, SCD.FOV, LOAD_FLAGS,
              LEAVE_USER, SCD.PUBLIC, SCD.TRAP_MIX[32], SCD.TRAP_MIX[34]}),
          .q(SCD.EBUSdriver.data[3]));
  
  mux e31(.en(SCD.EBUSdriver.driving),
          .sel(DIAG),
          .d({SCD.TRAP_CYC_1, SCD.CRY1, SCD.FXU, ~SCD.SCADeq0,
              ~CON.PI_CYCLE, SCD.KERNEL_MODE, SCD.TRAP_MIX[33], SCD.TRAP_MIX[35]}),
          .q(SCD.EBUSdriver.data[4]));
  
  mux e17(.en(SCD.EBUSdriver.driving),
          .sel(DIAG),
          .d({TRAP_REQ_1, ~EDP.AD_CRY[1], ~EDP.AD_OVERFLOW[0], CON.CLR_PRIVATE_INSTR,
              ~USER_EN, ~SCD.PRIVATE_INSTR, SCD.USER_IOT, SCD.ADR_BRK_CYC}),
          .q(SCD.EBUSdriver.data[5]));
  
  mux e12(.en(SCD.EBUSdriver.driving),
          .sel(DIAG),
          .d({SCD.FPD, SCD.DIV_CHK, ~EDP.AD_CRY[-2], NICOND_10,
              PUBLIC_PAGE, ~PRIVATE_INSTR_EN, ~USER_IOT_EN, SCD.ADR_BRK_PREVENT}),
          .q(SCD.EBUSdriver.data[6]));

  mux2x4 e58(.EN(SCD.EBUSdriver.driving),
             .SEL(DIAG[5:6]),
             .D0({SCD.SC[7], SCD.SC[2], SCD.FE[7], SCD.FE[2]}),
             .D1({SCD.SC[6], SCD.SC[1], SCD.FE[6], SCD.FE[1]}),
             .B0(SCD.EBUSdriver.data[9]),
             .B1(SCD.EBUSdriver.data[8]));
  
  mux2x4 e59(.EN(SCD.EBUSdriver.driving),
             .SEL(DIAG[5:6]),
             .D0({SCD.SC[9], SCD.SC[4], SCD.FE[9], SCD.FE[4]}),
             .D1({SCD.SC[8], SCD.SC[3], SCD.FE[8], SCD.FE[3]}),
             .B0(SCD.EBUSdriver.data[11]),
             .B1(SCD.EBUSdriver.data[10]));
  
  mux e47(.en(CON.COND_EN_30_37),
          .sel(CRAM.COND[3:5]),
          .d({{3{CRAM.MAGIC[5]}}, EDP.AR[32], PIC.PIC[0], 3'b000}),
          .q(SCD.TRAP_MIX[32]));
  
  mux e44(.en(CON.COND_EN_30_37),
          .sel(CRAM.COND[3:5]),
          .d({{2{CRAM.MAGIC[6]}}, SCD.USER, EDP.AR[33], PIC.PIC[1], 3'b000}),
          .q(SCD.TRAP_MIX[33]));
  
  mux e42(.en(CON.COND_EN_30_37),
          .sel(CRAM.COND[3:5]),
          .d({CRAM.MAGIC[7], SCD.TRAP_CYC_2, SCD.PUBLIC, EDP.AR[34], PIC.PIC[2], 3'b000}),
          .q(SCD.TRAP_MIX[34]));

  bit mix35out;
  mux e43(.en(CON.COND_EN_30_37),
          .sel(CRAM.COND[3:5]),
          .d({CRAM.MAGIC[8], SCD.TRAP_CYC_1, TRAP_CYC_1_OR_2, EDP.AR[35],
              CRAM.MAGIC[8], 3'b000}),
          .q(mix35out));
  assign SCD.TRAP_MIX[35] = (CRAM.VMA[0] | mix35out) &
                            (~CON.PCplus1_INH | mix35out);

  mux2x4 e48(.EN(1'b1),
             .SEL(CRAM.SH),
             .D0({CRAM.MAGIC[0], EDP.AR[0], CTL.COND_AR_EXP ? SCAD[1] : EDP.AR[0], SCAD[4]}),
             .D1({CRAM.MAGIC[1], EDP.AR[0], SCAD[2], SCAD[5]}),
             .B0(EDP.ARMM_SCD[0]),
             .B1(EDP.ARMM_SCD[1]));

  mux2x4 e49(.EN(1'b1),
             .SEL(CRAM.SH),
             .D0({CRAM.MAGIC[2], EDP.AR[0], SCAD[3], SCAD[6]}),
             .D1({CRAM.MAGIC[3], EDP.AR[0], SCAD[4], SCAD[7]}),
             .B0(EDP.ARMM_SCD[2]),
             .B1(EDP.ARMM_SCD[3]));

  mux2x4 e50(.EN(1'b1),
             .SEL(CRAM.SH),
             .D0({CRAM.MAGIC[4], EDP.AR[0], SCAD[5], SCAD[8]}),
             .D1({CRAM.MAGIC[5], EDP.AR[0], SCAD[6], SCAD[9]}),
             .B0(EDP.ARMM_SCD[4]),
             .B1(EDP.ARMM_SCD[5]));

  mux2x4 e46(.EN(1'b1),
             .SEL(CRAM.SH),
             .D0({CRAM.MAGIC[6], EDP.AR[0], SCAD[7], EDP.AR[6]}),
             .D1({CRAM.MAGIC[7], EDP.AR[0], SCAD[8], EDP.AR[7]}),
             .B0(EDP.ARMM_SCD[6]),
             .B1(EDP.ARMM_SCD[7]));

  mux2x4 e41(.EN(1'b1),
             .SEL(CRAM.SH),
             .D0({CRAM.MAGIC[8], EDP.AR[0], SCAD[9], EDP.AR[8]}),
             .D1(),
             .B0(EDP.ARMM_SCD[8]),
             .B1());


  // SCD4 p.141
  bit PIandSAVE_FLAGS;
  bit TRAP_CLEAR, TRAP_REQ_1_EN, TRAP_REQ_2_EN;
  bit e38OR;
  assign e38OR = EDP.AR[10] & LOAD_FLAGS |
                 SCAD[1] & EXP_TEST |
                 CRAM.MAGIC[4] & PCF_MAGIC |
                 CON.COND_INSTR_ABORT & (TRAP_REQ_1 | SCD.TRAP_CYC_1);
  assign TRAP_REQ_1_EN = SET_AD_FLAGS & EDP.AD_OVERFLOW[0] |
                         (TRAP_CLEAR | e38OR) &
                         (TRAP_REQ_1 | e38OR);
  assign TRAP_REQ_2_EN = TRAP_REQ_2 & ~TRAP_CLEAR |
                         EDP.AR[9] & LOAD_FLAGS |
                         CRAM.MAGIC[3] & PCF_MAGIC |
                         CON.COND_INSTR_ABORT & (SCD.TRAP_CYC_2 | TRAP_REQ_2);

  assign TRAP_CLEAR = CON.COND_INSTR_ABORT | PIandSAVE_FLAGS |
                      CTL.DISP_NICOND | LOAD_FLAGS;
  bit e22p15;
  assign e22p15 = CON.TRAP_EN & CTL.DISP_NICOND;

  bit DISP_SAVE_FLAGS;
  bit CLR_FPD;
  assign CLR_FPD = LOAD_FLAGS | DISP_SAVE_FLAGS | CTL.SPEC_CLR_FPD;

  bit LOAD_PCP;
  assign LOAD_PCP = LOAD_FLAGS & ~JFCL;

  // XXX Contrast this with CON.NICOND[10] guess on CON2
  assign NICOND_10 = (TRAP_REQ_1 | TRAP_REQ_2) & CON.TRAP_EN & CON.NICOND_TRAP_EN;

  always_ff @(posedge clk) begin
    SCD.OV <= EDP.AD_OVERFLOW[0] & SET_AD_FLAGS |
              (LOAD_FLAGS ?
               (SCD.OV | SCAD[1] & EXP_TEST | CRAM.MAGIC[0] & PCF_MAGIC) :
                EDP.AR[0]);

    SCD.CRY0 <= EDP.AD_CRY[-2] & SET_AD_FLAGS | (LOAD_FLAGS ? SCD.CRY0 : EDP.AR[1]);
    SCD.CRY1 <= EDP.AD_CRY[1] & SET_AD_FLAGS | (LOAD_FLAGS ? SCD.CRY1 : EDP.AR[2]);

    SCD.FOV <= (LOAD_FLAGS | SCD.FOV | (SCAD[1] & EXP_TEST | CRAM.MAGIC[0] & PCF_MAGIC)) &
               (~LOAD_FLAGS | EDP.AR[3]);

    SCD.FXU <= (LOAD_FLAGS | SCD.FXU | (SCAD[0] & EXP_TEST | CRAM.MAGIC[5] & PCF_MAGIC)) &
               (~LOAD_FLAGS | EDP.AR[11]);

    SCD.DIV_CHK <= (LOAD_FLAGS | SCD.DIV_CHK | CRAM.MAGIC[6] & PCF_MAGIC) & (~LOAD_FLAGS | EDP.AR[12]);
    SCD.TRAP_CYC_2 <= SCD.TRAP_CYC_2 & ~TRAP_CLEAR | TRAP_REQ_2 & e22p15;
    SCD.TRAP_CYC_1 <= SCD.TRAP_CYC_1 & TRAP_CLEAR | TRAP_REQ_1 & e22p15;
    SCD.FPD <= CLR_FPD & SCD.FPD | EDP.AR[4] & LOAD_FLAGS | CRAM.MAGIC[2] & PCF_MAGIC;
    SCD.PCP <= (LOAD_PCP | SCD.PCP) & (~LOAD_FLAGS | EDP.AR[0] | JFCL);
  end
  
  always_ff @(posedge clk) TRAP_REQ_2 <= TRAP_REQ_2_EN;
  always_ff @(posedge clk) TRAP_REQ_1 <= TRAP_REQ_1_EN;

  bit e5out;
  assign e5out = SCD.USER | JFCL;
  assign VMA.HELD_OR_PC[0] = (SCD.OV | ~e5out) &
                             (SCD.PCP | JFCL | e5out);
  assign TRAP_CYC_1_OR_2 = SCD.TRAP_CYC_1 | SCD.TRAP_CYC_2;


  // SCD5 p.142
  assign USER_EN = SCD.USER & ~LEAVE_USER |
                   EDP.AR[5] & LOAD_FLAGS;

  assign USER_IOT_EN = SCD.USER_IOT & ~LEAVE_USER & (~LOAD_FLAGS & EDP.AR[6]) |
                       LEAVE_USER & EDP.AR[6] & LOAD_FLAGS |
                       ~SCD.USER & EDP.AR[6] & LOAD_FLAGS |
                       SCD.USER & PIandSAVE_FLAGS;
  assign CLR_PUBLIC = SPEC_PORTAL & SCD.PRIVATE_INSTR |
                      LOAD_FLAGS & EDP.AR[5] & ~SCD.USER;

  assign LEAVE_USER = DISP_FLAG_CTL & ~CRAM.MAGIC[0] |
                      PIandSAVE_FLAGS |
                      RESET |
                      SCD.KERNEL_MODE & ~CRAM.MAGIC[7] & DISP_FLAG_CTL;

  assign PUBLIC_EN = SCD.PUBLIC & ~LEAVE_USER & CLR_PUBLIC |
                     EDP.AR[7] & LOAD_FLAGS |
                     INSTR_FETCH & CLK.MB_XFER & PUBLIC_PAGE;

  bit e6pin14;
  assign e6pin14 = LOAD_FLAGS & EDP.AR[7] | RESET | SCD.PRIVATE_INSTR;
  assign PRIVATE_INSTR_EN = INSTR_FETCH & CON.FM_XFER | ~SCD.PUBLIC |
                            ~INSTR_FETCH & CON.CLR_PRIVATE_INSTR & e6pin14 |
                            CON.CLR_PRIVATE_INSTR & e6pin14 |
                            INSTR_FETCH & CLK.MB_XFER & ~PUBLIC_PAGE;

  always_ff @(posedge clk) SCD.USER <= USER_EN;
  always_ff @(posedge clk) SCD.USER_IOT <= USER_IOT_EN;
  always_ff @(posedge clk) SCD.PUBLIC <= PUBLIC_EN;
  always_ff @(posedge clk) SCD.ADR_BRK_INH <= SCD.ADR_BRK_INH & TRAP_CLEAR |
                                              LOAD_FLAGS & EDP.AR[8] |
                                              CON.COND_INSTR_ABORT & SCD.ADR_BRK_CYC;
  always_ff @(posedge clk) SCD.ADR_BRK_CYC <= SCD.ADR_BRK_CYC & TRAP_CLEAR |
                                              SCD.ADR_BRK_INH & CTL.DISP_NICOND;

  assign SCD.ADR_BRK_PREVENT = SCD.ADR_BRK_INH | SCD.ADR_BRK_CYC;
  assign SCD.KERNEL_USER_IOT = SCD.USER & SCD.USER_IOT | ~SCD.PUBLIC & ~SCD.USER;
  assign PIandSAVE_FLAGS = CTL.SPEC_SAVE_FLAGS & CON.PI_CYCLE;
  assign DISP_SAVE_FLAGS = CTL.SPEC_SAVE_FLAGS;
  assign SCD.KERNEL_MODE = ~SCD.PUBLIC & ~SCD.USER;
  assign PUBLIC_PAGE = PAG.PT_PUBLIC;
  assign INSTR_FETCH = MCL.PAGED_FETCH;
  assign RESET = CLK.MR_RESET;

  assign SET_AD_FLAGS = CON.COND_AD_FLAGS & ~CON.PI_CYCLE;
  assign PCF_MAGIC = CON.COND_PCF_MAGIC & ~CON.PI_CYCLE;
  assign EXP_TEST = CTL.COND_AR_EXP & ~CON.PI_CYCLE;

  assign DISP_FLAG_CTL = CTL.SPEC_FLAG_CTL;
  assign JFCL = CRAM.MAGIC[1] & DISP_FLAG_CTL;
  assign SPEC_PORTAL = CRAM.MAGIC[5] & DISP_FLAG_CTL;
  assign LOAD_FLAGS = RESET | CRAM.MAGIC[4] & DISP_FLAG_CTL;
endmodule
