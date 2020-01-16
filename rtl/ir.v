`timescale 1ns / 1ps
// M8522 IR
module ir(input clk,
          input [0:35] cacheData,
          input [0:35] EDP_AD,
          input [0:8] CRAM_DIAG_FUNC,
          input [0:8] CRAM_magic,
          input mbXfer,
          input loadIR,
          input loadDRAM,
          input diagLoadFunc06X,
          input diagReadFunc13X,
          input inhibitCarry18,
          input SPEC_genCarry18,
          input genCarry36,
          input ADcarry_02,
          input ADcarry12,
          input ADcarry18,
          input ADcarry24,
          input ADcarry30,
          input ADcarry36,
          input ADXcarry12,
          input ADXcarry24,

          output ADeq0,
          output IOlegal,
          output ACeq0,
          output JRST0,
          output testSatisfied,
          output IRdrivingEBUS,
          output [0:35] IR_EBUS,
          output [8:10] norm,
          output [0:12] IR,
          output [9:12] IRAC,
          output [2:0] DRAM_A,
          output [2:0] DRAM_B,
          output [10:0] DRAM_J,
          output DRAM_ODD_PARITY
          /*AUTOARG*/);

  reg [23:0] DRAMdata;
  reg [0:12] DRADR;

  wire [8:10] DRAM_J_X, DRAM_J_Y;

  dram_mem dram(.clka(clk),
                .addra(DRADR),
                .douta(DRAMdata),
                .dina(0),
                .wea(0),
                .ena(1)
                /*AUTOINST*/);


  // p.210 shows older KL10 DRAM addressing.

  reg [0:2] DRAM_A_R, DRAM_B_R;
  reg [0:10] DRAM_J_R;
  reg [0:12] IR_R;
  reg [9:12] IRAC_R;

  // JRST is 0o254,F
  wire JRST;
  assign JRST = IR[0:8] === 13'b010_101_100;
  assign JRST0 = IR[0:12] === 13'b010_101_100_0000;

  // Model mc10173 mux + transparent latches
  always @(loadIR) if (loadIR) IR_R <= mbXfer ? AD[0:12] : cacheData[0:12];

  // XXX In addition to the below, this has two mystery OR term
  // signals on each input to the AND that are unlabeled except for
  // backplane references ES2 and ER2. See E66 p.128.
  assign IOlegal = &IR[3:6];
  assign ACeq0 = IR[9:12] === 4'b0;

  reg enIO_JRST;
  reg enAC;

  wire instr7XX;
  wire enableAC;
  wire magic7eq8;
  wire AgtB;

  // This mess is p.128 E55,E70,E71,E75,E76
  assign instr7XX = IR[0] & IR[1] & IR[2] & enIO_JRST;
  assign instr774 = &IR[3:6];

  wire [3:8] ioDRADR;
  assign ioDRADR[3:5] = instr7XX ? (IR[7:9] | {3{instr774}}) : IR[3:5];
  assign ioDRADR[6:8] = instr7XX ? IR[6:8] : IR[10:12];

  always @(loadDRAM) if (loadDRAM) begin
    DRADR <= {IR[0:2], instr7XX ? IR[3:8] : ioDRADR};
  end

  assign DRAM_A = DRAM_A_R;
  assign DRAM_B = DRAM_B_R;
  assign DRAM_J = DRAM_J_R;
  assign IR = IR_R;
  assign IRAC = IRAC_R;

  // There is no DRAM_J[0] or DRAM_J[5:6], so start out with 0s.
  initial DRAM_J_R <= 0;

  wire [0:2] DRAM_A_X, DRAM_A_Y, DRAM_B_X, DRAM_B_Y;
  reg [8:10] DRAM_PAR_J;
  reg DRAM_PAR;

  // XXX THIS SIGNAL does not appear to be defined in IR or anywhere.
  // It would seem it is to be combinatorially drived from
  // DRAM_PAR_X/DRAM_PAR_Y. But I can find no logic to do this.
  initial DRAM_PAR <= 0;

  // Latch-mux
  always @(loadDRAM) if (loadDRAM) begin

    if (DRADR[8]) begin
      DRAM_A_R <= DRADR[8] ? DRAM_A_X : DRAM_A_Y;
      DRAM_B_R <= DRADR[8] ? DRAM_B_X : DRAM_B_Y;
      DRAM_PAR_J[7] <= DRAM_J_R[7];
      DRAM_PAR_J[8:10] <= DRADR[8] ? DRAM_J_X[8:10] : DRAM_J_Y[8:10];
    end

    DRAM_J_R[8:10] <= JRST ? DRAM_PAR_J[7:10] : IR[9:12];
  end

  // Latch-mux
  always @(loadIR) if (loadIR) begin
    IR_R <= mbXfer ? AD[0:12] : cacheData[0:12];
    IRAC_R <= enableAC ? IR[9:12] : 4'b0;
  end

  assign magic7eq8 = CRAM_magic[7] ^ CRAM_magic[8];
  assign AgtB = AD[0] ^ ADcarry_02;
  assign ADeq0 = ~|AD;
  assign testSatisfied = |{DRAM_B[1] & ADeq0,                 // EQ
                           DRAM_B[2] & AgtB & CRAM_magic[7],  // GT
                           DRAM_B[2] & AD[0] & CRAM_magic[8], // LT
                           ~magic7eq8 & ADcarry_02            // X
                           } ^ DRAM_B[0];

  // p.130 E57 and friends
  reg dramLoadXYeven, dramLoadXYodd;
  reg dramLoadJcommon, dramLoadJeven, dramLoadJodd;
  reg enJRST5, enJRST6, enJRST7;

  // Inferred latch initialization
  initial begin
    enAC <= 0;
    enIO_JRST <= 0;
  end

  always @(*) begin

    if (diagLoadFunc06X) begin
      dramLoadXYeven <= 3'b000;
      dramLoadXYodd <= 3'b001;
      dramLoadJcommon <= 3'b010;
      dramLoadJeven <= 3'b011;
      dramLoadJodd <= 3'b100;
      enJRST5 <= 3'b101;
      enJRST6 <= 3'b110;
      enJRST7 <= 3'b111;
    end else begin
      dramLoadXYeven <= 0;
      dramLoadXYodd <= 0;
      dramLoadJcommon <= 0;
      dramLoadJeven <= 0;
      dramLoadJodd <= 0;
      enJRST5 <= 0;
      enJRST6 <= 0;
      enJRST7 <= 0;
    end

    enIO_JRST <= enJRST5 & (~enJRST7 | enIO_JRST);
    enAC <= enJRST6 & (~enJRST7 | enAC);
  end

  // p.130 E67 priority encoder
  always @(*) norm = AD[0] ? 3'b001 :
                     |AD[0:5] || AD[6] ? 3'b010 :
                     AD[7] ? 3'b011 :
                     AD[8] ? 3'b100 :
                     AD[9] ? 3'b101 :
                     AD[10] ? 3'b110 :
                     |AD[6:35];

  assign DRAM_ODD_PARITY = ^{DRAM_A, DRAM_B, DRAM_PAR, DRAM_J[1:4], DRAM_PAR_J[7:10]};

  // Diagnostics to drive EBUS
  reg [0:35] EBUS_R;
  assign ebusOut = EBUS_R;
  assign IRdrivingEBUS = diagReadFunc13X;

  always @(*) begin

    if (IRdrivingEBUS) begin

      case (CRAM_DIAG_FUNC[4:6])
      3'b000: EBUS_R[0:5] = {norm, DRADR[0:2]};
      3'b001: EBUS_R[0:5] = DRADR[3:8];
      3'b010: EBUS_R[0:5] = {enIO_JRST, enAC, IRAC[9:12]};
      3'b011: EBUS_R[0:5] = {DRAM_A[0:2], DRAM_B[0:2]};
      3'b100: EBUS_R[0:5] = {testSatisfied, JRST0, DRAM_J[1:4]};
      3'b101: EBUS_R[0:5] = {DRAM_PAR, DRAM_ODD_PARITY, DRAM_J[7:10]};
      3'b110: EBUS_R[0:5] = {ADeq0, IOlegal, inhibitCarry18,
                             SPEC_genCarry18, genCarry36, ADcarry_02};
      3'b111: EBUS_R[0:5] = {ADcarry12, ADcarry18, ADcarry24,
                             ADcarry36, ADXcarry12, ADXcarry24};
      endcase
    end else
      EBUS_R = 0;
  end

  // Look-ahead carry functions have been moved from IR to EDP.
endmodule // ir
// Local Variables:
// verilog-library-files:("../ip/dram_mem/dram_mem_stub.v")
// End:
