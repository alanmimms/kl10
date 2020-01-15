`timescale 1ns / 1ps
module edp(input clk,

           input ADXcarry36, // CTL1
           input ADlong,     // CTL

           input [0:2] ARLsel,
           input [0:2] ARRsel,
           input AR00to08load,
           input AR09to17load,
           input ARRload,

           input BRload,
           input BRXload,

           input [2:0] ARXLsel,
           input [2:0] ARXRsel,
           input ARXload,

           input [0:1] MQsel,
           input [0:1] MQMsel,
           input MQMen,

           input AR00to11clr,
           input AR12to17clr,
           input ARRclr,

           input [0:35] ARMM,
           input [0:35] cacheData,
           input [0:35] ebusIn,
           input [0:35] SH,

           input adToEBUS_L,
           input adToEBUS_R,

           input ADbool,
           input [0:3] ADsel,
           input [0:1] ADAsel,
           input [0:1] ADBsel,
           input [0:35] ADAen,

           input [0:2] fmBlk,
           input [0:3] fmAdr,

           input fmWrite00_17,
           input fmWrite18_35,

           input [0:8] diag,
           input diagReadFunc12X,

           input [0:35] VMAheldOrPC,
           input [0:8] magic,

           output [0:35] AD,
           output [0:36] ADX,
           output reg [0:35] MQ,
           output ADoverflow00,
           output reg [0:35] AR,
           output reg [0:35] ARX,
           output fmWrite,
           output fmParity,

           output ADcarry36,
           output drivingEBUS,
           output [0:35] ebusOut
           );

  // Universal shift register function selector values
  localparam USR_LOAD = 2'b00;
  localparam USR_SHL  = 2'b01;
  localparam USR_SHR  = 2'b10;
  localparam USR_HOLD = 2'b11;
  
  reg [0:36] BR, BRX;
  reg [0:17] ARL;
  reg [0:17] ARXL, ARXR;


  reg [0:35] MQM;

  reg [-2:36] ADcarry;
  reg [0:36] ADXcarry;
  
  reg [-2:35] ADA, ADB;
  reg [0:35] ADXA, ADXB;

  reg [0:35] AD_CG, AD_CP;
  reg [0:35] ADX_CG, ADX_CP;

  wire [0:35] FM;

  wire AD_CG06_11, AD_CG12_35, AD_CP06_11, AD_CP12_35;
  wire AD_CG18_23, AD_CG24_35, AD_CP18_23;
  wire AD_CP24_35, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35;
  wire ADX_CP00_11, ADX_CP12_23, ADX_CP24_35;

  wire inhibitCarry18, spec_genCarry18;

  assign ADcarry36 = ADcarry[36];
  assign ADXcarry36 = ADXcarry[36];

  // AR including ARL, ARR, and ARM p15.

  always @(*) begin
    case (ARLsel)
    3'b000: ARL = ARMM[0:17];
    3'b001: ARL = cacheData[0:17];
    3'b010: ARL = AD[0:17];
    3'b011: ARL = ebusIn[0:17];
    3'b100: ARL = SH[0:17];
    3'b101: ARL = AD[1:18];
    3'b110: ARL = ADX[0:17];
    3'b111: ARL = AD[-2:15];
    endcase
  end
  
  always @(posedge clk) begin

    if (AR00to11clr) begin
      AR[0:11] <= 0;
    end else if (AR00to08load) begin
      AR[0:8] <= ARL[0:8];
    end

    if (AR12to17clr) begin
      AR[12:17] <= 0;
    end else if (AR09to17load) begin
      AR[9:17] <= ARL[9:17];
    end

    if (ARRclr) begin
      AR[18:35] <= 0;
    end else if (ARRload) begin
      case (ARRsel)
      3'b000: AR[18:35] <= ARMM[18:35];
      3'b001: AR[18:35] <= cacheData[18:35];
      3'b010: AR[18:35] <= AD[18:35];
      3'b011: AR[18:35] <= ebusIn[18:35];
      3'b100: AR[18:35] <= SH[18:35];
      3'b101: AR[18:35] <= {AD[19:35], ADX[0]};
      3'b110: AR[18:35] <= ADX[18:35];
      3'b111: AR[18:35] <= AD[16:33];
      endcase
    end
  end

  // ARX p16.
  always @(*) begin

    case (ARXLsel)
    3'b000: ARXL = 0;
    3'b001: ARXL = cacheData[0:17];
    3'b010: ARXL = AD[0:17];
    3'b011: ARXL = MQ[0:17];
    3'b100: ARXL = SH[0:17];
    3'b101: ARXL = ADX[1:18];
    3'b110: ARXL = ADX[0:17];
    3'b111: ARXL = {AD[34:35], ADX[0:15]};
    endcase // case (ARXLsel)

    case (ARXRsel)
    3'b000: ARXR = 0;
    3'b001: ARXR = cacheData[18:35];
    3'b010: ARXR = AD[18:35];
    3'b011: ARXR = MQ[18:35];
    3'b100: ARXR = SH[18:35];
    3'b101: ARXR = {ADX[19:35], MQ[0]};
    3'b110: ARXR = ADX[18:35];
    3'b111: ARXR = ADX[16:33];
    endcase // case (ARXLsel)
  end

  always @(posedge clk) begin
    if (ARXload) ARX <= {ARXL, ARXR};
  end

  // MQ/MQM p16.
  always@(*) begin

    if (MQMen) begin

      case (MQMsel)
      USR_LOAD: MQM = {ADX[34:35], MQ[0:33]};
      USR_SHL:  MQM = SH;
      USR_SHR:  MQM = AD;
      USR_HOLD: MQM = 36'hFFFFFFFFF;
      endcase           // MQMsel
    end else
      MQM = 0;
  end // always@ (*)

  always@(posedge clk) begin
    // MQ: 36-bit MC10141-ish universal shift register
    case (MQsel)
    USR_LOAD: MQ <= MQM;
    USR_SHL:  MQ <= {MQM[1:35], ADcarry[-2]};
    USR_SHR:  MQ <= {MQM[1], MQM[1:35]};
    USR_HOLD: MQ <= MQ;
    endcase // case (MQsel)
  end // always@ (posedge clk)

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

  assign ADoverflow00 = (AD[-2] ^ AD[-1]) | (AD[0] | AD[-1]);

  // Instantiate ALU for AD and ADX
  genvar n;
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADaluE1
      mc10181(.S(ADsel), .M(ADbool),
              .A({ADA[n+0], ADA[n+0], ADA[n+0], ADA[n+1]}),
              .B(ADB[n-2:1]),
              .CIN(ADcarry[n+2]),
              .F(AD[n-2:n+1]),
              .CG(AD_CG[n+0]),
              .CP(AD_CP[n+0]),
              .COUT(ADcarry[n-2]));
    end // block: ADalu
  endgenerate
  
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADaluE2
      mc10181(.S(ADsel), .M(ADbool),
              .A(ADA[n+2:n+5]),
              .B(ADB[n+2:n+5]),
              .CIN(n < 30 ? ADcarry[n+6] : ADcarry36),
              .F(AD[n+2:n+5]),
              .CG(AD_CG[n+2]),
              .CP(AD_CP[n+2]),
              .COUT(ADcarry[n+2]));
    end // block: ADalu
  endgenerate
  
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXaluE3
      mc10181(.S(ADsel), .M(ADbool),
              .A({ADXA[n+0], ADXA[n+0], ADXA[n+1:n+2]}),
              .B({ADXB[n+0], ADXB[n+0], ADXB[n+1:n+2]}),
              .CIN(ADXcarry[n+3]),
              .F(ADX[n:n+2]),
              .CG(ADX_CG[n+0]),
              .CP(ADX_CP[n+0]));
    end
  endgenerate

  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXaluE4
      mc10181(.S(ADsel), .M(ADbool),
              .A({ADXA[n+3], ADXA[n+3], ADXA[n+4:n+5]}),
              .B({ADXB[n+3], ADXB[n+3], ADXB[n+4:n+5]}),
              .CIN(n < 30 ? ADXcarry[n+6] : ADXcarry36),
              .F(ADX[n+3:n+5]),
              .CG(ADX_CG[n+3]),
              .CP(ADX_CP[n+3]));
    end
  endgenerate

  // AD carry look ahead
  // Moved here from IR4
  // IR4 E11
  mc10179 AD_LCG_E11(.G({AD_CG[0], AD_CG[2], AD_CG06_11, AD_CG12_35}),
                     .P({AD_CP[0], AD_CP[2], AD_CP06_11, AD_CP12_35}),
                     .CIN(ADcarry36),
                     .C8OUT(ADcarry[-2]),
                     .C2OUT(ADcarry[6]));

  // IR4 E7
  mc10179 AD_LCG_E7(.G({AD_CG[6], AD_CG[6], AD_CG[8], AD_CG[8]}),
                    .P({AD_CP[6],        0,        0, AD_CP[8]}),
                    .CIN(0),
                    .GOUT(AD_CG06_11),
                    .POUT(AD_CP06_11));

  // IR4 E2
  mc10179 AD_LCG_E2(.G({AD_CG[12], AD_CG[14], AD_CG18_23, AD_CG24_35}),
                    .P({AD_CP[12], AD_CP[14], AD_CP18_23, AD_CP24_35}),
                    .CIN(ADcarry36),
                    .GOUT(AD_CG12_35),
                    .POUT(AD_CP12_35),
                    .C8OUT(ADcarry[12]),
                    .C2OUT(ADcarry[18]));

  // IR4 E6
  mc10179 AD_LCG_E6(.G({~inhibitCarry18, ~inhibitCarry18, AD_CG[18], AD_CG[20]}),
                    .P({spec_genCarry18, 0, AD_CP[18], AD_CP[20]}),
                    .CIN(0),
                    .GOUT(AD_CG18_23),
                    .POUT(AD_CP18_23));

  // IR4 E1
  mc10179 AD_LCG_E1(.G({AD_CG[24], AD_CG[26], AD_CG[30], AD_CG[32]}),
                    .P({AD_CP[24], AD_CP[26], AD_CP[30], AD_CP[32]}),
                    .CIN(ADcarry36),
                    .GOUT(AD_CG24_35),
                    .POUT(AD_CP24_35),
                    .C8OUT(ADcarry[24]),
                    .C2OUT(ADcarry[30]));

  // ADX carry look ahead
  // Moved here from IR4
  // IR4 E22
  mc10179 ADX_LCG_E22(.G({ADXcarry36 | ADlong, ADX_CG00_11, ADX_CG12_23, ADX_CG24_35}),
                      .P({~ADlong, ADX_CP00_11, ADX_CP12_23, ADX_CP24_35}),
                      .CIN(ADXcarry36),
                      .C8OUT(ADcarry36));
  // IR4 E21
  mc10179 ADX_LCG_E21(.G({ADX_CG[0], ADX_CG[3], ADX_CG[6], ADX_CG[9]}),
                      .P({ADX_CP[0], ADX_CP[3], ADX_CP[6], ADX_CP[9]}),
                      .CIN(ADXcarry[12]),
                      .GOUT(ADX_CG00_11),
                      .POUTT(ADX_CP00_11));
  // IR4 E26
  mc10179 ADX_LCG_E26(.G({ADX_CG[12], ADX_CG[15], ADX_CG[18], ADX_CG[21]}),
                      .P({ADX_CP[12], ADX_CP[15], ADX_CP[18], ADX_CP[21]}),
                      .CIN(ADXcarry[24]),
                      .C8OUT(ADXcarry[12]),
                      .C2OUT(ADXcarry[18]));
  // IR4 E16
  mc10179 ADX_LCG_E16(.G({ADX_CG[24], ADX_CG[27], ADX_CG[30], ADX_CG[33]}),
                      .P({ADX_CP[24], ADX_CP[27], ADX_CP[30], ADX_CP[33]}),
                      .CIN(ADXcarry36),
                      .GOUT(ADX_CG24_35),
                      .POUT(ADX_CP24_35),
                      .C8OUT(ADXcarry[24]),
                      .C2OUT(ADXcarry[30]));

  // ADB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADBmux
      always @(*)
        case(ADBsel)
        3'b000: ADB[n-2:n+5] = {{2{FM[n+0]}}, FM[n+0:n+5]};
        3'b001: ADB[n-2:n+5] = {{2{n == 0 ? BR[n+0] : BR[n+1]}},
                                BR[n+1:n+4], n < 30 ? BR[n+6] : BRX[0]};
        3'b010: ADB[n-2:n+5] = {{2{BR[n+0]}}, BR[n+0:n+5]};
        3'b011: ADB[n-2:n+5] = {n == 0 ? AR[n+0] : AR[n+2],
                                n == 0 ? AR[n+1] : AR[n+2],
                                AR[n+2:n+5],
                                n < 1 ? AR[n+6] : ARX[0],
                                n < 1 ? AR[n+7] : ARX[1]};
        endcase // case (ADBsel)
    end // block: ADBmux
  endgenerate

  // ADXB mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXBmux
      always @(*)
        case(ADBsel)
        3'b000: ADXB[n+0:n+5] = magic[n+0:n+5];
        3'b001: ADXB[n+0:n+5] = n < 30 ? BRX[n+1:n+6] : {BRX[n+1:n+6], 1'b0};
        3'b010: ADXB[n+0:n+5] = BRX[n+0:n+5];
        3'b011: ADXB[n+0:n+5] = n < 30 ? ARX[n+2:n+7] : {ARX[n+2:n+5], 2'b00};
        endcase // case (ADBsel)
    end // block: ADXBmux
  endgenerate

  // ADXA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADXAmux
      always @(*)
        ADXA[n+0:n+5] = ADAen ? ARX[n+0:n+5] : 6'b0;
    end // block: ADXAmux
  endgenerate


  // ADA mux
  generate
    for (n = 0; n < 36; n = n + 6) begin : ADAmux
      always @(*)
        if (ADAen)
          case(ADAsel)
          2'b00: ADA[n+0:n+5] = AR[n+0:n+5];
          2'b01: ADA[n+0:n+5] = ARX[n+0:n+5];
          2'b10: ADA[n+0:n+5] = MQ[n+0:n+5];
          2'b11: ADA[n+0:n+5] = VMAheldOrPC[n+0:n+5];
          endcase // case (ADAsel)
        else
          ADA[n+0:n+5] = 0;
    end
  endgenerate


  // FM. No static at all!
  wire [0:6] fmAddress = {fmBlk, fmAdr};

  fm_mem fm_mem0(.addra(fmAddress),
                 .clka(clk),
                 .dina(AR),
                 .douta(FM),
                 .wea({fmWrite00_17, fmWrite00_17, fmWrite18_35, fmWrite18_35})
                 );

  reg fmWriteR;
  always @(*) begin
    fmWriteR = ~clk & (fmWrite00_17 | fmWrite18_35);
  end

  assign fmWrite = fmWriteR;
  assign fmParity = ^FM;


  // BRX
  always @(posedge clk)
    if (BRXload) BRX = ARX;


  // BR
  always @(posedge clk)
    if (BRload) BR = AR;


  // EBUS DIAG mux
  reg [0:35] ebusR;
  reg [0:17] ebusLH, ebusRH;

  assign drivingEBUS = diagReadFunc12X;
  assign EBUS = {ebusLH, ebusRH};

  always @(*) begin

    case (diag[4:6])
    3'b000: ebusR = AR;
    3'b001: ebusR = BR;
    3'b010: ebusR = MQ;
    3'b011: ebusR = FM;
    3'b100: ebusR = BRX;
    3'b101: ebusR = ARX;
    3'b110: ebusR = ADX;
    3'b111: ebusR = AD;
    endcase // case (diag[4:6])

    if (diagReadFunc12X || adToEBUS_L) ebusLH = ebusR[0:17];
    if (diagReadFunc12X || adToEBUS_R) ebusRH = ebusR[18:35];
  end // always @ (*)
  
endmodule // edp
