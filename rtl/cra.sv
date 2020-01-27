`include "cram-defs.svh"

// M8541 CRA
//
// Addressing for 2K words CRAM
// CRAM address combinatorial logic
// CRAM CALL/RETURN subroutine stack
//
// In a real KL10PV, M8541 contains the last six bits of CRAM storage.
// This has been moved to crm.v in a single unified storage module.
module cra(input eboxClk,
           input fastMemClk,
           input force1777,
           input MULdone,

           input [0:3] DRAM_A,
           input [0:3] DRAM_B,
           input [0:9] DRAM_J,
           input tCRAM CRAM,

           input [0:35] EBUS,
           input [8:10] norm,
           input [0:10] NICOND,
           input [0:3] SR,
           input [0:35] SHM_SH,
           input [0:35] EDP_MQ,
           input [0:35] EDP_BR,
           input [0:35] EDP_AD,
           input [0:35] EDP_ADX,
           input [0:35] EDP_AR,
           input [0:35] EDP_ARX,
           input [-2:36] EDP_ADcarry,
           input [0:10] pfDisp,
           input skipEn40_47,
           input skipEn50_57,
           input diagReadFunc14X,
           input diaFunc051,
           input diaFunc052,

           input pcSection0,
           input localACAddress,
           input longEnable,
           input indexed,
           input ADeq0,
           input ACeq0,
           input FEsign,
           input SCsign,
           input SCADsign,
           input SCADeq0,
           input FPD,
           input ARparityOdd,

           output tCRADR CRADR,
           output logic [10:1] AREAD,
           output logic dispParity,
           output logic CRAdrivingEBUS,
           output logic [0:35] CRA_EBUS);

  timeunit 1ns;
  timeprecision 1ps;

  logic [0:11] dispMux;
  logic [0:10] diagAdr;
  logic [0:10] adr;
  logic [0:10] loc;

  logic [0:10] stack[15:0];
  logic [0:10] sbrRet;

  logic dispEn00_03, dispEn00_07, dispEn30_37;
  logic shortIndirWord;
  logic callForce1777;
  logic retNotForce1777;
  logic ret;

  // TEMPORARY? This looks like it belongs to an incompletely
  // implemented feature that might have been called DISP/EA TYPE
  // (37). This dispatch is never used in microcode.
  logic [7:10] eaType = 0;

`include "cram-aliases.svh"

  initial CRADR <= 0;

  // Note E43,E3,E23 and parts of E47(Q3),E35(Q3) are in crm.v since
  // they are simple CRAM storage mapping to logical fields.

  // Remaining features of E47,E35 are CRAM DISP field decoding.
  assign dispEn00_03 = CRAM.f.DISP[0:4] === 5'b00011;
  assign dispEn00_07 = CRAM.f.DISP[0:4] === 5'b00111;
  assign dispEn30_37 = CRAM.f.DISP[0:4] === 5'b11111;

  assign shortIndirWord = ~longEnable | EDP_ARX[1];
  assign callForce1777 = CRAM.f.CALL | force1777;
  assign ret = dispEn00_03 && CRAM.f.DISP[3] & CRAM.f.DISP[4];
  assign retNotForce1777 = ret & ~force1777;

  always @(*) begin

    if (dispEn00_03) begin
      case (CRAM.f.DISP[3:4])
      2'b00: dispMux[0:6] <= diagAdr[0:6];
      2'b01: dispMux[0:6] <= {2'b00, DRAM_J[1:4], 2'b00};
      2'b10: dispMux[0:6] <= {2'b00, AREAD[1:4], 2'b00};
      2'b11: dispMux[0:6] <= sbrRet;
      endcase
    end else if (dispEn00_07) begin
      case (CRAM.f.DISP[2:4])
      3'b000: dispMux[7:10] <= diagAdr[7:10];
      3'b001: dispMux[7:10] <= DRAM_J[7:10];
      3'b010: dispMux[7:10] <= AREAD[7:10];
      3'b011: dispMux[7:10] <= sbrRet[7:10];
      3'b100: dispMux[7:10] <= pfDisp[7:10];
      3'b101: dispMux[7:10] <= SR[0:3];
      3'b110: dispMux[7:10] <= NICOND[7:10];
      3'b111: dispMux[7:10] <= SHM_SH[0:3];
      endcase
    end else if (dispEn30_37) begin
      case (CRAM.f.DISP[2:4])
      3'b000: dispMux[7:10] <= {1'b0, FEsign, EDP_MQ[34:35], pcSection0};
      3'b001: dispMux[7:10] <= {1'b0, FEsign, EDP_BR[0], EDP_ADcarry[-2], SCADsign};
      3'b010: dispMux[7:10] <= {EDP_ARX[0], EDP_AR[0], EDP_BR[0], EDP_AD[0], SCADeq0};
      3'b011: dispMux[7:10] <= {1'b0, DRAM_B[0:2], EDP_ADX[0]};
      3'b100: dispMux[7:10] <= {1'b0, FPD, EDP_AR[12], SCADsign, EDP_ADcarry[-2];
      3'b101: dispMux[7:10] <= {1'b0, norm[8:10], EDP_AD[0]};
      3'b110: dispMux[7:10] <= {~longEnable | EDP_ARX[0], shortIndirWord,
                                EDP_ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[7:10] <= {eaType[7:10], localACAddress};
      endcase
    end else if (skipEn40_47) begin
      case (CRAM.f.COND[3:5])
      3'b000: dispMux[10] <= 0;
      3'b001: dispMux[10] <= ARparityOdd;
      3'b010: dispMux[10] <= EDP_BR[0];
      3'b011: dispMux[10] <= EDP_ARX[0];
      3'b100: dispMux[10] <= EDP_AR[18];
      3'b101: dispMux[10] <= EDP_AR[0];
      3'b110: dispMux[10] <= ACeq0;
      3'b111: dispMux[10] <= SCsign;
      endcase
    end else if (skipEn50_57) begin
      case (CRAM.f.COND[3:5])
      3'b000: dispMux[10] <= pcSection0;
      3'b001: dispMux[10] <= {1'b0, FEsign, EDP_BR[0], EDP_ADcarry[-2], SCADsign};
      3'b010: dispMux[10] <= {EDP_ARX[0], EDP_AR[0], EDP_BR[0], EDP_AD[0], SCADeq0};
      3'b011: dispMux[10] <= {1'b0, DRAM_B[0:2], EDP_ADX[0]};
      3'b100: dispMux[10] <= {1'b0, FPD, EDP_AR[12], SCADsign, EDP_ADcarry[-2]};
      3'b101: dispMux[10] <= {1'b0, norm[8:10], EDP_AD[0]};
      3'b110: dispMux[10] <= {~longEnable | EDP_ARX[0], shortIndirWord,
                              EDP_ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[10] <= {eaType[7:10], localACAddress};
      endcase
    end else
      dispMux <= 0;
    
    CRADR <= CRAM.f.J | {11{force1777}} | dispMux;
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
  logic [0:7] stackAdrAD, stackAdrEH;

  logic stackAdrA = stackAdrAD[0];
  logic stackAdrB = stackAdrAD[1];
  logic stackAdrC = stackAdrAD[2];
  logic stackAdrD = stackAdrAD[3];

  logic stackAdrE = stackAdrEH[0];
  logic stackAdrF = stackAdrEH[1];
  logic stackAdrG = stackAdrEH[2];
  logic stackAdrH = stackAdrEH[3];

  logic stackAdrY = stackAdrA ^ stackAdrD;
  logic stackAdrZ = stackAdrF ^ stackAdrE;

  logic stackAdr = {stackAdrAD, stackAdrEH};
  logic stackWrite = fastMemClk & ~retNotForce1777;
  logic selCall = stackWrite | ~retNotForce1777;

  always @(posedge eboxClk) begin

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

    if (~callForce1777 && ~retNotForce1777) begin
      sbrRet <= stack[stackAdr];
    end
  end

  always @(posedge stackWrite) stack[stackAdr] <= loc;


  ////////////////////////////////////////////////////////////////
  // Diagnostics stuff
  always @(*) dispParity = ^{CRAM.f.CALL, CRAM.f.DISP};

  always @(posedge eboxClk) begin

    if (diaFunc051)
      diagAdr[5:10] <= EBUS[0:5];
    else if (diaFunc052)
      diagAdr[0:4] <= EBUS[1:5];

    loc <= adr;

    AREAD <= DRAM_A === 3'b000 ? DRAM_J : 0;
  end

  // Diagnostics driving EBUS
  always @(*) begin
    CRAdrivingEBUS <= diagReadFunc14X;

    case (DIAG_FUNC[4:6])
    3'b000: CRA_EBUS <= {dispEn00_07, dispEn00_03, stackAdr};
    3'b001: CRA_EBUS <= {CRAM.f.CALL, CRAM.f.DISP[0:4], stackAdr};
    3'b010: CRA_EBUS <= sbrRet[5:10];
    3'b011: CRA_EBUS <= {dispEn30_37, sbrRet[0:4]};
    3'b100: CRA_EBUS <= adr[5:10];
    3'b101: CRA_EBUS <= {dispParity, adr[0:4]};
    3'b110: CRA_EBUS <= loc[5:10];
    3'b111: CRA_EBUS <= {1'b0, loc[0:4]};
    endcase
  end
endmodule
