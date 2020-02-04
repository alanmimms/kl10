`timescale 1ns/1ns
`include "ebox.svh"

// M8541 CRA
//
// Addressing for 2K words CRAM
// CRAM address combinatorial logic
// CRAM CALL/RETURN subroutine stack
//
// In a real KL10PV, M8541 contains the last six bits of CRAM storage.
// This has been moved to crm.v in a single unified storage module.
module cra(iCLK CLK,
           iCON CON,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iSHM SHM,

           iCRAM CRAM,

           output tCRADR CRADR,
           iEBUS EBUS
);

  iCRA CRA();

  logic [0:11] dispMux;
  logic [0:10] diagAdr;

  logic [0:10] stack[15:0];
  logic [0:10] sbrRet;

  logic dispEn00_03, dispEn00_07, dispEn30_37;
  logic shortIndirWord;
  logic CALL_FORCE_1777;
  logic retNotForce1777;
  logic ret;

  // TEMPORARY? This looks like it belongs to an incompletely
  // implemented feature that might have been called DISP/EA TYPE
  // (37). This dispatch is never used in microcode.
  logic [7:10] eaType = 0;

`include "cram-aliases.svh"

  // Note E43,E3,E23 and parts of E47(Q3),E35(Q3) are in crm.v since
  // they are simple CRAM storage mapping to logical fields.

  // Remaining features of E47,E35 are CRAM DISP field decoding.
  assign dispEn00_03 = CRAM.DISP[0:4] === 5'b00011;
  assign dispEn00_07 = CRAM.DISP[0:4] === 5'b00111;
  assign dispEn30_37 = CRAM.DISP[0:4] === 5'b11111;

  assign shortIndirWord = ~CON.LONG_EN | EDP.ARX[1];
  assign CALL_FORCE_1777 = CRAM.CALL | CLK.FORCE_1777;
  assign ret = dispEn00_03 && CRAM.DISP[3] & CRAM.DISP[4];
  assign retNotForce1777 = ret & ~CLK.FORCE_1777;

  always_comb begin

    if (CON.DISP_EN_00_03) begin
      case (CRAM.DISP[3:4])
      2'b00: dispMux[0:6] = diagAdr[0:6];
      2'b01: dispMux[0:6] = {2'b00, IR.DRAM_J[1:4], 2'b00};
      2'b10: dispMux[0:6] = {2'b00, CRA.CRA.AREAD[1:4], 2'b00};
      2'b11: dispMux[0:6] = sbrRet;
      endcase
    end else if (CON.DISP_EN_00_07) begin
      case (CRAM.DISP[2:4])
      3'b000: dispMux[7:10] = diagAdr[7:10];
      3'b001: dispMux[7:10] = IR.DRAM_J[7:10];
      3'b010: dispMux[7:10] = CRA.CRA.AREAD[7:10];
      3'b011: dispMux[7:10] = sbrRet[7:10];
      3'b100: dispMux[7:10] = CLK.PF_DISP[7:10];
      3'b101: dispMux[7:10] = CON.SR[0:3];
      3'b110: dispMux[7:10] = CON.NICOND[7:10];
      3'b111: dispMux[7:10] = SHM.SH[0:3];
      endcase
    end else if (CON.DISP_EN_30_37) begin
      case (CRAM.DISP[2:4])
      3'b000: dispMux[7:10] = {1'b0, SCD.FE_SIGN, EDP.MQ[34:35], MCL.PC_SECTION_0};
      3'b001: dispMux[7:10] = {1'b0, SCD.FE_SIGN, EDP.BR[0], EDP.AD_CRY[-2], SCD.SCAD_SIGN};
      3'b010: dispMux[7:10] = {EDP.ARX[0], EDP.AR[0], EDP.BR[0], EDP.AD[0], SCD.SCADeq0};
      3'b011: dispMux[7:10] = {1'b0, IR.DRAM_B[0:2], EDP.ADX[0]};
      3'b100: dispMux[7:10] = {1'b0, SCD.FPD, EDP.AR[12], SCD.SCAD_SIGN, EDP.AD_CRY[-2]};
      3'b101: dispMux[7:10] = {1'b0, IR.NORM[8:10], EDP.AD[0]};
      3'b110: dispMux[7:10] = {~CON.LONG_EN | EDP.ARX[0], shortIndirWord,
                               EDP.ARX[13], SHM.INDEXED, ~IR.ADeq0};
      3'b111: dispMux[7:10] = {eaType[7:10], VMA.LOCAL_AC_ADDRESS};
      endcase
    end else if (CON.SKIP_EN_40_47) begin
      case (CRAM.COND[3:5])
      3'b000: dispMux[10] = 0;
      3'b001: dispMux[10] = SHM.AR_PAR_ODD;
      3'b010: dispMux[10] = EDP.BR[0];
      3'b011: dispMux[10] = EDP.ARX[0];
      3'b100: dispMux[10] = EDP.AR[18];
      3'b101: dispMux[10] = EDP.AR[0];
      3'b110: dispMux[10] = IR.ACeq0;
      3'b111: dispMux[10] = SCD.SC_SIGN;
      endcase
    end else if (CON.SKIP_EN_50_57) begin
      case (CRAM.COND[3:5])
      3'b000: dispMux[10] = MCL.PC_SECTION_0;
      3'b001: dispMux[10] = {1'b0, SCD.FE_SIGN, EDP.BR[0], EDP.AD_CRY[-2], SCD.SCAD_SIGN};
      3'b010: dispMux[10] = {EDP.ARX[0], EDP.AR[0], EDP.BR[0], EDP.AD[0], SCD.SCADeq0};
      3'b011: dispMux[10] = {1'b0, IR.DRAM_B[0:2], EDP.ADX[0]};
      3'b100: dispMux[10] = {1'b0, SCD.FPD, EDP.AR[12], SCD.SCAD_SIGN, EDP.AD_CRY[-2]};
      3'b101: dispMux[10] = {1'b0, IR.NORM[8:10], EDP.AD[0]};
      3'b110: dispMux[10] = {~CON.LONG_EN | EDP.ARX[0], shortIndirWord,
                             EDP.ARX[13], SHM.INDEXED, ~IR.ADeq0};
      3'b111: dispMux[10] = {eaType[7:10], VMA.LOCAL_AC_ADDRESS};
      endcase
    end else
      dispMux = 0;
  end


  // CRADR
  always @(posedge CLK.EBOX_CLK) begin

    if (CLK.EBOX_RESET)
      CRADR <= 0;
    else
      CRADR <= CRAM.J | {11{CLK.FORCE_1777}} | dispMux;
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
  logic stackWrite = CLK.EBOX_CLK & ~retNotForce1777;
  logic selCall = stackWrite | ~retNotForce1777;

  always @(posedge CLK.EBOX_CLK) begin

    if (CALL_FORCE_1777 && retNotForce1777) begin // LOAD
      stackAdrAD <= 4'b1111;
      stackAdrEH <= 4'b0000;
    end else if (CALL_FORCE_1777) begin           // 0in+0
      stackAdrAD <= {stackAdrY, {3{retNotForce1777}}};
             stackAdrEH <= {stackAdrD, 3'b000};
           end else if (retNotForce1777) begin         // 3in+3
             stackAdrAD <= {{3{retNotForce1777}}, stackAdrE};
             stackAdrEH <= {3'b000, stackAdrZ};
           end else begin                              // HOLD
             stackAdrAD <= stackAdrAD;
             stackAdrEH <= stackAdrEH;
           end

    if (~CALL_FORCE_1777 && ~retNotForce1777) begin
      sbrRet <= stack[stackAdr];
    end
  end

  always @(posedge stackWrite) stack[stackAdr] <= CRADR;


  ////////////////////////////////////////////////////////////////
  // Diagnostics stuff
  assign CRA.DISP_PARITY = ^{CRAM.CALL, CRAM.DISP};

  always_comb begin

    if (CTL.diaFunc051)
      diagAdr[5:10] = EBUS.data[0:5];
    else if (CTL.diaFunc052)
      diagAdr[0:4] = EBUS.data[1:5];

    CRA.CRA.AREAD = IR.DRAM_A === 3'b000 ? IR.DRAM_J : 0;
  end

  // Diagnostics driving EBUS
  assign CRA.EBUSdriver.driving = CTL.DIAG_READ_FUNC_14x;

  always_comb begin

    if (CRA.EBUSdriver.driving) begin

      case (DIAG_FUNC[4:6])
      3'b000: CRA.EBUSdriver.data = {dispEn00_07, dispEn00_03, stackAdr};
      3'b001: CRA.EBUSdriver.data = {CRAM.CALL, CRAM.DISP[0:4], stackAdr};
      3'b010: CRA.EBUSdriver.data = sbrRet[5:10];
      3'b011: CRA.EBUSdriver.data = {dispEn30_37, sbrRet[0:4]};
      3'b100: CRA.EBUSdriver.data = CRADR[5:10];
      3'b101: CRA.EBUSdriver.data = {CRA.DISP_PARITY, CRADR[0:4]};
      3'b110: CRA.EBUSdriver.data = CRADR[5:10];
      3'b111: CRA.EBUSdriver.data = {1'b0, CRADR[0:4]};
      endcase
    end else
      CRA.EBUSdriver.data = 'z;
  end
endmodule
