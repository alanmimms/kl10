`timescale 1ns / 1ps
// M8541 CRA
//
// Addressing for 2K words CRAM
// CRAM address combinatorial logic
// CRAM CALL/RETURN subroutine stack
//
// In a real KL10PV, M8541 contains the last six bits of CRAM storage.
// This has been moved to crm.v in a single unified storage module.
module cra(
           input clk,
           input clkForce1777,
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
           input [0:10] NICOND,
           input [0:3] SR,
           input [0:10] pfDisp,
           input skipEn40_47,
           input skipEn50_57,

           input ADeq0,
           input FEsign,
           input SCsign,
           input SCADsign,
           input SCADeq0,

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
  reg [1:10] AREAD;

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
  assign retNotForce1777 = RET & ~force1777;
  assign ret = dispEn00_03 && disp[3] & disp[4];

  always @(*) begin

    if (dispEn00_03) begin
      case (DISP[3:4])
      2'b00: dispMux[0:6] <= diagAdr[0:6];
      2'b01: dispMux[0:6] <= {2'b00, DRAM_J[1:4], 2'b00};
      2'b10: dispMux[0:6] <= {2'b00, AREAD[1:4], 2'b00};
      2'b11: dispMux[0:6] <= [2'b00, SBR_RET[1:6]};
      endcase
    end else if (dispEn00_07) begin
      case (DISP[2:4])
      3'b000: dispMux[7:10] <= diagAdr[7:10];
      3'b001: dispMux[7:10] <= DRAM_J[7:10];
      3'b010: dispMux[7:10] <= ADREAD[7:10];
      3'b011: dispMux[7:10] <= SBR_RET[7:10];
      3'b100: dispMux[7:10] <= pfDisp[7:10];
      3'b101: dispMux[7:10] <= SR[0:3];
      3'b110: dispMux[7:10] <= NICOND[7:10];
      3'b111: dispMux[7:10] <= SH[0:3];
      endcase
    end else if (dispEn30_37) begin
      case (DISP[2:4])
      3'b000: dispMux[7:10] <= {1'b0, FEsign, mq[34:35], pcSection0};
      3'b001: dispMux[7:10] <= {1'b0, FEsign, br[0], ADcarry_02, SCADsign};
      3'b010: dispMux[7:10] <= {ARX[0], AR[0], BR[0], AD[0], SCADeq0};
      3'b011: dispMux[7:10] <= {1'b0, DRAM_B[0:2], ADX[0]};
      3'b100: dispMux[7:10] <= {1'b0, FPD, AR[12], SCADsign, ADcarry_02};
      3'b101: dispMux[7:10] <= {1'b0, norm[8:10], ad[0]};
      3'b110: dispMux[7:10] <= {~longEnable | ARX[0], shortIndirWord,
                                ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[7:10] <= {eaType[7:10], localACAddress};
      endcase
    end else if (skipEn40_47) begin
      case ({COND035, COND045, COND055})
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
      case ({COND035, COND045, COND055})
      3'b000: dispMux[10] <= pcSection0;
      3'b001: dispMux[10] <= {1'b0, FEsign, br[0], ADcarry_02, SCADsign};
      3'b010: dispMux[10] <= {ARX[0], AR[0], BR[0], AD[0], SCADeq0};
      3'b011: dispMux[10] <= {1'b0, DRAM_B[0:2], ADX[0]};
      3'b100: dispMux[10] <= {1'b0, FPD, AR[12], SCADsign, ADcarry_02};
      3'b101: dispMux[10] <= {1'b0, norm[8:10], ad[0]};
      3'b110: dispMux[10] <= {~longEnable | ARX[0], shortIndirWord, ARX[13], indexed, ~ADeq0};
      3'b111: dispMux[10] <= {eaType[7:10], localACAddress};
      endcase
    end else
      dispMux <= 0;
    
    CRADR <= J | {11{clkForce1777}} | dispMux;
  end

  always @(*) dispPartity = ^{CRAM_CALL, DISP};

  always @(posedge clk) begin

    if (diaFunc051)
      diagAdr[5:10] <= ebusIn[0:5];
    else if (diaFunc052)
      diagAdr[0:4] <= ebusIn[1:5];

    loc <= adr;

    AREAD <= DRAM_A === 3'b000 ? DRAM_J : 0;
  end
endmodule
