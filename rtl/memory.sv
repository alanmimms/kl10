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
  
  always_ff @(negedge SBUS.CLK_INT != phase) begin

    // If we have completed all reads and acks and we see START it's a
    // new cycle.
    if (START && toAck == '0 && toRead == '0) begin
      toAck <= SBUS.RQ;         // Still to ACK
      toRead <= SBUS.RQ;        // Still to read and return
      addr <= SBUS.ADR;         // Address of first word we do
      wo <= SBUS.ADR[34:35];    // Word offset we increment mod 4

      ACKN <= '0;
      VALID <= '0;
      $display($time, " START: SBUS.RQ=%4b", SBUS.RQ);
    end else begin
      // ^^^ else is up there because we want to do first ack or valid
      // data on the NEXT cycle after START.
      
      // If this word needs to be ACKed or is being ACKed...
      if (toAck[0]) begin

        if (ACKN) begin         // If the ACK for this word is
                                // CURRENTLY asserted, we deassert it
                                // and move on to the next word.
          $display($time, " toAck DEASSERT-SHIFT: toAck=%4b", toAck);
          toAck <= {toAck[1:3], '0};
        end else begin          // Else we will assert it and stay on
                                // this word.
          $display($time, " toAck   ASSERT-SHIFT: toAck=%4b", toAck);
        end

        ACKN <= ~ACKN;          // Switch ACK state
      end else if (toAck != '0) begin
        assert(!ACKN);
        $display($time, " toAck SHIFT-ONLY: toAck=%4b", toAck);
        toAck <= {toAck[1:3], '0}; // Move on to next possible ACK
      end

      // If this word needs to be returned or VALID is asserted...
      if (toRead[0]) begin

        if (VALID) begin        // If VALID for this word is CURRENTLY
                                // asserted, we deassert it and move
                                // on to the next word.
          $display($time, " toRead DEASSERT-SHIFT: toRead=%4b", toRead);

          // Move forward to next word (modulo 4) to return.
          toRead <= {toRead[1:3], '0};
          wo <= wo + '1;
        end else begin          // Else we will drive data and assert
                                // VALID and stay on this word.
          $display($time, " toRead   ASSERT-SHIFT: toRead=%4b", toRead);
          SBUS.D <= memory[{addr[12:33], wo}];
        end

        VALID <= ~VALID;      // Switch VALID state
      end else if (toRead != '0) begin
        assert(!VALID);
        $display($time, " toRead SHIFT-ONLY: toRead=%4b", toRead);

        // Move forward to next word (modulo 4) to return.
        toRead <= {toRead[1:3], '0};
        wo <= wo + '1;
      end
    end
  end
endmodule
