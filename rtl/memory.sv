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

  bit aClk, bClk;

  always @(posedge SBUS.START_A) aClk <= '0;
  always @(negedge SBUS.CLK_INT) aClk <= ~aClk;

  always @(posedge SBUS.START_B) bClk <= '0;
  always @(posedge SBUS.CLK_INT) bClk <= ~bClk;

  memPhase aPhase(CROBAR, aClk, mem, SBUS, SBUS.START_A, SBUS.ACKN_A, SBUS.DATA_VALID_A);
  memPhase bPhase(CROBAR, bClk, mem, SBUS, SBUS.START_B, SBUS.ACKN_B, SBUS.DATA_VALID_B);
`else
`endif
endmodule


// This is one phase of the MB20 core memory. Control signals are
// driven on the edge of the phase they apply to, but they are latched
// by the other side of the SBUS on the NEXT edge of that phase. This
// was done to allow synchronous operation with cabling (etc.)
// propagation delays always less than the clock cycle time.
//
// For now, we implement only read cycles and only non-interleaved
// organization.
//
// Note START may already be asserted for subsequent cycle while we
// are still finishing up the VALID pulses for the current one.
module memPhase(input CROBAR,
                input clk,
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
        mphACK1,
        mphACK2,
        mphACKtoREADdelay,
        mphREAD1,
        mphREAD2,
        mphSHIFT,
        mphWAITforIDLE
        } state, next;

  always_ff @(posedge clk) begin
    if (CROBAR) state <= mphIDLE; // Initialize state machine
    else state <= next;           // Advance state machine
  end

  // Generate state machine next state
  always_comb begin

    case (state)
    default: next <= state;

    mphIDLE: if (START) next = SBUS.RQ[0] ? mphACK1 : mphSHIFT;
                // else stay

    mphACK1: next = mphACK2;
    mphACK2: next = mphACKtoREADdelay;
    mphACKtoREADdelay: next = mphREAD1;
    mphREAD1: next = mphREAD2;
    mphREAD2: next = mphSHIFT;
    mphWAITforIDLE: next = mphIDLE;

    mphSHIFT: begin
      if (toAck[1]) next = mphACK1;
      else if (toAck[1:3] == '0) next = mphWAITforIDLE;
      // else stay in mphSHIFT to shift intermediate zero bits through
    end
    endcase
  end

  // Generate state machine outputs and set up internal registers.
  always_ff @(posedge clk) begin

    case (state)
    mphIDLE:
      if (START) begin
        toAck <= SBUS.RQ;         // Addresses remaining to ACK
        addr <= SBUS.ADR;         // Address of first word we do
        wo <= SBUS.ADR[34:35];    // Word offset we increment mod 4
      end

    mphACK1: ACKN <= '1;
    mphACK2: ACKN <= '1;

    mphACKtoREADdelay: ACKN <= '0;

    mphREAD1: begin
      VALID <= '1;
      SBUS.D <= memory[{addr[12:33], wo}];
      SBUS.DATA_PAR <= ^memory[{addr[12:33], wo}];
      wo <= wo + 2'b01;
    end

    mphREAD2: VALID <= '1;

    mphSHIFT: begin
      ACKN <= '0;
      VALID <= '0;
      toAck <<= '1;
    end

    default: ;
    endcase
  end
endmodule
