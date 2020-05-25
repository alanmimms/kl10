`timescale 1ns/1ns
`include "ebox.svh"

// M8522 IR
module ir(iIR IR,
          iCRAM CRAM,
          iCLK CLK,
          iCON CON,
          iCTL CTL,
          iEDP EDP,
          iEBUS.mod EBUS,
          iMBOX MBOX
          );

  localparam DRAM_WIDTH=15;
  localparam DRAM_SIZE=512;
  localparam DRAM_ADDR_BITS=$clog2(DRAM_SIZE);

  bit [0:DRAM_WIDTH-1] DRAMdata;
  bit [0:DRAM_ADDR_BITS - 1] DRADR;

  bit [8:10] DRAM_J_X, DRAM_J_Y;

  bit IR_CLK;
  assign IR_CLK = CLK.IR;


  initial begin
    IR.IR <= '0;
    IR.AC <= '0;
  end
  

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(DRAM_SIZE), .WIDTH(DRAM_WIDTH), .NBYTES(1))
  dram
    (.clk(IR_CLK),
     .din('0),                    // XXX
     .dout(DRAMdata),
     .addr(DRADR),
     .oe(1'b1),
     .wea(1'b0));                   // XXX
`else
  dram_mem dram(.clka(IR_CLK),
                .addra(DRADR),
                .douta(DRAMdata),
                .dina('0),
                .wea(1'b0),
                .ena(1'b1));
`endif

  // p.210 shows older KL10 DRAM addressing.

  // JRST is 0o254,F
  bit JRST;
  assign JRST = IR.IR[0:8] == 13'b010_101_100;
  assign IR.JRST0 = IR.IR[0:12] == 13'b010_101_100_0000;

  // XXX In addition to the below, this has two mystery OR term
  // signals on each input to the AND that are unlabeled except for
  // backplane references ES2 and ER2. See E66 p.128.
  assign IR.IO_LEGAL = &IR.IR[3:6];
  assign IR.ACeq0 = IR.IR[9:12] == 4'b0;

  bit enIO_JRST;
  bit enAC;

  bit instr7XX;
  bit instr3thru6;
  bit enableAC;
  bit magic7eq8;
  bit AgtB;

  // This mess is p.128 E55,E70,E71,E75,E76
  assign instr7XX = IR.IR[0] & IR.IR[1] & IR.IR[2] & enIO_JRST;
  assign instr3thru6 = &IR.IR[3:6];

  bit [3:8] ioDRADR;
  assign ioDRADR[3:5] = instr7XX ? (IR.IR[7:9] | {3{instr3thru6}}) : IR.IR[3:5];
  assign ioDRADR[6:8] = instr7XX ? IR.IR[6:8] : IR.IR[10:12];

  always @(posedge CON.LOAD_DRAM) DRADR <= {IR.IR[0:2], instr7XX ? IR.IR[3:8] : ioDRADR};

  bit [0:2] DRAM_A_X, DRAM_A_Y, DRAM_B_X, DRAM_B_Y;
  bit [7:10] DRAM_PAR_J;
  bit DRAM_PAR;

  // XXX this is to allow CLK to start up
  initial begin
    IR.DRAM_A = '0;
    IR.DRAM_B = '0;
    DRAM_PAR_J = '0;
  end

  // XXX THIS SIGNAL does not appear to be defined in IR or anywhere.
  // It would seem it is to be combinatorially drived from
  // DRAM_PAR_X/DRAM_PAR_Y. But I can find no logic to do this.
  initial begin
    DRAM_PAR = 0;
  end

  // Latch-mux
  always @(posedge CON.LOAD_DRAM) if (DRADR[8]) begin
    IR.DRAM_A <= DRADR[8] ? DRAM_A_X : DRAM_A_Y;
    IR.DRAM_B <= DRADR[8] ? DRAM_B_X : DRAM_B_Y;
    DRAM_PAR_J[7] <= IR.DRAM_J[7];
    DRAM_PAR_J[8:10] <= DRADR[8] ? DRAM_J_X[8:10] : DRAM_J_Y[8:10];
  end

  always @(posedge CON.LOAD_DRAM) IR.DRAM_J[8:10] <= JRST ? DRAM_PAR_J[7:10] : IR.IR[9:12];

  // Latch-mux
  always_ff @(posedge CON.LOAD_IR) IR.IR <= CLK.MB_XFER ? EDP.AD[0:12] : MBOX.CACHE_DATA[0:12];
  always_ff @(posedge CON.LOAD_IR) IR.AC <= enableAC ? IR.IR[9:12] : 4'b0;

  assign magic7eq8 = CRAM.MAGIC[7] ^ CRAM.MAGIC[8];
  assign AgtB = EDP.AD[0] ^ EDP.AD_CRY[-2];
  assign IR.ADeq0 = ~|EDP.AD;
  assign IR.TEST_SATISFIED = |{IR.DRAM_B[1] & IR.ADeq0,                  // EQ
                               IR.DRAM_B[2] & AgtB & CRAM.MAGIC[7],      // GT
                               IR.DRAM_B[2] & EDP.AD[0] & CRAM.MAGIC[8], // LT
                               ~magic7eq8 & EDP.AD_CRY[-2]               // X
                               } ^ IR.DRAM_B[0];

  // p.130 E57 and friends
  bit dramLoadXYeven, dramLoadXYodd;
  bit dramLoadJcommon, dramLoadJeven, dramLoadJodd;
  bit enJRST5, enJRST6, enJRST7;

  always_comb if (CTL.DIAG_LOAD_FUNC_06x) begin
    dramLoadXYeven = 3'b000;
    dramLoadXYodd = 3'b001;
    dramLoadJcommon = 3'b010;
    dramLoadJeven = 3'b011;
    dramLoadJodd = 3'b100;
    enJRST5 = 3'b101;
    enJRST6 = 3'b110;
    enJRST7 = 3'b111;
  end else begin
    dramLoadXYeven = 0;
    dramLoadXYodd = 0;
    dramLoadJcommon = 0;
    dramLoadJeven = 0;
    dramLoadJodd = 0;
    enJRST5 = 0;
    enJRST6 = 0;
    enJRST7 = 0;
  end

  assign enIO_JRST = enJRST5 & (~enJRST7 | enIO_JRST);
  assign enAC = enJRST6 & (~enJRST7 | enAC);

  // p.130 E67 priority encoder
  assign IR.NORM = EDP.AD[0] ? 3'b001 :
                   |EDP.AD[0:5] || EDP.AD[6] ? 3'b010 :
                   EDP.AD[7] ? 3'b011 :
                   EDP.AD[8] ? 3'b100 :
                   EDP.AD[9] ? 3'b101 :
                   EDP.AD[10] ? 3'b110 :
                   |EDP.AD[6:35];

  assign IR.DRAM_ODD_PARITY = ^{IR.DRAM_A,
                                IR.DRAM_B,
                                DRAM_PAR,
                                IR.DRAM_J[1:4],
                                DRAM_PAR_J[7:10]};

  // Diagnostics to drive EBUS
  assign IR.EBUSdriver.driving = CTL.DIAG_READ_FUNC_13x;

  always_comb
    if (IR.EBUSdriver.driving) case (CTL.DIAG[4:6])
                               3'b000: IR.EBUSdriver.data[0:5] = {IR.NORM, DRADR[0:2]};
                               3'b001: IR.EBUSdriver.data[0:5] = DRADR[3:8];
                               3'b010: IR.EBUSdriver.data[0:5] = {enIO_JRST, enAC, IR.AC};
                               3'b011: IR.EBUSdriver.data[0:5] = {IR.DRAM_A, IR.DRAM_B};
                               3'b100: IR.EBUSdriver.data[0:5] = {IR.TEST_SATISFIED, IR.JRST0, IR.DRAM_J[1:4]};
                               3'b101: IR.EBUSdriver.data[0:5] = {DRAM_PAR, IR.DRAM_ODD_PARITY, IR.DRAM_J[7:10]};
                               3'b110: IR.EBUSdriver.data[0:5] = {IR.ADeq0, IR.IO_LEGAL,
                                                                  CTL.INH_CRY_18, CTL.SPEC_GEN_CRY_18,
                                                                  CTL.SPEC_GEN_CRY_18, EDP.AD_CRY[-2]};
                               3'b111: IR.EBUSdriver.data[0:5] = {EDP.AD_CRY[12], EDP.AD_CRY[18],
                                                                  EDP.AD_CRY[24], EDP.AD_CRY[36],
                                                                  EDP.ADX_CRY[12], EDP.ADX_CRY[24]};
                               endcase
    else IR.EBUSdriver.data = 'z;

  // Look-ahead carry functions have been moved from IR to EDP.
endmodule // ir
// Local Variables:
// verilog-library-files:("../ip/dram_mem/dram_mem_stub.v")
// End:
