`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MB20 core memory. The A phase is
// negedge of SBUS.CLK_INT and B phase is posedge.
//
// TODO:
// * Implement BLKO PI diagnostic cycle support.
// * Support interleaving.
// * Implement hardware memory through DMA to DRAM shared with Linux.
module memory(iSBUS.memory SBUS);
`define MEM_SIZE (256*1024)

`ifdef KL10PV_TB
  bit [0:35] mem[`MEM_SIZE];
  memPhase aPhase('0, mem, SBUS, SBUS.START_A, SBUS.ACKN_A, SBUS.DATA_VALID_A);
  memPhase bPhase('1, mem, SBUS, SBUS.START_B, SBUS.ACKN_B, SBUS.DATA_VALID_B);
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
module memPhase(input phase,
                ref bit [0:35] memory[`MEM_SIZE],
                iSBUS.memory SBUS,
                input START,
                output bit ACKN,
                output bit VALID);

  bit [12:35] addr;             // Address base we start at for quadword
  bit [34:35] wo;               // Word offset of quadword
  bit [0:3] toAck;              // Words we have not yet ACKed
  bit [0:3] toRead;             // Words we have not yet read and returned

  // This set of states is used to track assert and deassert wait
  // states for ACKN and VALID.
  typedef enum {trsIdle, trsWait2More, trsWait1More} tResponseState;

  tResponseState acknState;
  tResponseState validState;
  
  always_ff @(negedge SBUS.CLK_INT == phase) begin

    if (START && toAck == '0) begin
      toAck <= SBUS.RQ;           // Still to ACK
    end else if (toAck != '0) begin
      // If this word needs to be ACKed or its ACK signal needs to be
      // deasserted...
      if (toAck[0]) begin

        // If the ACK for this word is asserted, we will deassert it
        // and move on to the next word.
        if (ACKN) toAck <= toAck << 1;

        ACKN <= ~ACKN;
      end else begin
        toAck <= toAck << 1;    // Move on to next possible ACK
      end
    end

    if (START && toRead == '0) begin
      toRead <= SBUS.RQ;          // Still to read and return
      addr <= SBUS.ADR;           // Address of first word we do
      wo <= addr[34:35];          // Word offset we increment mod 4
      $display($time, " START_%s addr=%08o rq=%5b", phase ? "B" : "A", addr, toRead);
    end else if (toRead != '0) begin
      // If this word needs to be returned or its VALID signal needs
      // to be deasserted...
      if (toRead[0]) begin

        // If the VALID for this word is asserted, we will deassert it
        // and move on to the next word.
        if (VALID) begin
          toRead <= toRead << 1;

          // Move forward to next word (modulo 4) to return.
          wo <= wo + '1;
        end

        VALID <= ~VALID;
        SBUS.D <= memory[{addr[12:33], wo}];
      end else begin
        toRead <= toRead << 1;    // Move on to next word(s)

        // Move forward to next word (modulo 4) to return.
        wo <= wo + '1;
      end
    end
  end
endmodule
