`timescale 1ns/1ns
// XXX TODO: Refactor this into six instances of the same module wired
// together in ebox.v?
`include "ebox.svh"

module edp(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRAM CRAM,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iPI PIC,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,
           iEBUS EBUS,
           iMBOX MBOX
);

  // Universal shift register function selector values
  enum bit [0:1] {usrLOAD, usrSHL, usrSHR, usrHOLD} tUSRfunc;
  
  bit [0:17] ARL;
  bit [0:17] ARXL, ARXR;
  
  bit [0:35] MQM;

  bit [0:35] ADA;
  bit [-2:35] ADB;
  bit [0:35] ADXA, ADXB;

  bit [0:35] AD_CG, AD_CP;
  bit [0:35] ADX_CG, ADX_CP;

  bit AD_CG06_11, AD_CG12_35, AD_CP06_11, AD_CP12_35;
  bit AD_CG18_23, AD_CG24_35, AD_CP18_23;
  bit AD_CP24_35, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35;
  bit ADX_CP00_11, ADX_CP12_23, ADX_CP24_35;

`include "cram-aliases.svh"
  
  // XXX wrong?
  assign EDP.AD_CRY[36] = CTL.AD_CRY_36;

  // FM. No static at all!
`ifdef KL10PV_TB
  // Simulated fake memory can have "bytes" of 18 bits for simple
  // LH/RH byte write enable.
  sim_mem
    #(.SIZE(128), .WIDTH(36), .NBYTES(2))
  fm
  (.clk(EDP.FM_WRITE),
   .din(EDP.AR),
   .dout(EDP.FM),
   .addr({APR.FM_BLOCK, APR.FM_ADR}),
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

  // Initial states for our registers
  initial begin
    EDP.AR = '0;
    EDP.ARX = '0;
    EDP.BR = '0;
    EDP.BRX = '0;
    EDP.MQ = '0;
  end


  // AR including ARL, ARR, and ARM p15.
  // ARL mux
  always_comb begin
    unique case (CTL.ARL_SEL)
    default: ARL = '0;
    3'b000: ARL = {SCD.ARMM_UPPER, 5'b0, SCD.ARMM_LOWER};
    3'b001: ARL = MBOX.CACHE_DATA[0:17];
    3'b010: ARL = EDP.AD[0:17];
    3'b011: ARL = EBUS.data[0:17];
    3'b100: ARL = SHM.SH[0:17];
    3'b101: ARL = EDP.AD[1:18];
    3'b110: ARL = EDP.ADX[0:17];
    3'b111: ARL = {EDP.AD_EX[-2:-1], EDP.AD[0:14]};
    endcase
  end
  
  // EDP.AR
  always_ff @(posedge CLK.EDP) begin

    if (CTL.AR00to11_CLR) begin
      EDP.AR[0:11] <= '0;
    end else if (CTL.AR00to08_LOAD) begin
      EDP.AR[0:8] <= ARL[0:8];
    end

    if (CTL.AR12to17_CLR) begin
      EDP.AR[12:17] <= '0;
    end else if (CTL.AR09to17_LOAD) begin
      EDP.AR[9:17] <= ARL[9:17];
    end

    if (CTL.ARR_CLR) begin
      EDP.AR[18:35] <= '0;
    end else if (CTL.ARR_LOAD) begin
      unique case (CRAM.AR)
      3'b000: EDP.AR[18:35] <= {SCD.ARMM_UPPER, 5'b0, SCD.ARMM_LOWER}; // XXX?
      3'b001: EDP.AR[18:35] <= MBOX.CACHE_DATA[18:35];
      3'b010: EDP.AR[18:35] <= EDP.AD[18:35];
      3'b011: EDP.AR[18:35] <= EBUS.data[18:35];
      3'b100: EDP.AR[18:35] <= SHM.SH[18:35];
      3'b101: EDP.AR[18:35] <= {EDP.AD[19:35], EDP.ADX[0]};
      3'b110: EDP.AR[18:35] <= EDP.ADX[18:35];
      3'b111: EDP.AR[18:35] <= EDP.AD[16:33];
      endcase
    end
  end

  // ARX muxes p16.
  always_comb begin

    unique case (CTL.ARXL_SEL)
    default: ARXL = '0;
    3'b000: ARXL = '0;
    3'b001: ARXL = MBOX.CACHE_DATA[0:17];
    3'b010: ARXL = EDP.AD[0:17];
    3'b011: ARXL = EDP.MQ[0:17];
    3'b100: ARXL = SHM.SH[0:17];
    3'b101: ARXL = EDP.ADX[1:18];
    3'b110: ARXL = EDP.ADX[0:17];
    3'b111: ARXL = {EDP.AD[34:35], EDP.ADX[0:15]};
    endcase

    unique case (CTL.ARXR_SEL)
    default: ARXR = '0;
    3'b000: ARXR = '0;
    3'b001: ARXR = MBOX.CACHE_DATA[18:35];
    3'b010: ARXR = EDP.AD[18:35];
    3'b011: ARXR = EDP.MQ[18:35];
    3'b100: ARXR = SHM.SH[18:35];
    3'b101: ARXR = {EDP.ADX[19:35], EDP.MQ[0]};
    3'b110: ARXR = EDP.ADX[18:35];
    3'b111: ARXR = EDP.ADX[16:33];
    endcase
  end

  // ARX
  always_ff @(posedge CLK.EDP) begin
    if (CTL.ARX_LOAD) EDP.ARX <= {ARXL, ARXR};
  end

  // MQM mux p16.
  always_comb begin

    if (CTL.MQM_EN) begin

      unique case (CTL.MQM_SEL)
      default: MQM = {EDP.ADX[34:35], EDP.MQ[0:33]};
      usrLOAD: MQM = {EDP.ADX[34:35], EDP.MQ[0:33]};
      usrSHL:  MQM = SHM.SH;
      usrSHR:  MQM = EDP.AD[0:35];
      usrHOLD: MQM = '1;
      endcase
    end else
      MQM = '0;
  end

  // MQ mux and register
  always_ff @(posedge CLK.EDP) begin

    // MQ: 36-bit MC10141-ish universal shift register
    unique case (CTL.MQ_SEL)
    default: EDP.MQ <= '0;
    usrLOAD: EDP.MQ <= MQM;
    usrSHL:  EDP.MQ <= {MQM[1:35], EDP.AD_CRY[-2]};
    usrSHR:  EDP.MQ <= {MQM[1], MQM[1:35]};
    usrHOLD: EDP.MQ <= EDP.MQ;
    endcase
  end

  // Look-ahead carry network moved here from IR4 M8522 board.
  bit [0:35] ADEXxortmp;

  // Why is this necessary?
  bit [0:3] S;
  always_comb S = CRAM.AD[2:5];

  // AD
  genvar n;
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADaluE1E2

      // Misc carry logic, top p.17
      assign ADEXxortmp[n] = EDP.AD[n+0] ^ EDP.AD_EX[n-1];
      assign EDP.AD_CRY[n+1] = EDP.AD_CRY[n-2] ^ ADEXxortmp[n];
      assign EDP.AD_OV[n] = EDP.AD_EX[n-2]  ^ ADEXxortmp[n];

      mc10181 alu0(.M(AD_BOOL),
                   .S(S),
                   .A({{3{ADA[n+0]}}, ADA[n+1]}),
                   .B(ADB[n-2:n+1]),
                   .CIN(EDP.AD_CRY[n+2]),
                   // Note EDP.AD_EX is a dumping ground when n>0
                   .F({EDP.AD_EX[n-2:n-1], EDP.AD[n:n+1]}),
                   .CG(AD_CG[n+0]),
                   .CP(AD_CP[n+0])/*,
                   .COUT(EDP.AD_CRY[n-2])*/); // XXX multi-drives EDP.AD_CRY[-2] w/E11 below
      mc10181 alu1(.M(AD_BOOL),
                   .S(S),
                   .A(ADA[n+2:n+5]),
                   .B(ADB[n+2:n+5]),
                   .CIN(EDP.AD_CRY[n+6]),
                   .F(EDP.AD[n+2:n+5]),
                   .CG(AD_CG[n+2]),
                   .CP(AD_CP[n+2]),
                   .COUT(EDP.AD_CRY[n+2]));
    end
  endgenerate
  
  // ADX
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADXaluE3E4
      bit x1, x2;

      mc10181 alu2(.M(AD_BOOL),
                   .S(S),
                   .A({ADXA[n+0], ADXA[n+0], ADXA[n+1:n+2]}),
                   .B({ADXB[n+0], ADXB[n+0], ADXB[n+1:n+2]}),
                   .CIN(EDP.ADX_CRY[n+3]),
                   .F({x1, EDP.ADX[n:n+2]}),
                   .CG(ADX_CG[n+0]),
                   .CP(ADX_CP[n+0]));
      mc10181 alu3(.M(AD_BOOL),
                   .S(S),
                   .A({ADXA[n+3], ADXA[n+3], ADXA[n+4:n+5]}),
                   .B({ADXB[n+3], ADXB[n+3], ADXB[n+4:n+5]}),
                   .CIN(n < 30 ? EDP.ADX_CRY[n+6] : CTL.ADX_CRY_36),
                   .F({x2, EDP.ADX[n+3:n+5]}),
                   .CG(ADX_CG[n+3]),
                   .CP(ADX_CP[n+3]),
                   .COUT(EDP.ADX_CRY[n+3]));
    end
  endgenerate

  // AD carry look ahead
  // Moved here from IR4
  assign EDP.GEN_CRY_36 = CTL.ADX_CRY_36 | CTL.SPEC_AD_LONG;
  
  // IR4 E11
  mc10179 AD_LCG_E11(.G({AD_CG[0], AD_CG[2], AD_CG06_11, AD_CG12_35}),
                     .P({AD_CP[0], AD_CP[2], AD_CP06_11, AD_CP12_35}),
                     .CIN(EDP.AD_CRY[36]),
                     .C8OUT(EDP.AD_CRY[-2]),
                     .C2OUT(EDP.AD_CRY[6]));

  // IR4 E7
  mc10179 AD_LCG_E7(.G({AD_CG[6], AD_CG[6], AD_CG[8], AD_CG[8]}),
                    .P({AD_CP[6],     1'b0,     1'b0, AD_CP[8]}),
                    .CIN(1'b0),
                    .GG(AD_CG06_11),
                    .PG(AD_CP06_11));

  // IR4 E2
  mc10179 AD_LCG_E2(.G({AD_CG[12], AD_CG[14], AD_CG18_23, AD_CG24_35}),
                    .P({AD_CP[12], AD_CP[14], AD_CP18_23, AD_CP24_35}),
                    .CIN(EDP.AD_CRY[36]),
                    .GG(AD_CG12_35),
                    .PG(AD_CP12_35),
                    .C8OUT(EDP.AD_CRY[12]),
                    .C2OUT(EDP.AD_CRY[18]));

  // IR4 E6
  mc10179 AD_LCG_E6(.G({~CTL.INH_CRY_18, ~CTL.INH_CRY_18, AD_CG[18], AD_CG[20]}),
                    .P({CTL.SPEC_GEN_CRY_18, 1'b0, AD_CP[18], AD_CP[20]}),
                    .CIN(1'b0),
                    .GG(AD_CG18_23),
                    .PG(AD_CP18_23));

  // IR4 E1
  mc10179 AD_LCG_E1(.G({AD_CG[24], AD_CG[26], AD_CG[30], AD_CG[32]}),
                    .P({AD_CP[24], AD_CP[26], AD_CP[30], AD_CP[32]}),
                    .CIN(EDP.AD_CRY[36]),
                    .GG(AD_CG24_35),
                    .PG(AD_CP24_35),
                    .C8OUT(EDP.AD_CRY[24]),
                    .C2OUT(EDP.AD_CRY[30]));

  // ADX carry look ahead
  // Moved here from IR4
  // IR4 E22
  mc10179 ADX_LCG_E22(.G({   EDP.GEN_CRY_36, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35}),
                      .P({~CTL.SPEC_AD_LONG, ADX_CP00_11, ADX_CP12_23, ADX_CP24_35}),
                      .CIN(CTL.ADX_CRY_36),
                      .C8OUT(EDP.AD_CRY[36]));
  // IR4 E21
  mc10179 ADX_LCG_E21(.G({ADX_CG[0], ADX_CG[3], ADX_CG[6], ADX_CG[9]}),
                      .P({ADX_CP[0], ADX_CP[3], ADX_CP[6], ADX_CP[9]}),
                      .CIN(EDP.ADX_CRY[12]),
                      .GG(ADX_CG00_11),
                      .PG(ADX_CP00_11));
  // IR4 E26
  mc10179 ADX_LCG_E26(.G({ADX_CG[12], ADX_CG[15], ADX_CG[18], ADX_CG[21]}),
                      .P({ADX_CP[12], ADX_CP[15], ADX_CP[18], ADX_CP[21]}),
                      .CIN(EDP.ADX_CRY[24]),
                      .C8OUT(EDP.ADX_CRY[12]),
                      .C2OUT(EDP.ADX_CRY[18]));
  // IR4 E16
  mc10179 ADX_LCG_E16(.G({ADX_CG[24], ADX_CG[27], ADX_CG[30], ADX_CG[33]}),
                      .P({ADX_CP[24], ADX_CP[27], ADX_CP[30], ADX_CP[33]}),
                      .CIN(CTL.ADX_CRY_36),
                      .GG(ADX_CG24_35),
                      .PG(ADX_CP24_35),
                      .C8OUT(EDP.ADX_CRY[24]),
                      .C2OUT(EDP.ADX_CRY[30]));

  // ADB mux
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADBmux

      always_comb begin
        // The irregular part of ADB mux: E22 and E21.
        // When N==0, D4..D7 inputs are selected else D0..D3.
        //
        // In the real KL10 EDP the ADB[-2],ADB[-1] are handled by
        // this bit. But when N > 0, they wire-OR with other signals.
        // I am resolving this by forcing this logic only for N=0.
        if (n == 0) begin
          unique case(CRAM.ADB)
          default: ADB[n-2:n-1] = '0;
          adbFM:   ADB[n-2:n-1] = {2{EDP.FM[n+0]}};
          adbBRx2: ADB[n-2:n-1] = {2{n == 0 ? EDP.BR[n+0] : EDP.BR[n+1]}};
          adbBR:   ADB[n-2:n-1] = {2{EDP.BR[n+0]}};
          adbARx4: ADB[n-2:n-1] = {n == 0 ? EDP.AR[n+0] : EDP.AR[n+2],
                                   n == 0 ? EDP.AR[n+1] : EDP.AR[n+2]};
          endcase
        end

        // The regular part of ADB mux: E23, E26, and E19.
        unique case(CRAM.ADB)
        default: ADB[n:n+5] = '0;
        adbFM:   ADB[n:n+5] = EDP.FM[n+0:n+5];
        adbBRx2: ADB[n:n+5] = {EDP.BR[n+1:n+5], n < 30 ? EDP.BR[n+6] : EDP.BRX[0]};
        adbBR:   ADB[n:n+5] = EDP.BR[n+0:n+5];
        adbARx4: ADB[n:n+5] = {EDP.AR[n+2:n+5], n < 30 ? EDP.AR[n+6:n+7] : EDP.ARX[0:1]};
        endcase
      end
    end
  endgenerate

  // ADXB mux
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADXBmux
      always_comb
        unique case(CRAM.ADB)
        default: ADXB[n+0:n+5] = '0;
        adbFM:   ADXB[n+0:n+5] = n < 6 ? CRAM.MAGIC[n+0:n+5] : 6'b0;
        adbBRx2: ADXB[n+0:n+5] = n < 30 ? EDP.BRX[n+1:n+6] : {EDP.BRX[n+1:n+5], 1'b0};
        adbBR:   ADXB[n+0:n+5] = EDP.BRX[n+0:n+5];
        adbARx4: ADXB[n+0:n+5] = n < 30 ? EDP.ARX[n+2:n+7] : {EDP.ARX[n+2:n+5], 2'b00};
        endcase
    end
  endgenerate

  // ADXA mux
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADXAmux
      always_comb ADXA[n+0:n+5] = ADA_EN ? 6'b0 : EDP.ARX[n+0:n+5];
    end
  endgenerate


  // ADA mux
  generate
    for (n = '0; n < 36; n = n + 6) begin : ADAmux
      always_comb
        if (~ADA_EN)
          unique case(CRAM.ADA)
          default: ADA[n+0:n+5] = '0;
          adaAR:  ADA[n+0:n+5] = EDP.AR[n+0:n+5];
          adaARX: ADA[n+0:n+5] = EDP.ARX[n+0:n+5];
          adaMQ:  ADA[n+0:n+5] = EDP.MQ[n+0:n+5];
          adaPC:  ADA[n+0:n+5] = VMA.HELD_OR_PC[n+0:n+5];
          endcase
        else
          ADA[n+0:n+5] = '0;
    end
  endgenerate


  // BRX
  always_ff @(posedge CLK.EDP) begin
    if (CRAM.BRX == brxARX) EDP.BRX <= EDP.ARX;
  end

  // BR
  always_ff @(posedge CLK.EDP) begin
    if (CRAM.BR == brAR) EDP.BR <= EDP.AR;
  end

  // DIAG or AD driving EBUS
  // If either CTL_adToEBUS_{L,R} is lit we force AD as the source
  bit [0:35] ebusR;
  assign EDP.EBUSdriver.driving = CTL.DIAG_READ_FUNC_12x ||
                                  CTL.AD_TO_EBUS_L ||
                                  CTL.AD_TO_EBUS_R;
  assign EDP.EBUSdriver.data[0:17] = (CTL.DIAG_READ_FUNC_12x || CTL.AD_TO_EBUS_L) ?
                                     ebusR[0:17] : '0;
  assign EDP.EBUSdriver.data[18:35] = (CTL.DIAG_READ_FUNC_12x || CTL.AD_TO_EBUS_R) ?
                                      ebusR[18:35] : '0;

  always_ff @(posedge CLK.EDP) begin

    if (EDP.EBUSdriver.driving) begin

      unique case ((CTL.AD_TO_EBUS_L | CTL.AD_TO_EBUS_R) ?  3'b111 : DIAG_FUNC[4:6])
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
    end else
      ebusR <= 'z;
  end
endmodule
