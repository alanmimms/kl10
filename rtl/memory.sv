`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MF20 MOS memory.
module memory(iSBUS.memory SBUS);

`ifdef KL10PV_TB
  bit [0:35] mem[256*1024];
  bit [0:35] w;
  bit [12:35] addr;
  bit [0:1] wOffset;
  bit [12:35] fullAddr;
  bit [0:3] rqBits;

  assign fullAddr = {addr[12:33], wOffset};

  always @(posedge SBUS.START_A) begin
    rqBits <= SBUS.RQ;
    addr <= SBUS.ADR;
    wOffset = '0;
    $display($time, " START_A addr=%08o rqBits=%04b", fullAddr, rqBits);
    // 625-187ns = 438ns
    #438 ;                      // Delay inherent in KL10 design?

    while (rqBits != '0) begin

      if (rqBits[0]) begin
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

  always @(posedge SBUS.START_B) begin
    rqBits = SBUS.RQ;
    addr = SBUS.ADR;
    SBUS.ACKN_B <= '1;
    wOffset = '0;
    $display($time, " START_B addr=%08o rqBits=%04b", fullAddr, rqBits);

    #438 ;                      // Delay inherent in KL10 design?

    while (rqBits != '0) begin

      if (rqBits[0]) begin
        SBUS.ACKN_B <= '1;
        SBUS.DATA_VALID_B <= '0;
        w = mem[fullAddr];
        SBUS.D <= w;
        #187 ;                  // Word to word delay inherent in KL10 design?
        SBUS.ACKN_B <= '0;
        SBUS.DATA_VALID_B <= '1;
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
