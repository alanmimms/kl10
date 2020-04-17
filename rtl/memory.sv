`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MB20 core memory. The A phase is
// negedge of SBUS.CLK_INT and B phase is posedge.
//
// TODO:
// * Implement BLKO PI diagnostic cycle support.
// * Support interleaving.
// * Implement hardware memory through DMA to DRAM shared with Linux.
// * Support ACKN of next word while VALID on current word
module memory(input CROBAR,
              iSBUS.memory SBUS);
`define MEM_SIZE (256*1024)

`ifdef KL10PV_TB
  bit [0:35] mem[`MEM_SIZE];
  memPhase aPhase(CROBAR, '0, mem, SBUS, SBUS.START_A, SBUS.ACKN_A, SBUS.DATA_VALID_A);
  memPhase bPhase(CROBAR, '1, mem, SBUS, SBUS.START_B, SBUS.ACKN_B, SBUS.DATA_VALID_B);
`else
`endif


  function string octW(input [0:35] w);
    $sformat(octW, "%06o,,%06o", w[0:17], w[18:35]);
  endfunction
endmodule


// This is one phase of the MB20 core memory. If `phase` is '0 we are
// the A phase (SBUS.CLK_EXT negedge). Otherwise we are the B phase
// (SBUS.CLK_EXT negedge). Control signals are driven on the edge of
// the phase they apply to, but they are latched by the other side of
// the SBUS on the NEXT edge of that phase. This was done to allow
// synchronous operation with cabling (etc.) propagation delays always
// less than the clock cycle time.
module memPhase(input CROBAR,
                input phase,
                ref bit [0:35] memory[`MEM_SIZE],
                iSBUS.memory SBUS,
                input START,
                output bit ACKN,
                output bit VALID);

  bit [12:35] addr;             // Address base we start at for quadword
  bit [34:35] wo;               // Word offset of quadword
  bit [0:3] toAck;              // Words we have not yet ACKed

  enum {
        mphIDLE,
        mphACK,
        mphREAD1,
        mphREAD2,
        mphWAIT1,
        mphWAIT2,
        mphWAIT3,
        mphWAIT4
        } state, next;

  always_ff @(negedge SBUS.CLK_INT != phase) begin
    if (CROBAR) $display($time, " CLOCK: CROBAR");

    if (!CROBAR && (state != mphIDLE || next != mphIDLE))
      $display($time, " CLOCK [IDLE]: state=%s  next=%s", state.name, next.name);

    if (CROBAR) state <= mphIDLE; // Initialize state machine
    else state <= next;           // Advance state machine
  end

  // Generate state machine next state
  always_comb begin

    case (state)
    mphIDLE:
      if (START) begin
        next = mphACK;
        $display($time, " comb START==> IDLE->ACK");
      end else begin
        next = mphIDLE;
        $display($time, " comb no START==> IDLE->IDLE");
      end

    mphACK:
      if (toAck[0]) begin
        next = mphREAD1;
        $display($time, " comb ACK->READ1 toAck[0] != 0");
      end else if (toAck == '0) begin
        next = mphWAIT1;
        $display($time, " comb ACK->WAIT1 toAck == 0");
      end

    mphREAD1: begin
      next = mphREAD2;
      $display($time, " comb READ1->READ2");
    end

    mphREAD2: begin
      next = mphACK;
      $display($time, " comb READ2->ACK");
    end

    mphWAIT1: next = mphWAIT2;
    mphWAIT2: next = mphWAIT3;
    mphWAIT3: next = mphWAIT4;
    mphWAIT4: next = mphIDLE;
    endcase
  end

  // Generate state machine outputs
  always_ff @(negedge SBUS.CLK_INT != phase) begin

    case (state)
    mphIDLE:
      if (START) begin
        $display($time, " CLOCK OUT [IDLE]: SBUS.RQ=%4b, SBUS.ADR=%8o", SBUS.RQ, SBUS.ADR);
        toAck <= SBUS.RQ;         // Still to ACK
        addr <= SBUS.ADR;         // Address of first word we do
        wo <= SBUS.ADR[34:35];    // Word offset we increment mod 4
        ACKN <= '0;
        VALID <= '0;
      end

    mphACK: begin
      $display($time, " CLOCK OUT [ACK]:                                        clear VALID");
      VALID <= '0;

      if (toAck[0]) begin
        $display($time, " CLOCK OUT [ACK]:              set ACKN");
        ACKN <= '1;
      end

      toAck <<= '1;
      $display($time, " CLOCK OUT [ACK]: shift up from toAck=%4b", toAck);
    end

    mphREAD1: begin
      $display($time, " CLOCK OUT [READ1]             clear ACKN");
      ACKN <= '0;
    end

    mphREAD2: begin
      VALID <= '1;
      SBUS.D <= memory[{addr[12:33], wo}];
      SBUS.DATA_PAR <= ~(^memory[{addr[12:33], wo}]);
      $display($time, " CLOCK OUT [READ2]: mem[%8o]=%s  ++wo   set VALID",
               {addr[12:33], wo}, octW(memory[{addr[12:33], wo}]));
      wo <= wo + 2'b01;
    end

    default: ;
    endcase
  end

  function string octW(input [0:35] w);
    $sformat(octW, "%06o,,%06o", w[0:17], w[18:35]);
  endfunction
endmodule
