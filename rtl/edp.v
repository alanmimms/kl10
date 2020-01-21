// XXX TODO: Refactor this into six instances of the same module wired
// together in ebox.v.
`timescale 1ns / 1ps
module edp(input eboxClk,
           input fastMemClk,

           input CTL_ADcarry36,
           input CTL_ADXcarry36,
           input CTL_ADlong,

           input [0:5] CRAM_AD,
           input [0:3] CRAM_ADA,
           input [0:1] CRAM_ADA_EN,
           input [0:1] CRAM_ADB,

           input [0:3] CRAM_AR,
           input [0:3] CRAM_ARX,
           input [0:8] CRAM_MAGIC,

           input CRAM_BRload,
           input CRAM_BRXload,

           input [0:2] CTL_ARL_SEL,
           input [0:2] CTL_ARR_SEL,
           input CTL_AR00to08load,
           input CTL_AR09to17load,
           input CTL_ARRload,

           input CTL_AR00to11clr,
           input CTL_AR12to17clr,
           input CTL_ARRclr,

           input [0:2] CTL_ARXL_SEL,
           input [0:2] CTL_ARXR_SEL,
           input CTL_ARX_LOAD,

           input [0:1] CTL_MQ_SEL,
           input [0:1] CTL_MQM_SEL,
           input CTL_MQM_EN,
           input CTL_inhibitCarry18,
           input CTL_SPEC_genCarry18,

           input [0:35] cacheDataRead,
           output reg [0:35] cacheDataWrite,
           input [0:35] EBUS,
           input [0:35] SHM_SH,
           input [0:8] SCD_ARMMupper,
           input [13:17] SCD_ARMMlower,

           input CTL_adToEBUS_L,
           input CTL_adToEBUS_R,

           input [0:2] APR_FMblk,
           input [0:3] APR_FMadr,

           input CON_fmWrite00_17,
           input CON_fmWrite18_35,

           input [0:8] CRAM_DIAG_FUNC,
           input diagReadFunc12X,

           input [0:35] VMA_VMAheldOrPC,

           output wire [-2:35] EDP_AD,
           output wire [0:35] EDP_ADX,
           output reg [0:35] EDP_BR,
           output reg [0:35] EDP_BRX,
           output reg [0:35] EDP_MQ,
           output reg [0:35] EDP_AR,
           output reg [0:35] EDP_ARX,
           output wire [0:35] FM,
           output fmParity,


           output wire [-2:35] EDP_AD_EX,
           output wire [-2:36] EDP_ADcarry,
           output wire [0:36] EDP_ADXcarry,
           output wire [0:35] EDP_ADoverflow,
           output wire EDP_genCarry36,

           output reg EDPdrivingEBUS,
           output reg [0:35] EDP_EBUS
           );

  // Universal shift register function selector values
  localparam USR_LOAD = 2'b00;
  localparam USR_SHL  = 2'b01;
  localparam USR_SHR  = 2'b10;
  localparam USR_HOLD = 2'b11;
  
  /*AUTOWIRE*/
  /*AUTOREG*/

  reg [0:17] ARL;
  reg [0:17] ARXL, ARXR;
  
  reg [0:35] MQM;

  reg [0:35] ADA;
  reg [-2:35] ADB;
  reg [0:35] ADXA, ADXB;

  wire [0:35] AD_CG, AD_CP;
  wire [0:35] ADX_CG, ADX_CP;

  wire AD_CG06_11, AD_CG12_35, AD_CP06_11, AD_CP12_35;
  wire AD_CG18_23, AD_CG24_35, AD_CP18_23;
  wire AD_CP24_35, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35;
  wire ADX_CP00_11, ADX_CP12_23, ADX_CP24_35;

  wire ADbool = CRAM_AD[1];
  wire [0:3] ADsel = CRAM_AD[2:5];
  wire [0:1] ADAsel = CRAM_ADA[1:2];
  wire ADAen = ~CRAM_ADA_EN[0];
  wire [0:1] ADBsel = CRAM_ADB;

  wire [0:2] ARRsel = CRAM_AR;

  wire [2:0] ARXLsel = CTL_ARXL_SEL;
  wire [2:0] ARXRsel = CTL_ARXR_SEL;
  wire ARXload = CTL_ARX_LOAD;
  
  wire [0:1] MQsel = CTL_MQ_SEL;
  wire [0:1] MQMsel = CTL_MQM_SEL;
  wire MQMen = CTL_MQM_EN;

  wire ADcarry36 = EDP_ADcarry[36];
  wire ADXcarry36 = EDP_ADXcarry[36];

  // XXX is this completely right?
  assign EDP_ADcarry[36] = CTL_ADcarry36;

  // Set registers we own to initial reset state
  initial begin
    ARL = 0;
    ARXL = 0;
    ARXR = 0;
    MQM = 36'd0;
    ADA = 36'd0;
    ADB = 38'd0;
    ADXA = 36'd0;
    ADXB = 36'd0;

    cacheDataWrite = 0;
    EDP_BR = 36'd0;
    EDP_BRX = 36'd0;
    EDP_MQ = 36'd0;
    EDP_AR = 36'd0;
    EDP_ARX = 36'd0;
    EDPdrivingEBUS = 0;
    EDP_EBUS = 36'd0;
  end
  
  // AR including ARL, ARR, and ARM p15.

  always @(*) begin
    case (CTL_ARL_SEL)
    3'b000: ARL = {SCD_ARMMupper, 5'b0, SCD_ARMMlower};
    3'b001: ARL = cacheDataRead[0:17];
    3'b010: ARL = EDP_AD[0:17];
    3'b011: ARL = EBUS[0:17];
    3'b100: ARL = SHM_SH[0:17];
    3'b101: ARL = EDP_AD[1:18];
    3'b110: ARL = EDP_ADX[0:17];
    3'b111: ARL = {EDP_AD_EX[-2:-1], EDP_AD[0:14]};
    endcase
  end
  
  always @(posedge eboxClk) begin

    if (CTL_AR00to11clr) begin
      EDP_AR[0:11] <= 0;
    end else if (CTL_AR00to08load) begin
      EDP_AR[0:8] <= ARL[0:8];
    end

    if (CTL_AR12to17clr) begin
      EDP_AR[12:17] <= 0;
    end else if (CTL_AR09to17load) begin
      EDP_AR[9:17] <= ARL[9:17];
    end

    if (CTL_ARRclr) begin
      EDP_AR[18:35] <= 0;
    end else if (CTL_ARRload) begin
      case (ARRsel)
      3'b000: EDP_AR[18:35] <= {SCD_ARMMupper, 5'b0, SCD_ARMMlower}; // XXX?
      3'b001: EDP_AR[18:35] <= cacheDataRead[18:35];
      3'b010: EDP_AR[18:35] <= EDP_AD[18:35];
      3'b011: EDP_AR[18:35] <= EBUS[18:35];
      3'b100: EDP_AR[18:35] <= SHM_SH[18:35];
      3'b101: EDP_AR[18:35] <= {EDP_AD[19:35], EDP_ADX[0]};
      3'b110: EDP_AR[18:35] <= EDP_ADX[18:35];
      3'b111: EDP_AR[18:35] <= EDP_AD[16:33];
      endcase
    end
  end

  // ARX p16.
  always @(*) begin

    case (ARXLsel)
    3'b000: ARXL = 0;
    3'b001: ARXL = cacheDataRead[0:17];
    3'b010: ARXL = EDP_AD[0:17];
    3'b011: ARXL = EDP_MQ[0:17];
    3'b100: ARXL = SHM_SH[0:17];
    3'b101: ARXL = EDP_ADX[1:18];
    3'b110: ARXL = EDP_ADX[0:17];
    3'b111: ARXL = {EDP_AD[34:35], EDP_ADX[0:15]};
    endcase // case (ARXLsel)

    case (ARXRsel)
    3'b000: ARXR = 0;
    3'b001: ARXR = cacheDataRead[18:35];
    3'b010: ARXR = EDP_AD[18:35];
    3'b011: ARXR = EDP_MQ[18:35];
    3'b100: ARXR = SHM_SH[18:35];
    3'b101: ARXR = {EDP_ADX[19:35], EDP_MQ[0]};
    3'b110: ARXR = EDP_ADX[18:35];
    3'b111: ARXR = EDP_ADX[16:33];
    endcase // case (ARXLsel)
  end

  always @(posedge eboxClk) begin
    if (ARXload) EDP_ARX <= {ARXL, ARXR};
  end

  // MQ/MQM p16.
  always@(*) begin

    if (MQMen) begin

      case (MQMsel)
      USR_LOAD: MQM = {EDP_ADX[34:35], EDP_MQ[0:33]};
      USR_SHL:  MQM = SHM_SH;
      USR_SHR:  MQM = EDP_AD[0:35];
      USR_HOLD: MQM = 36'hFFF_FFF_FFF;
      endcase           // MQMsel
    end else
      MQM = 36'd0;
  end // always@ (*)

  always@(posedge eboxClk) begin
    // MQ: 36-bit MC10141-ish universal shift register
    case (MQsel)
    USR_LOAD: EDP_MQ <= MQM;
    USR_SHL:  EDP_MQ <= {MQM[1:35], EDP_ADcarry[-2]};
    USR_SHR:  EDP_MQ <= {MQM[1], MQM[1:35]};
    USR_HOLD: EDP_MQ <= EDP_MQ;
    endcase
  end

  // AD, p17.
  /*
   A+1=40
   A+XCRY=00
   A+ANDCB=01
   A+AND=02
   A*2=03
   A*2+1=43
   OR+1=44
   OR+ANDCB=05
   A+B=06
   A+B+1=46
   A+OR=07
   ORCB+1=50
   A-B-1=11
   A-B=51
   AND+ORCB=52
   A+ORCB=53
   XCRY-1=54
   ANDCB-1=15
   AND-1=16
   A-1=17
   ;ADDER LOGICAL FUNCTIONS
   SETCA=20
   ORC=21		;NAND
   ORCA=22
   1S=23
   ANDC=24		;NOR
   NOR=24
   SETCB=25
   EQV=26
   ORCB=27
   ANDCA=30
   XOR=31
   B=32
   OR=33
   0S=34
   ANDCB=35
   AND=36
   A=37
   ;BOOLEAN FUNCTIONS FOR WHICH CRY0 IS INTERESTING
   CRY A EQ -1=60	;GENERATE CRY0 IF A=1S, AD=SETCA
   CRY A.B#0=36	;CRY 0 IF A&B NON-ZERO, AD=AND
   CRY A#0=37		;GENERATE CRY0 IF A .NE. 0, AD=A
   CRY A GE B=71	;CRY0 IF A .GE. B, UNSIGNED; AD=XOR
   */

  // Look-ahead carry network moved here from IR4 M8522 board.
  wire [0:35] ADEXxortmp;

  // Instantiate ALU for AD and ADX
  genvar n;
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADaluE1E2

      // Misc carry logic, top p.17
      assign ADEXxortmp[n] = EDP_AD[n+0] ^ EDP_AD_EX[n-1];
      assign EDP_ADcarry[n+1] = EDP_ADcarry[n-2] ^ ADEXxortmp[n];
      assign EDP_ADoverflow[n] = EDP_AD_EX[n-2]  ^ ADEXxortmp[n];

      mc10181 alu0(.S(ADsel), .M(ADbool),
                   .A({{3{ADA[n+0]}}, ADA[n+1]}),
                   .B(ADB[n-2:n+1]),
                   .CIN(EDP_ADcarry[n+2]),
                   // Note EDP_AD_EX is dumping ground when n>0
                   .F({EDP_AD_EX[n-2:n-1], EDP_AD[n:n+1]}),
                   .CG(AD_CG[n+0]),
                   .CP(AD_CP[n+0]),
                   .COUT(EDP_ADcarry[n-2]));
      mc10181 alu1(.S(ADsel), .M(ADbool),
                   .A(ADA[n+2:n+5]),
                   .B(ADB[n+2:n+5]),
                   .CIN(EDP_ADcarry[n+6]),
                   .F(EDP_AD[n+2:n+5]),
                   .CG(AD_CG[n+2]),
                   .CP(AD_CP[n+2]),
                   .COUT(EDP_ADcarry[n+2]));
    end
  endgenerate
  
  wire [0:35] alu2_x1 = 36'd0, alu3_x1 = 36'd0;
  
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXaluE3E4
        mc10181 alu2(.S(ADsel), .M(ADbool),
                     .A({ADXA[n+0], ADXA[n+0], ADXA[n+1:n+2]}),
                     .B({ADXB[n+0], ADXB[n+0], ADXB[n+1:n+2]}),
                     .CIN(EDP_ADXcarry[n+3]),
                     .F({alu2_x1[n], EDP_ADX[n:n+2]}),
                     .CG(ADX_CG[n+0]),
                     .CP(ADX_CP[n+0]));
        mc10181 alu3(.S(ADsel), .M(ADbool),
                     .A({ADXA[n+3], ADXA[n+3], ADXA[n+4:n+5]}),
                     .B({ADXB[n+3], ADXB[n+3], ADXB[n+4:n+5]}),
                     .CIN(n < 30 ? EDP_ADXcarry[n+6] : CTL_ADXcarry36),
                     .F({alu3_x1[n], EDP_ADX[n+3:n+5]}),
                     .CG(ADX_CG[n+3]),
                     .CP(ADX_CP[n+3]),
                     .COUT(EDP_ADXcarry[n+3]));
    end
  endgenerate

  // AD carry look ahead
  // Moved here from IR4
  assign EDP_genCarry36 = CTL_ADXcarry36 | CTL_ADlong;
  
  // IR4 E11
  mc10179 AD_LCG_E11(.G({AD_CG[0], AD_CG[2], AD_CG06_11, AD_CG12_35}),
                     .P({AD_CP[0], AD_CP[2], AD_CP06_11, AD_CP12_35}),
                     .CIN(ADcarry36),
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
                    .CIN(ADcarry36),
                    .GG(AD_CG12_35),
                    .PG(AD_CP12_35),
                    .C8OUT(EDP_ADcarry[12]),
                    .C2OUT(EDP_ADcarry[18]));

  // IR4 E6
  mc10179 AD_LCG_E6(.G({~CTL_inhibitCarry18, ~CTL_inhibitCarry18, AD_CG[18], AD_CG[20]}),
                    .P({CTL_SPEC_genCarry18, 1'b0, AD_CP[18], AD_CP[20]}),
                    .CIN(1'b0),
                    .GG(AD_CG18_23),
                    .PG(AD_CP18_23));

  // IR4 E1
  mc10179 AD_LCG_E1(.G({AD_CG[24], AD_CG[26], AD_CG[30], AD_CG[32]}),
                    .P({AD_CP[24], AD_CP[26], AD_CP[30], AD_CP[32]}),
                    .CIN(ADcarry36),
                    .GG(AD_CG24_35),
                    .PG(AD_CP24_35),
                    .C8OUT(EDP_ADcarry[24]),
                    .C2OUT(EDP_ADcarry[30]));

  // ADX carry look ahead
  // Moved here from IR4
  // IR4 E22
  mc10179 ADX_LCG_E22(.G({EDP_genCarry36, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35}),
                      .P({~CTL_ADlong, ADX_CP00_11, ADX_CP12_23, ADX_CP24_35}),
                      .CIN(CTL_ADXcarry36),
                      .C8OUT(ADcarry36));
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
                      .CIN(CTL_ADXcarry36),
                      .GG(ADX_CG24_35),
                      .PG(ADX_CP24_35),
                      .C8OUT(EDP_ADXcarry[24]),
                      .C2OUT(EDP_ADXcarry[30]));

  // ADB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADBmux

      always @(*) begin
        // The irregular part of ADB mux: E22 and E21.
        // When N==0, D4..D7 inputs are selected else D0..D3.
        //
        // In the real KL10 EDP the ADB[-2],ADB[-1] are handled by
        // this logic. But when N > 0, they wire-OR with other
        // signals. I am resolving this by forcing this logic only for
        // N=0.
        if (n === 0) begin
          case(ADBsel)
          2'b00: ADB[n-2:n-1] = {2{FM[n+0]}};
          2'b01: ADB[n-2:n-1] = {2{n === 0 ? EDP_BR[n+0] : EDP_BR[n+1]}};
          2'b10: ADB[n-2:n-1] = {2{EDP_BR[n+0]}};
          2'b11: ADB[n-2:n-1] = {n === 0 ? EDP_AR[n+0] : EDP_AR[n+2],
                                 n === 0 ? EDP_AR[n+1] : EDP_AR[n+2]};
          endcase
        end

        // The regular part of ADB mux: E23, E26, and E19.
        case(ADBsel)
        2'b00: ADB[n:n+5] = FM[n+0:n+5];
        2'b01: ADB[n:n+5] = {EDP_BR[n+1:n+5], n < 30 ? EDP_BR[n+6] : EDP_BRX[0]};
        2'b10: ADB[n:n+5] = EDP_BR[n+0:n+5];
        2'b11: ADB[n:n+5] = {EDP_AR[n+2:n+5], n < 30 ? EDP_AR[n+6:n+7] : EDP_ARX[0:1]};
        endcase
      end
    end
  endgenerate

  // ADXB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXBmux
      always @(*)
        case(ADBsel)
        2'b00: ADXB[n+0:n+5] = n < 6 ? CRAM_MAGIC[n+0:n+5] : 6'b0;
        2'b01: ADXB[n+0:n+5] = n < 30 ? EDP_BRX[n+1:n+6] : {EDP_BRX[n+1:n+5], 1'b0};
        2'b10: ADXB[n+0:n+5] = EDP_BRX[n+0:n+5];
        2'b11: ADXB[n+0:n+5] = n < 30 ? EDP_ARX[n+2:n+7] : {EDP_ARX[n+2:n+5], 2'b00};
        endcase
    end
  endgenerate

  // ADXA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXAmux
      always @(*)
        ADXA[n+0:n+5] = ADAen ? EDP_ARX[n+0:n+5] : 6'b0;
    end
  endgenerate


  // ADA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADAmux
      always @(*)
        if (ADAen)
          case(ADAsel)
          2'b00: ADA[n+0:n+5] = EDP_AR[n+0:n+5];
          2'b01: ADA[n+0:n+5] = EDP_ARX[n+0:n+5];
          2'b10: ADA[n+0:n+5] = EDP_MQ[n+0:n+5];
          2'b11: ADA[n+0:n+5] = VMA_VMAheldOrPC[n+0:n+5];
          endcase
        else
          ADA[n+0:n+5] = 36'd0;
    end
  endgenerate


  // FM. No static at all!
  wire [0:6] fmAddress = {APR_FMblk, APR_FMadr};

  // NOTE: fm_mem is byte writable with 9-bit bytes so we can do
  // halfword writes by writing two "bytes" at a time.
  fm_mem fm_mem0(.addra(fmAddress),
                 .clka(fastMemClk),
                 .dina(EDP_AR),
                 .douta(FM),
                 .wea({CON_fmWrite00_17, CON_fmWrite00_17,
                       CON_fmWrite18_35, CON_fmWrite18_35})
                 );

  assign fmParity = ^FM;


  // BRX
  always @(posedge eboxClk)
    if (CRAM_BRXload) EDP_BRX = EDP_ARX;


  // BR
  always @(posedge eboxClk)
    if (CRAM_BRload) EDP_BR = EDP_AR;


  // EBUS DIAG mux
  reg [0:35] ebusR;
  reg [0:17] ebusLH, ebusRH;

  always @(*) EDPdrivingEBUS = diagReadFunc12X;
  assign EBUS = {ebusLH, ebusRH};

  always @(*) begin

    case (CRAM_DIAG_FUNC[4:6])
    3'b000: ebusR = EDP_AR;
    3'b001: ebusR = EDP_BR;
    3'b010: ebusR = EDP_MQ;
    3'b011: ebusR = FM;
    3'b100: ebusR = EDP_BRX;
    3'b101: ebusR = EDP_ARX;
    3'b110: ebusR = EDP_ADX[0:35];
    3'b111: ebusR = EDP_AD[0:35];
    endcase

    if (diagReadFunc12X || CTL_adToEBUS_L) ebusLH = ebusR[0:17];
    if (diagReadFunc12X || CTL_adToEBUS_R) ebusRH = ebusR[18:35];
  end
endmodule
