// 2020-05-23 Schematic review: DP01, DP02, IR4, DP03, DP04
`timescale 1ns/1ns
`include "ebox.svh"

module edp(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM.mod CRAM,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iPI PIC,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,
           iEBUS.mod EBUS,
           iMBOX MBOX,
           input bit [18:35] hwOptions);

  bit [0:17] ARL;
  bit [0:17] ARXL, ARXR;
  
  bit [0:35] ADA;
  bit [-2:35] ADB;
  bit [0:35] ADXA, ADXB;

  bit [0:35] AD_CG, AD_CP;
  bit [0:35] ADX_CG, ADX_CP;

  bit AD_CG06_11, AD_CG12_35, AD_CP06_11, AD_CP12_35;
  bit AD_CG18_23, AD_CG24_35, AD_CP18_23;
  bit AD_CP24_35, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35;
  bit ADX_CP00_11, ADX_CP12_23, ADX_CP24_35;

  bit [-2:36] AD_CRY;           // Local COUT gets XORed
  bit [0:36] ADX_CRY;
  bit [-2:33] AD_EX;

  bit clk;
  assign clk = CLK.EDP;         // Saves typing

  assign EDP.AD_CRY[36] = CTL.AD_CRY_36;
  assign EDP.ADX_CRY[36] = CTL.ADX_CRY_36;

  // AR including ARL, ARR, and ARM p15.
  bit [0:35] ARM;

  // ARL mux DP01 p.15
  always_comb begin
    ARM = '0;

    unique case (CTL.ARL_SEL)
    // These hwOptions bits are wirewrapped
    // onto the backplane for each machine's
    // serial number and hardware options.
    // This is listed in schematics as ARMM
    // but ARMM is only [0:8] and [13:17]
    // (driven by SCD and VMA, respectively).
    // The low half comes from this
    // wirewrapped strapping.
    3'b000: ARM = {EDP.ARMM_SCD, 5'b0, EDP.ARMM_VMA, hwOptions};
    3'b001: ARM = MBOX.CACHE_DATA[0:35];
    3'b010: ARM = EDP.AD[0:35];
    3'b011: ARM = EBUS.data[0:35];
    3'b100: ARM = SHM.SH[0:35];
    3'b101: ARM = {EDP.AD[1:35], EDP.ADX[0]};
    3'b110: ARM = EDP.ADX[0:35];
    3'b111: ARM = {AD_EX[-2:-1], EDP.AD[0:33]};
    endcase

    if (CTL.AR00to11_CLR) ARM[0:11] = '0;
    if (CTL.AR12to17_CLR) ARM[12:17] = '0;
    if (CTL.ARR_CLR) ARM[18:35] = '0;
  end
  
  // EDP.AR
  always_ff @(posedge clk) if (CTL.AR00to08_LOAD) EDP.AR[0:8] <= ARM[0:8];
  always_ff @(posedge clk) if (CTL.AR09to17_LOAD) EDP.AR[9:17] <= ARM[9:17];
  always_ff @(posedge clk) if (CTL.ARR_LOAD)      EDP.AR[18:35] <= ARM[18:35];

  // ARX muxes DP02 p16.
  bit [0:35] ARXM;
  always_comb begin
    ARXM[0:17] = '0;

    unique case (CTL.ARXL_SEL)
              3'b000: ARXM[0:17] = '0;
              3'b001: ARXM[0:17] = MBOX.CACHE_DATA[0:17];
              3'b010: ARXM[0:17] = EDP.AD[0:17];
              3'b011: ARXM[0:17] = EDP.MQ[0:17];
              3'b100: ARXM[0:17] = SHM.SH[0:17];
              3'b101: ARXM[0:17] = EDP.ADX[1:18];
              3'b110: ARXM[0:17] = EDP.ADX[0:17];
              3'b111: ARXM[0:17] = {EDP.AD[34:35], EDP.ADX[0:15]};
              endcase
  end

  always_comb begin
    ARXM[18:35] = '0;

    unique case (CTL.ARXR_SEL)
              3'b000: ARXM[18:35] = '0;
              3'b001: ARXM[18:35] = MBOX.CACHE_DATA[18:35];
              3'b010: ARXM[18:35] = EDP.AD[18:35];
              3'b011: ARXM[18:35] = EDP.MQ[18:35];
              3'b100: ARXM[18:35] = SHM.SH[18:35];
              3'b101: ARXM[18:35] = {EDP.ADX[19:35], EDP.MQ[0]};
              3'b110: ARXM[18:35] = EDP.ADX[18:35];
              3'b111: ARXM[18:35] = EDP.ADX[16:33];
              endcase
  end

  // ARX
  always_ff @(posedge clk) if (CTL.ARX_LOAD) EDP.ARX <= ARXM;

  // MQM mux p16. DP02
  bit [0:35] MQM;

  always_comb begin
    MQM = '0;
    
    if (CTL.MQM_EN) unique case (CTL.MQM_SEL)
                              2'b00: MQM = {EDP.ADX[34:35], EDP.MQ[0:33]};
                              2'b01: MQM = SHM.SH[0:35];
                              2'b10: MQM = EDP.AD[0:35];
                              2'b11: MQM = '1;
                              endcase
  end

  // MQ mux and register
  // MQ: 36-bit MC10141-ish universal shift register
  genvar n;
  generate
    for (n = 0; n < 36; n += 6) begin: mqSR
      bit unusedE13, unusedE15;

      USR4 e13(.S0(MQM[n+1]),
               .D(MQM[n:n+3]),
               .S3(EDP.MQ[n+4]),
               .SEL(CTL.MQ_SEL),
               .CLK(clk),
               .Q({EDP.MQ[n:n+2], unusedE13}));


      USR4 e15(.S0(MQM[n+3]),
               .D(MQM[n+2:n+5]),
               .S3(n < 30 ? EDP.MQ[n+6] : AD_CRY[-2]),
               .SEL(CTL.MQ_SEL),
               .CLK(clk),
               .Q({unusedE15, EDP.MQ[n+3:n+5]}));
    end
  endgenerate


  // DP03 p.17
  // Aliases for simplified access
  bit ADA_EN, AD_BOOL;
  assign ADA_EN = ~CRAM.ADA[0];
  assign AD_BOOL = CRAM.AD[1];

  assign EDP.AD_CRY[-1:35] = AD_CRY[-1:35];

  bit [2:5] adOp;
  assign adOp = CRAM.AD;

  // AD
  generate
    for (n = 0; n < 36; n += 6) begin : ADaluE1E2
      bit e33q10;

      // Misc carry logic, top p.17
      assign e33q10 = EDP.AD[n+0] ^ AD_EX[n-1];
      assign EDP.AD_CRY[n+1] = AD_CRY[n-2] ^ e33q10;
      assign EDP.AD_OVERFLOW[n] = (AD_EX[n-2] ^ AD_EX[n-1]) | e33q10;

      mc10181 e1(.M(AD_BOOL),
//                 .S(CRAM.AD[2:5]),
                 .S(adOp),
                 .A({{3{ADA[n+0]}}, ADA[n+1]}),
                 .B(ADB[n-2:n+1]),
                 .CIN(AD_CRY[n+2]),
                 // Note EDP.AD_EX is a dumping ground when n>0
                 .F({AD_EX[n-2:n-1], EDP.AD[n:n+1]}),
                 .CG(AD_CG[n]),
                 .CP(AD_CP[n]),
                 .COUT(AD_CRY[n-2]));

      mc10181 e2(.M(AD_BOOL),
//                 .S(CRAM.AD[2:5]),
                 .S(adOp),
                 .A(ADA[n+2:n+5]),
                 .B(ADB[n+2:n+5]),
                 .CIN(AD_CRY[n+6]), // Assigned AD_CRY_36 to AD_CRY[36] so this works
                 .F(EDP.AD[n+2:n+5]),
                 .CG(AD_CG[n+2]),
                 .CP(AD_CP[n+2]),
                 .COUT(AD_CRY[n+2]));
    end
  endgenerate
  
  // ADX
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXaluE3E4
      bit unusedE3, unusedE4;

      mc10181 e3(.M(AD_BOOL),
                 .S(adOp),
                 .A({ADXA[n+0], ADXA[n+0], ADXA[n+1:n+2]}),
                 .B({ADXB[n+0], ADXB[n+0], ADXB[n+1:n+2]}),
                 .CIN(ADX_CRY[n+3]),
                 .F({unusedE3, EDP.ADX[n:n+2]}),
                 .CG(ADX_CG[n+0]),
                 .CP(ADX_CP[n+0]),
                 .COUT());
      mc10181 e4(.M(AD_BOOL),
                 .S(adOp),
                 .A({ADXA[n+3], ADXA[n+3], ADXA[n+4:n+5]}),
                 .B({ADXB[n+3], ADXB[n+3], ADXB[n+4:n+5]}),
                 .CIN(ADX_CRY[n+6]), // Assigned ADX_CRY_36 to ADX_CRY[36] so this works
                 .F({unusedE4, EDP.ADX[n+3:n+5]}),
                 .CG(ADX_CG[n+3]),
                 .CP(ADX_CP[n+3]),
                 .COUT(ADX_CRY[n+3]));
    end
  endgenerate

  // AD carry look ahead
  // Moved here from IR4
  mc10179 e11(.G({AD_CG[0], AD_CG[2], AD_CG06_11, AD_CG12_35}),
              .P({AD_CP[0], AD_CP[2], AD_CP06_11, AD_CP12_35}),
              .CIN(AD_CRY[36]),
              .GG(),
              .PG(),
              .C8OUT(EDP.AD_CRY[-2]),
              .C2OUT(EDP.AD_CRY[6]));

  mc10179 e7(.G({AD_CG[6], AD_CG[6], AD_CG[8], AD_CG[8]}),
             .P({AD_CP[6],     1'b0,     1'b0, AD_CP[8]}),
             .CIN(1'b0),
             .GG(AD_CG06_11),
             .PG(AD_CP06_11),
             .C8OUT(),
             .C2OUT());

  mc10179 e2(.G({AD_CG[12], AD_CG[14], AD_CG18_23, AD_CG24_35}),
             .P({AD_CP[12], AD_CP[14], AD_CP18_23, AD_CP24_35}),
             .CIN(AD_CRY[36]),
             .GG(AD_CG12_35),
             .PG(AD_CP12_35),
             .C8OUT(EDP.AD_CRY[12]),
             .C2OUT(EDP.AD_CRY[18]));

  mc10179 e6(.G({~CTL.INH_CRY_18,     ~CTL.INH_CRY_18, AD_CG[18], AD_CG[20]}),
             .P({CTL.SPEC_GEN_CRY_18, 1'b0,            AD_CP[18], AD_CP[20]}),
             .CIN(1'b0),
             .GG(AD_CG18_23),
             .PG(AD_CP18_23),
             .C8OUT(),
             .C2OUT());

  mc10179 e1(.G({AD_CG[24], AD_CG[26], AD_CG[30], AD_CG[32]}),
             .P({AD_CP[24], AD_CP[26], AD_CP[30], AD_CP[32]}),
             .CIN(AD_CRY[36]),
             .GG(AD_CG24_35),
             .PG(AD_CP24_35),
             .C8OUT(EDP.AD_CRY[24]),
             .C2OUT(EDP.AD_CRY[30]));

  // ADX carry look ahead
  // Moved here from IR4
  bit GEN_CRY_36, PROP_CRY_36;
  assign GEN_CRY_36 = CTL.ADX_CRY_36 | CTL.SPEC_AD_LONG;
  assign PROP_CRY_36 = ~CTL.AD_LONG;
  mc10179 e22(.G({ GEN_CRY_36, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35}),
              .P({PROP_CRY_36, ADX_CP00_11, ADX_CP12_23, ADX_CP24_35}),
              .CIN(CTL.ADX_CRY_36),
              .GG(),
              .PG(),
              .C8OUT(EDP.AD_CRY[36]),
              .C2OUT());

  mc10179 e21(.G({ADX_CG[0], ADX_CG[3], ADX_CG[6], ADX_CG[9]}),
              .P({ADX_CP[0], ADX_CP[3], ADX_CP[6], ADX_CP[9]}),
              .CIN(ADX_CRY[12]),
              .GG(ADX_CG00_11),
              .PG(ADX_CP00_11),
              .C8OUT(),
              .C2OUT(ADX_CRY[6]));

  mc10179 e26(.G({ADX_CG[12], ADX_CG[15], ADX_CG[18], ADX_CG[21]}),
              .P({ADX_CP[12], ADX_CP[15], ADX_CP[18], ADX_CP[21]}),
              .CIN(ADX_CRY[24]),
              .GG(),
              .PG(),
              .C8OUT(EDP.ADX_CRY[12]),
              .C2OUT(EDP.ADX_CRY[18]));

  mc10179 e16(.G({ADX_CG[24], ADX_CG[27], ADX_CG[30], ADX_CG[33]}),
              .P({ADX_CP[24], ADX_CP[27], ADX_CP[30], ADX_CP[33]}),
              .CIN(CTL.ADX_CRY_36),
              .GG(ADX_CG24_35),
              .PG(ADX_CP24_35),
              .C8OUT(EDP.ADX_CRY[24]),
              .C2OUT(EDP.ADX_CRY[30]));

  // DP03 p.17
  // ADB mux
  // This was way more complex in the schematics, but it boils down to this.
  always_comb begin
    ADB = '0;

    unique case(CRAM.ADB)
    2'b00: ADB[0:35] = {{2{EDP.FM[0]}}, EDP.FM[0:35]};
    2'b01: ADB[0:35] = {{2{EDP.BR[0]}}, EDP.BR[1:35], EDP.BRX[0]};
    2'b10: ADB[0:35] = {{2{EDP.BR[0]}}, EDP.BR[0:35]};
    2'b11: ADB[0:35] = {EDP.AR[0:35], EDP.ARX[0:1]};
    endcase
  end
  
  // This simplifies the mostly unused bits of the `adbFM` case for
  // ADXB. The schematics show this as # [N+0] H\#400\ (the H\#400\
  // just means to use a certain type of backplane wire (coax for
  // 400?) is to be used). But the CRAM.MAGIC field is only nine bits.
  // I'm pretty sure the remaining pins of ADXB for this case are just
  // floating (i.e., ECL 0).
  bit [0:35] adxbMagic;
  assign adxbMagic = {CRAM.MAGIC, 27'b0};
  // ADXB mux
  always_comb begin
    ADXB = '0;

    unique case(CRAM.ADB)
    2'b00: ADXB[0:35] = adxbMagic[0:35];
    2'b01: ADXB[0:35] = {EDP.BRX[1:35], 1'b0};
    2'b10: ADXB[0:35] = EDP.BRX[0:35];
    2'b11: ADXB[0:35] = {EDP.ARX[2:35], 2'b00};
    endcase
  end

  // ADA mux E16,E18
  always_comb begin
    ADA = '0;

    unique case (CRAM.ADA)
    2'b00: ADA = EDP.AR[0:35];
    2'b01: ADA = EDP.ARX[0:35];
    2'b10: ADA = EDP.MQ[0:35];
    2'b11: ADA = VMA.HELD_OR_PC[0:35];
    endcase
  end

  // ADXA mux E17,E5
  assign ADXA[0:35] = ADA_EN ? EDP.ARX[0:35] : '0;


  // DP04 p.18
  // BR and BRX
  always_ff @(posedge clk) if (CRAM.BR  ==   brAR) EDP.BR  <= EDP.AR;
  always_ff @(posedge clk) if (CRAM.BRX == brxARX) EDP.BRX <= EDP.ARX;

  // DIAG or AD driving EBUS.
  //
  // If either CTL_adToEBUS_{L,R} is lit we force AD as the source XXX
  // this is wrong. But it might be right enough. And I don't want to
  // go change every EBUSdriver.driving into LH and RH separately.
  // Because that would be arsing tedious as fuck.
  bit [0:35] ebusR;
  assign EDP.EBUSdriver.driving = CTL.DIAG_READ_FUNC_12x | CTL.AD_TO_EBUS_L | CTL.AD_TO_EBUS_R;
  assign EDP.EBUSdriver.data[ 0:17] = (CTL.DIAG_READ_FUNC_12x || CTL.AD_TO_EBUS_L) ? ebusR[0:17] : '0;
  assign EDP.EBUSdriver.data[18:35] = (CTL.DIAG_READ_FUNC_12x || CTL.AD_TO_EBUS_R) ? ebusR[18:35] : '0;

  always_comb if (EDP.EBUSdriver.driving)
    unique case ((CTL.AD_TO_EBUS_L | CTL.AD_TO_EBUS_R) ? 3'b111 : CTL.DIAG[4:6])
    default: ebusR <= '0;
    3'b000: ebusR <= EDP.AR;
    3'b001: ebusR <= EDP.BR;
    3'b010: ebusR <= EDP.MQ;
    3'b011: ebusR <= EDP.FM;
    3'b100: ebusR <= EDP.BRX;
    3'b101: ebusR <= EDP.ARX;
    3'b110: ebusR <= EDP.ADX[0:35];
    3'b111: ebusR <= EDP.AD[0:35];
    endcase

  // FM. No static at all!
`ifdef TB
  // Simulated fake memory can have "bytes" of 18 bits for simple
  // LH/RH byte write enable.
  sim_mem
    #(.SIZE(128), .WIDTH(36), .NBYTES(2))
  fm
    (.clk(EDP.FM_WRITE),
     .din(EDP.AR),
     .dout(EDP.FM),
     .addr({APR.FM_BLOCK, APR.FM_ADR}),
     .oe(1'b1),
     .wea({CON.FM_WRITE00_17, CON.FM_WRITE18_35}));
`else
  // NOTE: fm_mem is byte writable with 9-bit bytes so we can do
  // halfword writes by writing two "bytes" at a time.
  fm_mem fm(.addra({APR.FM_BLOCK, APR.FM_ADR}),
            .clka(EDP.FM_WRITE),
            .dina(EDP.AR),
            .douta(EDP.FM),
            .wea({CON.FM_WRITE00_17, CON.FM_WRITE00_17,
                  CON.FM_WRITE18_35, CON.FM_WRITE18_35})
            );
`endif

  assign EDP.FM_PARITY = ^EDP.FM;
endmodule
