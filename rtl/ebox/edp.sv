`timescale 1ns/1ns
// XXX TODO: Refactor this into six instances of the same module wired
// together in ebox.v?
`include "cram-defs.svh"
`include "ebus-defs.svh"

module edp(input eboxClk,
           input fastMemClk,
           input eboxReset,
           input CTL_AD_CRY_36,
           input CTL_ADX_CRY_36,

           iCRAM CRAM,

           input [0:2] CTL_ARL_SEL,
           input [0:2] CTL_ARR_SEL,
           input CTL_AR00to08_LOAD,
           input CTL_AR09to17_LOAD,
           input CTL_ARR_LOAD,

           input CTL_AR00to11_CLR,
           input CTL_AR12to17_CLR,
           input CTL_ARR_CLR,

           input [0:2] CTL_ARXL_SEL,
           input [0:2] CTL_ARXR_SEL,
           input CTL_ARX_LOAD,

           input [0:1] CTL_MQ_SEL,
           input [0:1] CTL_MQM_SEL,
           input CTL_MQM_EN,
           input CTL_INH_CRY_18,
           input CTL_SPEC_AD_LONG,
           input CTL_SPEC_GEN_CRY18,

           input [0:35] cacheDataRead,
           output logic [0:35] cacheDataWrite,
           iEBUS EBUS,
           tEBUSdriver EBUSdriver,
           input [0:35] SHM_SH,
           input [0:8] SCD_ARMM_UPPER,
           input [13:17] SCD_ARMM_LOWER,

           input CTL_adToEBUS_L,
           input CTL_adToEBUS_R,

           input [0:2] APR_FMblk,
           input [0:3] APR_FMadr,

           input CON_FM_WRITE00_17,
           input CON_FM_WRITE18_35,

           input CTL_DIAG_READ_FUNC_12x,

           input [0:35] VMA_VMAheldOrPC,

           output logic [0:35] FM,
           output fmParity,

           iEDP EDP);

  // Universal shift register function selector values
  enum logic [0:1] {usrLOAD, usrSHL, usrSHR, usrHOLD} tUSRfunc;
  
  /*AUTOWIRE*/
  /*AUTOREG*/

  logic [0:17] ARL;
  logic [0:17] ARXL, ARXR;
  
  logic [0:35] MQM;

  logic [0:35] ADA;
  logic [-2:35] ADB;
  logic [0:35] ADXA, ADXB;

  logic [0:35] AD_CG, AD_CP;
  logic [0:35] ADX_CG, ADX_CP;

  logic AD_CG06_11, AD_CG12_35, AD_CP06_11, AD_CP12_35;
  logic AD_CG18_23, AD_CG24_35, AD_CP18_23;
  logic AD_CP24_35, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35;
  logic ADX_CP00_11, ADX_CP12_23, ADX_CP24_35;

`include "cram-aliases.svh"
  
  // Miscellaneous reset (XXX)
  always_ff @(posedge eboxClk) begin
    if (eboxReset) cacheDataWrite <= 0;
  end
  
  // XXX wrong?
  assign EDP_ADcarry[36] = CTL_AD_CRY_36;

  // AR including ARL, ARR, and ARM p15.
  // ARL mux
  always_comb begin
    unique case (CTL_ARL_SEL)
    default: ARL = 'x;
    3'b000: ARL = {SCD_ARMM_UPPER, 5'b0, SCD_ARMM_LOWER};
    3'b001: ARL = cacheDataRead[0:17];
    3'b010: ARL = EDP_AD[0:17];
    3'b011: ARL = EBUS.data[0:17];
    3'b100: ARL = SHM_SH[0:17];
    3'b101: ARL = EDP_AD[1:18];
    3'b110: ARL = EDP_ADX[0:17];
    3'b111: ARL = {EDP_AD_EX[-2:-1], EDP_AD[0:14]};
    endcase
  end
  
  // EDP_AR
  always_ff @(posedge eboxClk) begin

    // RESET
    if (eboxReset) begin
      EDP_AR <= '0;
    end else begin

      if (CTL_AR00to11_CLR) begin
        EDP_AR[0:11] <= 0;
      end else if (CTL_AR00to08_LOAD) begin
        EDP_AR[0:8] <= ARL[0:8];
      end

      if (CTL_AR12to17_CLR) begin
        EDP_AR[12:17] <= 0;
      end else if (CTL_AR09to17_LOAD) begin
        EDP_AR[9:17] <= ARL[9:17];
      end

      if (CTL_ARR_CLR) begin
        EDP_AR[18:35] <= 0;
      end else if (CTL_ARR_LOAD) begin
        unique case (CRAM.AR)
        3'b000: EDP_AR[18:35] <= {SCD_ARMM_UPPER, 5'b0, SCD_ARMM_LOWER}; // XXX?
        3'b001: EDP_AR[18:35] <= cacheDataRead[18:35];
        3'b010: EDP_AR[18:35] <= EDP_AD[18:35];
        3'b011: EDP_AR[18:35] <= EBUS.data[18:35];
        3'b100: EDP_AR[18:35] <= SHM_SH[18:35];
        3'b101: EDP_AR[18:35] <= {EDP_AD[19:35], EDP_ADX[0]};
        3'b110: EDP_AR[18:35] <= EDP_ADX[18:35];
        3'b111: EDP_AR[18:35] <= EDP_AD[16:33];
        endcase
      end
    end
  end

  // ARX muxes p16.
  always_comb begin

    unique case (CTL_ARXL_SEL)
    default: ARXL = 'x;
    3'b000: ARXL = 0;
    3'b001: ARXL = cacheDataRead[0:17];
    3'b010: ARXL = EDP_AD[0:17];
    3'b011: ARXL = EDP_MQ[0:17];
    3'b100: ARXL = SHM_SH[0:17];
    3'b101: ARXL = EDP_ADX[1:18];
    3'b110: ARXL = EDP_ADX[0:17];
    3'b111: ARXL = {EDP_AD[34:35], EDP_ADX[0:15]};
    endcase

    unique case (CTL_ARXR_SEL)
    default: ARXR = 'x;
    3'b000: ARXR = 0;
    3'b001: ARXR = cacheDataRead[18:35];
    3'b010: ARXR = EDP_AD[18:35];
    3'b011: ARXR = EDP_MQ[18:35];
    3'b100: ARXR = SHM_SH[18:35];
    3'b101: ARXR = {EDP_ADX[19:35], EDP_MQ[0]};
    3'b110: ARXR = EDP_ADX[18:35];
    3'b111: ARXR = EDP_ADX[16:33];
    endcase
  end

  // ARX
  always_ff @(posedge eboxClk) begin

    // RESET
    if (eboxReset) begin
      EDP_ARX <= '0;
    end else if (CTL_ARX_LOAD)
      EDP_ARX <= {ARXL, ARXR};
  end

  // MQM mux p16.
  always_comb begin

    if (CTL_MQM_EN) begin

      unique case (CTL_MQM_SEL)
      usrLOAD: MQM = {EDP_ADX[34:35], EDP_MQ[0:33]};
      usrSHL:  MQM = SHM_SH;
      usrSHR:  MQM = EDP_AD[0:35];
      usrHOLD: MQM = '1;
      endcase
    end else
      MQM = '0;
  end

  // MQ mux and register
  always_ff @(posedge eboxClk) begin

    if (eboxReset) begin
      EDP_MQ <= 0;
    end else begin
      
      // MQ: 36-bit MC10141-ish universal shift register
      unique case (CTL_MQ_SEL)
      default: EDP_MQ <= 'x;
      usrLOAD: EDP_MQ <= MQM;
      usrSHL:  EDP_MQ <= {MQM[1:35], EDP_ADcarry[-2]};
      usrSHR:  EDP_MQ <= {MQM[1], MQM[1:35]};
      usrHOLD: EDP_MQ <= EDP_MQ;
      endcase
    end
  end

  // Look-ahead carry network moved here from IR4 M8522 board.
  logic [0:35] ADEXxortmp;

  // Why is this necessary?
  logic [0:3] S;
  always_comb S = CRAM.AD[2:5];

  // AD
  genvar n;
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADaluE1E2

      // Misc carry logic, top p.17
      assign ADEXxortmp[n] = EDP_AD[n+0] ^ EDP_AD_EX[n-1];
      assign EDP_ADcarry[n+1] = EDP_ADcarry[n-2] ^ ADEXxortmp[n];
      assign EDP_ADoverflow[n] = EDP_AD_EX[n-2]  ^ ADEXxortmp[n];

      mc10181 alu0(.M(ADbool),
                   .S(S),
                   .A({{3{ADA[n+0]}}, ADA[n+1]}),
                   .B(ADB[n-2:n+1]),
                   .CIN(EDP_ADcarry[n+2]),
                   // Note EDP_AD_EX is a dumping ground when n>0
                   .F({EDP_AD_EX[n-2:n-1], EDP_AD[n:n+1]}),
                   .CG(AD_CG[n+0]),
                   .CP(AD_CP[n+0])/*,
                   .COUT(EDP_ADcarry[n-2])*/); // XXX multi-drives EDP_ADcarry[-2] w/E11 below
      mc10181 alu1(.M(ADbool),
                   .S(S),
                   .A(ADA[n+2:n+5]),
                   .B(ADB[n+2:n+5]),
                   .CIN(EDP_ADcarry[n+6]),
                   .F(EDP_AD[n+2:n+5]),
                   .CG(AD_CG[n+2]),
                   .CP(AD_CP[n+2]),
                   .COUT(EDP_ADcarry[n+2]));
    end
  endgenerate
  
  // ADX
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXaluE3E4

      mc10181 alu2(.M(ADbool),
                   .S(S),
                   .A({ADXA[n+0], ADXA[n+0], ADXA[n+1:n+2]}),
                   .B({ADXB[n+0], ADXB[n+0], ADXB[n+1:n+2]}),
                   .CIN(EDP_ADXcarry[n+3]),
                   .F({1'bx, EDP_ADX[n:n+2]}),
                   .CG(ADX_CG[n+0]),
                   .CP(ADX_CP[n+0]));
      mc10181 alu3(.M(ADbool),
                   .S(S),
                   .A({ADXA[n+3], ADXA[n+3], ADXA[n+4:n+5]}),
                   .B({ADXB[n+3], ADXB[n+3], ADXB[n+4:n+5]}),
                   .CIN(n < 30 ? EDP_ADXcarry[n+6] : CTL_ADX_CRY_36),
                   .F({1'bx, EDP_ADX[n+3:n+5]}),
                   .CG(ADX_CG[n+3]),
                   .CP(ADX_CP[n+3]),
                   .COUT(EDP_ADXcarry[n+3]));
    end
  endgenerate

  // AD carry look ahead
  // Moved here from IR4
  assign EDP_genCarry36 = CTL_ADX_CRY_36 | CTL_SPEC_AD_LONG;
  
  // IR4 E11
  mc10179 AD_LCG_E11(.G({AD_CG[0], AD_CG[2], AD_CG06_11, AD_CG12_35}),
                     .P({AD_CP[0], AD_CP[2], AD_CP06_11, AD_CP12_35}),
                     .CIN(EDP_ADcarry[36]),
                     .C8OUT(EDP_ADcarry[-2]),
                     .C2OUT(EDP_ADcarry[6]));

  // IR4 E7
  mc10179 AD_LCG_E7(.G({AD_CG[6], AD_CG[6], AD_CG[8], AD_CG[8]}),
                    .P({AD_CP[6],     1'b0,     1'b0, AD_CP[8]}),
                    .CIN(1'b0),
                    .GG(AD_CG06_11),
                    .PG(AD_CP06_11));

  // IR4 E2
  mc10179 AD_LCG_E2(.G({AD_CG[12], AD_CG[14], AD_CG18_23, AD_CG24_35}),
                    .P({AD_CP[12], AD_CP[14], AD_CP18_23, AD_CP24_35}),
                    .CIN(EDP_ADcarry[36]),
                    .GG(AD_CG12_35),
                    .PG(AD_CP12_35),
                    .C8OUT(EDP_ADcarry[12]),
                    .C2OUT(EDP_ADcarry[18]));

  // IR4 E6
  mc10179 AD_LCG_E6(.G({~CTL_INH_CRY_18, ~CTL_INH_CRY_18, AD_CG[18], AD_CG[20]}),
                    .P({CTL_SPEC_GEN_CRY18, 1'b0, AD_CP[18], AD_CP[20]}),
                    .CIN(1'b0),
                    .GG(AD_CG18_23),
                    .PG(AD_CP18_23));

  // IR4 E1
  mc10179 AD_LCG_E1(.G({AD_CG[24], AD_CG[26], AD_CG[30], AD_CG[32]}),
                    .P({AD_CP[24], AD_CP[26], AD_CP[30], AD_CP[32]}),
                    .CIN(EDP_ADcarry[36]),
                    .GG(AD_CG24_35),
                    .PG(AD_CP24_35),
                    .C8OUT(EDP_ADcarry[24]),
                    .C2OUT(EDP_ADcarry[30]));

  // ADX carry look ahead
  // Moved here from IR4
  // IR4 E22
  mc10179 ADX_LCG_E22(.G({   EDP_genCarry36, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35}),
                      .P({~CTL_SPEC_AD_LONG, ADX_CP00_11, ADX_CP12_23, ADX_CP24_35}),
                      .CIN(CTL_ADX_CRY_36),
                      .C8OUT(EDP_ADcarry[36]));
  // IR4 E21
  mc10179 ADX_LCG_E21(.G({ADX_CG[0], ADX_CG[3], ADX_CG[6], ADX_CG[9]}),
                      .P({ADX_CP[0], ADX_CP[3], ADX_CP[6], ADX_CP[9]}),
                      .CIN(EDP_ADXcarry[12]),
                      .GG(ADX_CG00_11),
                      .PG(ADX_CP00_11));
  // IR4 E26
  mc10179 ADX_LCG_E26(.G({ADX_CG[12], ADX_CG[15], ADX_CG[18], ADX_CG[21]}),
                      .P({ADX_CP[12], ADX_CP[15], ADX_CP[18], ADX_CP[21]}),
                      .CIN(EDP_ADXcarry[24]),
                      .C8OUT(EDP_ADXcarry[12]),
                      .C2OUT(EDP_ADXcarry[18]));
  // IR4 E16
  mc10179 ADX_LCG_E16(.G({ADX_CG[24], ADX_CG[27], ADX_CG[30], ADX_CG[33]}),
                      .P({ADX_CP[24], ADX_CP[27], ADX_CP[30], ADX_CP[33]}),
                      .CIN(CTL_ADX_CRY_36),
                      .GG(ADX_CG24_35),
                      .PG(ADX_CP24_35),
                      .C8OUT(EDP_ADXcarry[24]),
                      .C2OUT(EDP_ADXcarry[30]));

  // ADB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADBmux

      always_comb begin
        // The irregular part of ADB mux: E22 and E21.
        // When N==0, D4..D7 inputs are selected else D0..D3.
        //
        // In the real KL10 EDP the ADB[-2],ADB[-1] are handled by
        // this logic. But when N > 0, they wire-OR with other
        // signals. I am resolving this by forcing this logic only for
        // N=0.
        if (n === 0) begin
          unique case(CRAM.ADB)
          default: ADB[n-2:n-1] = 'x;
          adbFM:   ADB[n-2:n-1] = {2{FM[n+0]}};
          adbBRx2: ADB[n-2:n-1] = {2{n === 0 ? EDP_BR[n+0] : EDP_BR[n+1]}};
          adbBR:   ADB[n-2:n-1] = {2{EDP_BR[n+0]}};
          adbARx4: ADB[n-2:n-1] = {n === 0 ? EDP_AR[n+0] : EDP_AR[n+2],
                                   n === 0 ? EDP_AR[n+1] : EDP_AR[n+2]};
          endcase
        end

        // The regular part of ADB mux: E23, E26, and E19.
        unique case(CRAM.ADB)
        default: ADB[n:n+5] = 'x;
        adbFM:   ADB[n:n+5] = FM[n+0:n+5];
        adbBRx2: ADB[n:n+5] = {EDP_BR[n+1:n+5], n < 30 ? EDP_BR[n+6] : EDP_BRX[0]};
        adbBR:   ADB[n:n+5] = EDP_BR[n+0:n+5];
        adbARx4: ADB[n:n+5] = {EDP_AR[n+2:n+5], n < 30 ? EDP_AR[n+6:n+7] : EDP_ARX[0:1]};
        endcase
      end
    end
  endgenerate

  // ADXB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXBmux
      always_comb
        unique case(CRAM.ADB)
        default: ADXB[n+0:n+5] = 'x;
        adbFM:   ADXB[n+0:n+5] = n < 6 ? CRAM.MAGIC[n+0:n+5] : 6'b0;
        adbBRx2: ADXB[n+0:n+5] = n < 30 ? EDP_BRX[n+1:n+6] : {EDP_BRX[n+1:n+5], 1'b0};
        adbBR:   ADXB[n+0:n+5] = EDP_BRX[n+0:n+5];
        adbARx4: ADXB[n+0:n+5] = n < 30 ? EDP_ARX[n+2:n+7] : {EDP_ARX[n+2:n+5], 2'b00};
        endcase
    end
  endgenerate

  // ADXA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXAmux
      always_comb ADXA[n+0:n+5] = ADA_EN ? 6'b0 : EDP_ARX[n+0:n+5];
    end
  endgenerate


  // ADA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADAmux
      always_comb
        if (~ADA_EN)
          unique case(CRAM.ADA)
          default: ADA[n+0:n+5] = 'x;
          adaAR:  ADA[n+0:n+5] = EDP_AR[n+0:n+5];
          adaARX: ADA[n+0:n+5] = EDP_ARX[n+0:n+5];
          adaMQ:  ADA[n+0:n+5] = EDP_MQ[n+0:n+5];
          adaPC:  ADA[n+0:n+5] = VMA_VMAheldOrPC[n+0:n+5];
          endcase
        else
          ADA[n+0:n+5] = '0;
    end
  endgenerate


  // FM. No static at all!
  logic [0:6] fmAddress = {APR_FMblk, APR_FMadr};

`ifdef KL10PV_TB
  // Simulated fake memory can have "bytes" of 18 bits for simple
  // LH/RH byte write enable.
  sim_mem
    #(.SIZE(128), .WIDTH(36), .NBYTES(2))
  fm
  (.clk(fastMemClk),
   .din(EDP_AR),
   .dout(FM),
   .addr(fmAddress),
   .wea({CON_FM_WRITE00_17, CON_FM_WRITE18_35}));
`else
  // NOTE: fm_mem is byte writable with 9-bit bytes so we can do
  // halfword writes by writing two "bytes" at a time.
  fm_mem fm(.addra(fmAddress),
            .clka(fastMemClk),
            .dina(EDP_AR),
            .douta(FM),
            .wea({CON_FM_WRITE00_17, CON_FM_WRITE00_17,
                  CON_FM_WRITE18_35, CON_FM_WRITE18_35})
            );
`endif

  assign fmParity = ^FM;


  // BRX
  always_ff @(posedge eboxClk)

    if (eboxReset)
      EDP_BRX <= 0;
    else if (CRAM.BRX === brxARX)
      EDP_BRX <= EDP_ARX;


  // BR
  always_ff @(posedge eboxClk)

    if (eboxReset)
      EDP_BR <= 0;
    else if (CRAM.BR === brAR)
      EDP_BR <= EDP_AR;


  // DIAG or AD driving EBUS
  // If either CTL_adToEBUS_{L,R} is lit we force AD as the source
  logic [0:35] ebusR;
  assign EBUSdriver.driving = CTL_DIAG_READ_FUNC_12x || CTL_adToEBUS_L || CTL_adToEBUS_R;
  assign EBUSdriver.data[0:17] = (CTL_DIAG_READ_FUNC_12x || CTL_adToEBUS_L) ? ebusR[0:17] : '0;
  assign EBUSdriver.data[18:35] = (CTL_DIAG_READ_FUNC_12x || CTL_adToEBUS_R) ? ebusR[18:35] : '0;

  always_ff @(posedge eboxClk) begin

    if (eboxReset) begin
      EBUSdriver.driving <= '0;
    end else if (EBUSdriver.driving) begin

      unique case ((CTL_adToEBUS_L | CTL_adToEBUS_R) ?  3'b111 : DIAG_FUNC[4:6])
      default: ebusR <= 'x;
      3'b000: ebusR <= EDP_AR;
      3'b001: ebusR <= EDP_BR;
      3'b010: ebusR <= EDP_MQ;
      3'b011: ebusR <= FM;
      3'b100: ebusR <= EDP_BRX;
      3'b101: ebusR <= EDP_ARX;
      3'b110: ebusR <= EDP_ADX[0:35];
      3'b111: ebusR <= EDP_AD[0:35];
      endcase
    end else
      ebusR <= 'z;
  end
endmodule
