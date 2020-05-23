// Schematic review 2020-05-21 CRA1, CRA2
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
module cra(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCRA CRA,
           iCRAM CRAM,
           iCRM CRM,
           iCSH CSH,
           iCTL CTL,
           iEDP EDP,
           iIR IR,
           iMCL MCL,
           iPAG PAG,
           iSCD SCD,
           iSHM SHM,
           iVMA VMA,
           iEBUS.mod EBUS
           );

  tCRADR dispMux;
  tCRADR diagAdr;
  tCRADR SBR_RET;

  bit dispEn00_03, dispEn00_07, dispEn30_37;
  bit SHORT_INDIR_WORD;
  bit CALL_FORCE_1777;
  bit ret;
  bit WRITE_00_19, WRITE_20_39, WRITE_40_59, WRITE_60_79;

  bit clk;
  assign clk = CLK.CRA;

  bit RESET;
  assign RESET = CLK.MR_RESET;

  // Required to get CLK to run
  initial CRA.CRADR = '0;
  
  // TEMPORARY? This looks like it belongs to an incompletely
  // implemented feature that might have been called DISP/EA TYPE
  // (37). This dispatch is never used in microcode.
  bit [7:10] eaType = 0;

  // Note E43,E3,E23 and parts of E47(Q3),E35(Q3) are in crm.v since
  // they are simple CRAM storage mapping to logical fields.

  // CRA1 p.343

  // Remaining features of E47,E35 are CRAM DISP field decoding.
  assign dispEn00_03 = CRAM.DISP[0:2] == 3'b000;
  assign dispEn00_07 = CRAM.DISP[0:1] == 2'b00;
  assign dispEn30_37 = CRAM.DISP[0:1] == 2'b11;

  assign SHORT_INDIR_WORD = ~CON.LONG_EN | ~EDP.ARX[1];
  assign CALL_FORCE_1777 = CRAM.CALL | CLK.FORCE_1777;

  // CRA2 p.344
  always_comb begin
    dispMux = '0;

    if (dispEn00_03) unique case (CRAM.DISP[3:4])
                     2'b00: dispMux[0:6] = diagAdr[0:6];
                     2'b01: dispMux[0:6] = {2'b00, IR.DRAM_J[1:4], 2'b00};
                     2'b10: dispMux[0:6] = {2'b00, CRA.AREAD[1:4], 2'b00};
                     2'b11: dispMux[0:6] = SBR_RET[0:6];
                     endcase

    if (dispEn00_07) unique case (CRAM.DISP[2:4])
                     3'b000: dispMux[7:10] = diagAdr[7:10];
                     3'b001: dispMux[7:10] = IR.DRAM_J[7:10];
                     3'b010: dispMux[7:10] = CRA.AREAD[7:10];
                     3'b011: dispMux[7:10] = SBR_RET[7:10];
                     3'b100: dispMux[7:10] = CLK.PF_DISP[7:10];
                     3'b101: dispMux[7:10] = CON.SR[0:3];
                     3'b110: dispMux[7:10] = CON.NICOND[7:10];
                     3'b111: dispMux[7:10] = SHM.SH[0:3];
                     endcase
    else if (dispEn30_37) unique case (CRAM.DISP[2:4])
                          3'b000: dispMux[7:10] = {1'b0, SCD.FE_SIGN, EDP.MQ[34:35]};
                          3'b001: dispMux[7:10] = {1'b0, SCD.FE_SIGN, EDP.BR[0], EDP.AD_CRY[-2]};
                          3'b010: dispMux[7:10] = {EDP.ARX[0], EDP.AR[0], EDP.BR[0], EDP.AD[0]};
                          3'b011: dispMux[7:10] = {1'b0, IR.DRAM_B[0:2]};
                          3'b100: dispMux[7:10] = {1'b0, SCD.FPD, EDP.AR[12], SCD.SCAD_SIGN};
                          3'b101: dispMux[7:10] = {1'b0, IR.NORM[8:10]};
                          3'b110: dispMux[7:10] = {~CON.LONG_EN | EDP.ARX[0], SHORT_INDIR_WORD,
                                                   EDP.ARX[13], SHM.INDEXED};
                          3'b111: dispMux[7:10] = eaType[7:10];
                          endcase
    else begin

      if (CON.SKIP_EN_40_47) unique case (CRAM.COND[3:5])
                             3'b000: dispMux[10] = 0; // XXX? CRA2 SPARE H is backplane signal unknown value
                             3'b001: dispMux[10] = ~SHM.AR_PAR_ODD;
                             3'b010: dispMux[10] = EDP.BR[0];
                             3'b011: dispMux[10] = EDP.ARX[0];
                             3'b100: dispMux[10] = EDP.AR[18];
                             3'b101: dispMux[10] = EDP.AR[0];
                             3'b110: dispMux[10] = IR.ACeq0;
                             3'b111: dispMux[10] = SCD.SC_SIGN;
                             endcase
      else if (CON.SKIP_EN_50_57) unique case (CRAM.COND[3:5])
                                  3'b000: dispMux[10] = MCL.PC_SECTION_0;
                                  3'b001: dispMux[10] = SCD.SCAD_SIGN;
                                  3'b010: dispMux[10] = ~SCD.SCADeq0;
                                  3'b011: dispMux[10] = EDP.ADX[0];
                                  3'b100: dispMux[10] = EDP.AD_CRY[-2];
                                  3'b101: dispMux[10] = ~EDP.AD[0];
                                  3'b110: dispMux[10] = ~IR.ADeq0;
                                  3'b111: dispMux[10] = ~VMA.LOCAL_AC_ADDRESS;
                                  endcase
    end
  end

  // CRA.CRADR
  always @(posedge clk) if (RESET) CRA.CRADR <= '0;
                        else CRA.CRADR <= CRAM.J |
                                          {1'b0, {9{CLK.FORCE_1777}}, 1'b0} |
                                          dispMux |
                                          {10'b0, CON.COND_ADR_10};
  

  assign CRA.AREAD = IR.DRAM_A == 3'b000 ? IR.DRAM_J : '0;

  bit RET_AND_not1777, CALL_RESET, CALL_RESET_1777;
  assign RET_AND_not1777 = CTL.DISP_RETURN & ~CLK.FORCE_1777;
  assign CALL_RESET = RESET | CRAM.CALL;
  assign CALL_RESET_1777 = CALL_RESET | CLK.FORCE_1777;

  `ifdef THIS_IS_BAROQUE_AND_BROKE

  tCRADR LOC;
  // E67, E72, E76 combined
  always_ff @(posedge clk) LOC <= CRA.CRADR;

  ////////////////////////////////////////////////////////////////
  // The opaque, baroque, tedious, and painful call/return stack implementation
  //
  // STACK ADDRESS SEQUENCE
  // Y  ABCD EFGH  Z  |  WRITE  READ
  // -----------------|------------
  // 0  1111 000X  0  |   16    10         RESET
  // 1  0111 1000  1  |   17    14
  // 0  1011 1100  0  |   07    16
  // 1  0101 1110  0  |   13    17
  //                  |
  // 1  1010 1111  0  |   05    07
  // 0  1101 0111  1  |   12    13
  // 0  0110 1011  1  |   15    05
  // 1  0011 0101  1  |   06    12
  //                  |
  // 0  1001 1010  1  |   03    15
  // 0  0100 1101  0  |   11    06
  // 0  0010 0110  1  |   04    03
  // 1  0001 0011  0  |   02    11
  //                  |
  // 1  1000 1001  1  |   01    04
  // 1  1100 0100  1  |   10    02
  // 1  1110 0010  0  |   14    01
  // 0  1111 0001  0  |   16    10

  bit stackAdrA, stackAdrB, stackAdrC, stackAdrD;
  bit stackAdrE, stackAdrF, stackAdrG, stackAdrH;
  bit stackAdrY, stackAdrZ;
  bit SEL_CALL, STACK_WRITE;

  assign SEL_CALL = STACK_WRITE & RET_AND_not1777; // NOTE wire-AND

  // XXX STACK_WRITE is delayed 13ns in CRA4 from CRA3 CLK A H by DL1.
  assign STACK_WRITE = clk;

  USR4 e56SR(.S0(stackAdrY),
             .D({4{RET_AND_not1777 | RESET}}),
             .Q({stackAdrA, stackAdrB, stackAdrC, stackAdrD}),
             .S3(stackAdrE),
             .SEL({CALL_RESET_1777, CALL_RESET_1777 | RESET}),
             .CLK(clk));

  USR4 e57SR(.S0(stackAdrD),
             .D('0),
             .S3(stackAdrZ),
             .Q({stackAdrE, stackAdrF, stackAdrG, stackAdrH}),
             .SEL({CALL_RESET_1777, CALL_RESET_1777 | RESET}),
             .CLK(clk));             

  assign stackAdrY = stackAdrA ^ stackAdrD;
  assign stackAdrZ = stackAdrF ^ stackAdrE;

  `define SP e62Q
  bit [0:3] e62Q;
  assign e62Q = SEL_CALL ?
                {stackAdrB, stackAdrC, stackAdrD, stackAdrE} :
                {stackAdrD, stackAdrE, stackAdrF, stackAdrG};

  // E66, E71, E81 combined
  always @(posedge clk) if (~CALL_FORCE_1777 && ~RET_AND_not1777) SBR_RET <= stack[e62Q];

  `else                         // MUCH simpler

  // NOTE: CLK FORCE 1777 is done for page faults as a synthetic call
  // (by asserting CTL SPEC CALL) to 1777 or 3777 depending on which
  // half of the microcode address space is currently running. The
  // first microinstruction of the handler is duplicated in both
  // locations to allow this to work properly. When the PF handler
  // microsubroutine is done, it just does a RETURN to re-execute the
  // microinstruction (???) that was running when the fault was
  // detected. See EK-EBOX-UD-004-OCR "3.4.5.1 CLK FORCE 1777" p.256.
  //
  // Stack discipline:
  // * SP points to next empty loc, overwritten on CALL before SP increment.
  // * SP pushes toward increasing addresses and pops back to decreasing ones.
  tCRADR stack[15:0];
  `define SP realSP
  bit [0:3] realSP;
  initial `SP = '0;

  // If this is a CALL or a synthetic call caused by page fail
  // (FORCE_1777), save current CRADR at TOS and increment SP.
  // NOTE: This is using the NEGATIVE edge.
  always @(negedge clk) if (CRAM.CALL || CLK.FORCE_1777) begin
    stack[`SP] <= CRA.CRADR;
    `SP <= `SP + 1;
  end else if (RET_AND_not1777) begin // Pop if returning and no new page fault.
    SBR_RET <= stack[`SP - 1];
    `SP <= `SP - 1;
  end
  `endif

  ////////////////////////////////////////////////////////////////
  // Diagnostics stuff
  assign CRA.DISP_PARITY = ^{CRAM.CALL, CRAM.DISP};

  always_comb if (CRA.DIA_FUNC_051) diagAdr[5:10] = EBUS.data[0:5];
              else if (CRA.DIA_FUNC_052) diagAdr[0:4] = EBUS.data[1:5];

  decoder e1(.en(CTL.DIAG_LOAD_FUNC_05x),
             .sel(CTL.DIAG[4:6]),
             .q({CRA.DIA_FUNC_050, CRA.DIA_FUNC_051, CRA.DIA_FUNC_052, CRA.DIA_FUNC_053,
                 WRITE_60_79, WRITE_40_59, WRITE_20_39, WRITE_00_19}));

  // Diagnostics driving EBUS
  assign CRA.EBUSdriver.driving = CTL.DIAG_READ_FUNC_14x;

  always_comb
    if (CRA.EBUSdriver.driving) case (CTL.DIAG[4:6])
                                3'b000: CRA.EBUSdriver.data[0:5] = {dispEn00_07, dispEn00_03, `SP};
                                3'b001: CRA.EBUSdriver.data[0:5] = {CRAM.CALL, CRAM.DISP[0:4], `SP};
                                3'b010: CRA.EBUSdriver.data[0:5] = SBR_RET[5:10];
                                3'b011: CRA.EBUSdriver.data[0:5] = {dispEn30_37, SBR_RET[0:4]};
                                3'b100: CRA.EBUSdriver.data[0:5] = CRA.CRADR[5:10];
                                3'b101: CRA.EBUSdriver.data[0:5] = {CRA.DISP_PARITY, CRA.CRADR[0:4]};
                                3'b110: CRA.EBUSdriver.data[0:5] = CRA.CRADR[5:10];
                                3'b111: CRA.EBUSdriver.data[0:5] = {1'b0, CRA.CRADR[0:4]};
                                endcase
    else CRA.EBUSdriver.data = '0;
endmodule
