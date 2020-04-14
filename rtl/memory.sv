`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MB20 core memory. The A phase is
// negedge of SBUS.CLK_INT and B phase is posedge. Control signals are
// driven on the edge of the phase they apply to, but they are latched
// by the other side of the SBUS on the NEXT edge of that phase. This
// was done to allow synchronous operation with cabling (etc.)
// propagation delays always less than the clock cycle time.
//
// TODO:
// * Implement BLKO PI diagnostic cycle support.
// * Support interleaving.
// * Implement hardware memory through DMA to DRAM shared with Linux.
module memory(iSBUS.memory SBUS);
`define MEM_SIZE (256*1024)

`ifdef KL10PV_TB
  bit [0:35] mem[`MEM_SIZE];

  memoryPhase aPhase('0, memory, SBUS, SBUS.START_A, SBUS.ACKN_A, SBUS.DATA_VALID_A);
  memoryPhase bPhase('1, memory, SBUS, SBUS.START_B, SBUS.ACKN_B, SBUS.DATA_VALID_B);
  
  bit [0:35] w;
  bit [12:35] addr;
  bit [0:1] wOffset;
  bit [12:35] fullAddr;
  bit [0:3] rqBits;

  assign fullAddr = {addr[12:33], wOffset};

  always @(posedge SBUS.CLK_INT & SBUS.START_A) begin
    rqBits <= SBUS.RQ;
    addr <= SBUS.ADR;
    wOffset <= addr[34:35];
    $display($time, " START_A addr=%08o rqBits=%04b", fullAddr, rqBits);

    while (rqBits != '0) begin

      if (rqBits[0]) begin
        // Memory latency
        repeat (4) @(posedge SBUS.CLK_INT) ;

        SBUS.ACKN_A <= '1;
        SBUS.DATA_VALID_A <= '0;
        w = mem[fullAddr];
        SBUS.D <= w;
        #187 ;                  // Word to word delay inherent in KL10 design?
        SBUS.ACKN_A <= '0;
        SBUS.DATA_VALID_A <= '1;
        $display($time, "   data valid=%s addr=%08o rqBits=%04b", octW(w), fullAddr, rqBits);
      end

      rqBits <<= 1;
      ++wOffset;
    end
  end
`else
`endif


  function string octW(input [0:35] w);
    $sformat(octW, "%06o,,%06o", w[0:17], w[18:35]);
  endfunction
endmodule


// This is one phase of the MB20 core memory. If `phase` is '0 we are
// the A phase (SBUS.CLK_EXT negedge). Otherwise we are the B phase
// (SBUS.CLK_EXT negedge).
module memPhase(input phase,
                inout bit [0:35] memory[`MEM_SIZE],
                iSBUS.memory SBUS,
                input START,
                output bit ACKN,
                output bit VALID);

endmodule
