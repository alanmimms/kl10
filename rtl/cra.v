`timescale 1ns / 1ps
// M8541 CRA
//
// Addressing for 2K words CRAM
// CRAM address combinatorial logic
// CRAM CALL/RETURN subroutine stack
//
// In a real KL10PV, M8541 contains the last six bits of CRAM storage.
// This has been moved to crm.v in a single unified storage module.
module cra(input clk,
           input force1777,
           input MULdone,
           input [0:3] DRAM_A,
           input [0:3] DRAM_B,
           input [0:9] DRAM_J,
           input [10:0] J,
           input [3:0] MEM,
           input [5:0] SKIP,
           input [5:0] COND,
           input CALL,
           input [4:0] DISP,
           input [4:0] SPEC,
           input MARK,
           input [8:0] magic,
           input [0:35] ebusIn,
           input [4:6] diag,
           input [8:10] norm,
           input [0:10] NICOND,
           input [0:3] SR,
           input [0:35] SH,
           input [0:35] MQ,
           input [0:35] BR,
           input [0:35] AD,
           input [0:35] ADX,
           input [0:35] AR,
           input [0:35] ARX,
           input [0:10] pfDisp,
           input [7:10] eaType,
           input skipEn40_47,
           input skipEn50_57,
           input diagReadFunc14X,
           input diaFunc051,
           input diaFunc052,

           input pcSection0,
           input localACAddress,
           input longEnable,
           input indexed,
           input ADcarry_02,
           input ADeq0,
           input ACeq0,
           input FEsign,
           input SCsign,
           input SCADsign,
           input SCADeq0,
           input FPD,
           input ARparityOdd,

           output reg [11:0] CRADR,
           output reg [1:10] AREAD,
           output reg dispParity,
           output reg drivingEBUS,
           output reg [0:35] ebusOut
           /*AUTOARG*/);

  initial CRADR <= 0;

  reg [0:11] dispMux;
  reg [0:10] diagAdr;
  reg [0:10] adr;
  reg [0:10] loc;

  reg [0:4] stackAdr;
  reg [0:10] sbrRet;

  wire dispEn00_03, dispEn00_07, dispEn30_37;
  wire shortIndirWord;
  wire callForce1777;
  wire retNotForce1777;
  wire ret;

  // Note E43,E3,E23 and parts of E47(Q3),E35(Q3) are in crm.v since
  // they are simple CRAM storage mapping to logical fields.

  // Remaining features of E47,E35 are CRAM DISP field decoding.
  assign dispEn00_03 = DISP[0:4] === 5'b00011;
  assign dispEn00_07 = DISP[0:4] === 5'b00111;
  assign dispEn30_37 = DISP[0:4] === 5'b11111;

  assign shortIndirWord = ~longEnable | ARX[1];
  assign callForce1777 = CALL | force1777;
  assign ret = dispEn00_03 && DISP[3] & DISP[4];
  assign retNotForce1777 = ret & ~force1777;

  always @(*) begin

    if (dispEn00_03) begin
      case (DISP[3:4])
      2'b00: dispMux[0:6] <= diagAdr[0:6];
      2'b01: dispMux[0:6] <= {2'b00, DRAM_J[1:4], 2'b00};
      2'b10: dispMux[0:6] <= {2'b00, AREAD[1:4], 2'b00};
      2'b11: dispMux[0:6] <= sbrRet;
      endcase
    end else if (dispEn00_07) begin
      case (DISP[2:4])
      3'b000: dispMux[7:10] <= diagAdr[7:10];
      3'b001: dispMux[7:10] <= DRAM_J[7:10];
      3'b010: dispMux[7:10] <= AREAD[7:10];
      3'b011: dispMux[7:10] <= sbrRet[7:10];
      3'b100: dispMux[7:10] <= pfDisp[7:10];
      3'b101: dispMux[7:10] <= SR[0:3];
      3'b110: dispMux[7:10] <= NICOND[7:10];
      3'b111: dispMux[7:10] <= SH[0:3];
      endcase
    end else if (dispEn30_37) begin
      case (DISP[2:4])
      3'b000: dispMux[7:10] <= {1'b0, FEsign, MQ[34:35], pcSection0};
      3'b001: dispMux[7:10] <= {1'b0, FEsign, BR[0], ADcarry_02, SCADsign};
      3'b010: dispMux[7:10] <= {ARX[0], AR[0], BR[0], AD[0], SCADeq0};
      3'b011: dispMux[7:10] <= {1'b0, DRAM_B[0:2], ADX[0]};
      3'b100: dispMux[7:10] <= {1'b0, FPD, AR[12], SCADsign, ADcarry_02};
      3'b101: dispMux[7:10] <= {1'b0, norm[8:10], AD[0]};
      3'b110: dispMux[7:10] <= {~longEnable | ARX[0], shortIndirWord,
                                ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[7:10] <= {eaType[7:10], localACAddress};
      endcase
    end else if (skipEn40_47) begin
      case (COND[3:5])
      3'b000: dispMux[10] <= 0;
      3'b001: dispMux[10] <= ARparityOdd;
      3'b010: dispMux[10] <= BR[0];
      3'b011: dispMux[10] <= ARX[0];
      3'b100: dispMux[10] <= AR[18];
      3'b101: dispMux[10] <= AR[0];
      3'b110: dispMux[10] <= ACeq0;
      3'b111: dispMux[10] <= SCsign;
      endcase
    end else if (skipEn50_57) begin
      case (COND[3:5])
      3'b000: dispMux[10] <= pcSection0;
      3'b001: dispMux[10] <= {1'b0, FEsign, BR[0], ADcarry_02, SCADsign};
      3'b010: dispMux[10] <= {ARX[0], AR[0], BR[0], AD[0], SCADeq0};
      3'b011: dispMux[10] <= {1'b0, DRAM_B[0:2], ADX[0]};
      3'b100: dispMux[10] <= {1'b0, FPD, AR[12], SCADsign, ADcarry_02};
      3'b101: dispMux[10] <= {1'b0, norm[8:10], AD[0]};
      3'b110: dispMux[10] <= {~longEnable | ARX[0], shortIndirWord, ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[10] <= {eaType[7:10], localACAddress};
      endcase
    end else
      dispMux <= 0;
    
    CRADR <= J | {11{force1777}} | dispMux;
  end

  ////////////////////////////////////////////////////////////////
  // The incredibly baroque call/return stack implementation
  //
  // STACK ADDRESS SEQUENCE
  // Y  ABCD EFGH  Z  |  WRITE  READ
  // -----------------|------------
  // 0  1111 000X  0  |   16    10         RESET
  // 1  0111 1000  1  |   17    14         RESET
  // 0  1011 1100  0  |   07    16         RESET
  // 1  0101 1110  0  |   13    17         RESET
  //                  |
  // 1  1010 1111  0  |   05    07         RESET
  // 0  1101 0111  1  |   12    13         RESET
  // 0  0110 1011  1  |   15    05         RESET
  // 1  0011 0101  1  |   06    12         RESET
  //                  |
  // 0  1001 1010  1  |   03    15         RESET
  // 0  0100 1101  0  |   11    06         RESET
  // 0  0010 0110  1  |   04    03         RESET
  // 1  0001 0011  0  |   02    11         RESET
  //                  |
  // 1  1000 1001  1  |   01    04         RESET
  // 1  1100 0100  1  |   10    02         RESET
  // 1  1110 0010  0  |   14    01         RESET
  // 0  1111 0001  0  |   16    10         RESET

  // E56,E57
  reg [0:7] stackAdrAD, stackAdrEH;
  wire stackAdrA, stackAdrB, stackAdrC, stackAdrD;
  wire stackAdrE, stackAdrF, stackAdrG, stackAdrH;

  assign stackAdrA = stackAdrAD[0];
  assign stackAdrB = stackAdrAD[1];
  assign stackAdrC = stackAdrAD[2];
  assign stackAdrD = stackAdrAD[3];

  assign stackAdrE = stackAdrEH[0];
  assign stackAdrF = stackAdrEH[1];
  assign stackAdrG = stackAdrEH[2];
  assign stackAdrH = stackAdrEH[3];

  wire stackAdrY = stackAdrA ^ stackAdrD;
  wire stackAdrZ = stackAdrF ^ stackAdrE;

  always @(posedge clk) begin

    if (callForce1777 && retNotForce1777) begin // LOAD
      stackAdrAD <= 4'b1111;
      stackAdrEH <= 4'b0000;
    end else if (callForce1777) begin           // 0in+0
      stackAdrAD <= {stackAdrY, {3{retNotForce1777}}};
      stackAdrEH <= {stackAdrD, 3'b000};
    end else if (retNotForce1777) begin         // 3in+3
      stackAdrAD <= {{3{retNotForce1777}}, stackAdrE};
      stackAdrEH <= {3'b000, stackAdrZ};
    end else begin                              // HOLD
      stackAdrAD <= stackAdrAD;
      stackAdrEH <= stackAdrEH;
    end

    // XXX still need to implement remainder of p.346 CRA4.

  end


  ////////////////////////////////////////////////////////////////
  // Diagnostics stuff

  always @(*) dispParity = ^{CALL, DISP};

  always @(posedge clk) begin

    if (diaFunc051)
      diagAdr[5:10] <= ebusIn[0:5];
    else if (diaFunc052)
      diagAdr[0:4] <= ebusIn[1:5];

    loc <= adr;

    AREAD <= DRAM_A === 3'b000 ? DRAM_J : 0;
  end

  // Diagnostics driving EBUS
  always @(*) begin

    case (diag[4:6])
    3'b000: ebusOut <= {dispEn00_07, dispEn00_03, stackAdr};
    3'b001: ebusOut <= {CALL, DISP[0:4], stackAdr};
    3'b010: ebusOut <= sbrRet[5:10];
    3'b011: ebusOut <= {dispEn30_37, sbrRet[0:4]};
    3'b100: ebusOut <= adr[5:10];
    3'b101: ebusOut <= {dispParity, adr[0:4]};
    3'b110: ebusOut <= loc[5:10];
    3'b111: ebusOut <= {1'b0, loc[0:4]};
    endcase

    drivingEBUS <= diagReadFunc14X;
  end
endmodule
