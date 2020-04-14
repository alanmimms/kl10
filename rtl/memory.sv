`timescale 1ns/1ns
`include "ebox.svh"

// This module pretends to be a MF20 MOS memory.
module memory(iSBUS.memory SBUS);

`ifdef KL10PV_TB
  bit [0:35] mem[256*1024];
  bit [0:35] w;
  bit [12:35] addr;
  bit [0:3] rqBits;

  always @(posedge SBUS.START_A) begin
    rqBits <= SBUS.RQ;
    addr <= SBUS.ADR;
    $display($time, " START_A addr=%08o rqBits=%04b", addr, rqBits);
    // 625-187ns = 438ns
    #438 ;                      // Delay inherent in KL10 design?

    while (rqBits != '0) begin

      if (rqBits[0]) begin
        SBUS.DATA_VALID_A <= '1;
        w = mem[addr];
        SBUS.D <= w;
        #187 ;                  // Word to word delay inherent in KL10 design?
        SBUS.DATA_VALID_A <= '1;
        $display($time, "   data valid=%s addr=%08o rqBits=%04b", octW(w), addr, rqBits);
      end

      rqBits <<= 1;
      ++addr;
    end
  end

  always @(posedge SBUS.START_B) begin
    rqBits = SBUS.RQ;
    addr = SBUS.ADR;
    $display($time, " START_B addr=%08o rqBits=%04b", addr, rqBits);

    #438 ;                      // Delay inherent in KL10 design?

    while (rqBits != '0) begin

      if (rqBits[0]) begin
        SBUS.DATA_VALID_B <= '0;
        w = mem[addr];
        SBUS.D <= w;
        #187 ;                  // Word to word delay inherent in KL10 design?
        SBUS.DATA_VALID_B <= '1;
        $display($time, "   data valid=%s addr=%08o rqBits=%04b", octW(w), addr, rqBits);
      end

      rqBits <<= 1;
      ++addr;
    end
  end
`else
`endif


  function string octW(input [0:35] w);
    $sformat(octW, "%06o,,%06o", w[0:17], w[18:35]);
  endfunction
endmodule
