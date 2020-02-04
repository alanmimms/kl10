`include "ebox.svh"
`include "mbox.svh"

module kl10pv_tb(input clk);
  logic CROBAR;
  logic masterClk;

  top top0(.*);

  // 50MHz EBOX clock
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  // Initialize our memories
  initial begin                 // FM is always zero at start
    for (int a = 0; a < $size(top0.ebox0.edp0.fm.mem); ++a)
      top0.ebox0.edp0.fm.mem[a] = '0;
  end

  initial begin                 // For now, MBOX memory is zero too
    for (int a = 0; a < $size(top0.mbox0.fake_mem.mem); ++a)
      top0.mbox0.fake_mem.mem[a] = '0;
  end

  initial $readmemh("images/DRAM.mem", top0.ebox0.ir0.dram.mem);
  initial $readmemh("images/CRAM.mem", top0.ebox0.crm0.cram.mem);

  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    CROBAR = 1;
    repeat(10) @(posedge masterClk) ;
    CROBAR = 0;
  end
  
endmodule

