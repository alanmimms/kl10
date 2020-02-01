`timescale 1ns/1ns
`include "cram-defs.svh"
`include "ebus-defs.svh"
// M8522 IR
module ir(input eboxClk,

          iIR IR,
          iCRAM CRAM,
          iCON CON,
          iCTL CTL,
          iEDP EDP,

          input [0:35] cacheDataRead,

          iEBUS EBUS,
          tEBUSdriver EBUSdriver,

          output logic [8:10] norm,
          output logic [0:12] IR,
          output logic [9:12] IRAC,
          output logic [0:2] DRAM_A,
          output logic [0:2] DRAM_B,
          output logic [0:10] DRAM_J,
          output logic DRAM_ODD_PARITY
);

  localparam DRAM_WIDTH=15;
  localparam DRAM_SIZE=512;
  localparam DRAM_ADDR_BITS=$clog2(DRAM_SIZE);

`include "cram-aliases.svh"

  logic [0:DRAM_WIDTH-1] DRAMdata;
  logic [0:DRAM_ADDR_BITS - 1] DRADR;

  logic [8:10] DRAM_J_X, DRAM_J_Y;

`ifdef KL10PV_TB
  sim_mem
    #(.SIZE(DRAM_SIZE), .WIDTH(DRAM_WIDTH), .NBYTES(1))
  dram
  (.clk(eboxClk),
   .din('0),                    // XXX
   .dout(DRAMdata),
   .addr(DRADR),
   .wea('0));                   // XXX
`else
  dram_mem dram(.clka(eboxClk),
                .addra(DRADR),
                .douta(DRAMdata),
                .dina('0),
                .wea('0),
                .ena('1));
`endif

  // p.210 shows older KL10 DRAM addressing.

  // JRST is 0o254,F
  logic JRST;
  assign JRST = IR[0:8] === 13'b010_101_100;
  assign IR.JRST0 = IR[0:12] === 13'b010_101_100_0000;

  // XXX In addition to the below, this has two mystery OR term
  // signals on each input to the AND that are unlabeled except for
  // backplane references ES2 and ER2. See E66 p.128.
  assign IR.IO_LEGAL = &IR[3:6];
  assign IR_ACeq0 = IR[9:12] === 4'b0;

  logic enIO_JRST;
  logic enAC;

  logic instr7XX;
  logic instr3thru6;
  logic enableAC;
  logic magic7eq8;
  logic AgtB;

  // This mess is p.128 E55,E70,E71,E75,E76
  assign instr7XX = IR[0] & IR[1] & IR[2] & enIO_JRST;
  assign instr3thru6 = &IR[3:6];

  logic [3:8] ioDRADR;
  assign ioDRADR[3:5] = instr7XX ? (IR[7:9] | {3{instr3thru6}}) : IR[3:5];
  assign ioDRADR[6:8] = instr7XX ? IR[6:8] : IR[10:12];

  always @(posedge CON.LOAD_DRAM) begin
    DRADR <= {IR[0:2], instr7XX ? IR[3:8] : ioDRADR};
  end

  logic [0:2] DRAM_A_X, DRAM_A_Y, DRAM_B_X, DRAM_B_Y;
  logic [7:10] DRAM_PAR_J;
  logic DRAM_PAR;

  // XXX THIS SIGNAL does not appear to be defined in IR or anywhere.
  // It would seem it is to be combinatorially drived from
  // DRAM_PAR_X/DRAM_PAR_Y. But I can find no logic to do this.
  initial DRAM_PAR = 0;

  // Latch-mux
  always @(posedge CON.LOAD_DRAM) begin

    if (DRADR[8]) begin
      DRAM_A <= DRADR[8] ? DRAM_A_X : DRAM_A_Y;
      DRAM_B <= DRADR[8] ? DRAM_B_X : DRAM_B_Y;
      DRAM_PAR_J[7] <= DRAM_J[7];
      DRAM_PAR_J[8:10] <= DRADR[8] ? DRAM_J_X[8:10] : DRAM_J_Y[8:10];
    end

    DRAM_J[8:10] <= JRST ? DRAM_PAR_J[7:10] : IR[9:12];
  end

  // Latch-mux
  always_ff @(posedge CON.LOAD_IR) begin
    IR <= CON.MB_XFER ? EDP.AD[0:12] : cacheDataRead[0:12];
    IRAC <= enableAC ? IR[9:12] : 4'b0;
  end

  assign magic7eq8 = CRAM.MAGIC[7] ^ CRAM.MAGIC[8];
  assign AgtB = EDP.AD[0] ^ EDP.AD_CRY[-2];
  assign IR.ADeq0 = ~|EDP.AD;
  assign IR.TEST_SATISFIED = |{DRAM_B[1] & IR.ADeq0,                  // EQ
                               DRAM_B[2] & AgtB & CRAM.MAGIC[7],      // GT
                               DRAM_B[2] & EDP.AD[0] & CRAM.MAGIC[8], // LT
                               ~magic7eq8 & EDP.AD_CRY[-2]           // X
                               } ^ DRAM_B[0];

  // p.130 E57 and friends
  logic dramLoadXYeven, dramLoadXYodd;
  logic dramLoadJcommon, dramLoadJeven, dramLoadJodd;
  logic enJRST5, enJRST6, enJRST7;

  // Inferred latch initialization
  initial begin
    enAC <= 0;
    enIO_JRST <= 0;
  end

  always @(*) begin

    if (CTL.DIAG_LOAD_FUNC_06x) begin
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
  always @(*) norm = EDP.AD[0] ? 3'b001 :
                     |EDP.AD[0:5] || EDP.AD[6] ? 3'b010 :
                     EDP.AD[7] ? 3'b011 :
                     EDP.AD[8] ? 3'b100 :
                     EDP.AD[9] ? 3'b101 :
                     EDP.AD[10] ? 3'b110 :
                     |EDP.AD[6:35];

  assign DRAM_ODD_PARITY = ^{DRAM_A, DRAM_B, DRAM_PAR, DRAM_J[1:4], DRAM_PAR_J[7:10]};

  // Diagnostics to drive EBUS
  assign EBUSdriver.driving = CTL.DIAG_READ_FUNC_13x;

  always @(*) begin

    if (EBUSdriver.driving) begin

      case (DIAG_FUNC[4:6])
      3'b000: EBUSdriver.data[0:5] = {norm, DRADR[0:2]};
      3'b001: EBUSdriver.data[0:5] = DRADR[3:8];
      3'b010: EBUSdriver.data[0:5] = {enIO_JRST, enAC, IRAC};
      3'b011: EBUSdriver.data[0:5] = {DRAM_A, DRAM_B};
      3'b100: EBUSdriver.data[0:5] = {IR.TEST_SATISFIED, IR.JRST0, DRAM_J[1:4]};
      3'b101: EBUSdriver.data[0:5] = {DRAM_PAR, DRAM_ODD_PARITY, DRAM_J[7:10]};
      3'b110: EBUSdriver.data[0:5] = {IR.ADeq0, IR.IO_LEGAL, CTL.INH_CRY_18,
                                      CTL.SPEC_GEN_CRY_18, CTL.SPEC_GEN_CRY_18, EDP.AD_CRY[-2]};
      3'b111: EBUSdriver.data[0:5] = {EDP.AD_CRY[12], EDP.AD_CRY[18], EDP.AD_CRY[24],
                                      EDP.AD_CRY[36], EDP.ADX_CRY[12], EDP.ADX_CRY[24]};
      endcase
    end else
      EBUSdriver.data = 'z;
  end

  // Look-ahead carry functions have been moved from IR to EDP.
endmodule // ir
// Local Variables:
// verilog-library-files:("../ip/dram_mem/dram_mem_stub.v")
// End:
