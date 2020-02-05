`include "ebox.svh"
`include "mbox.svh"

module kl10pv_tb;
  logic CROBAR;
  logic masterClk;
  logic clk;

  top top0(.*);

  assign clk = masterClk;

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

  initial $readmemh("../../../../images/DRAM.mem", top0.ebox0.ir0.dram.mem);
  initial $readmemh("../../../../images/CRAM.mem", top0.ebox0.crm0.cram.mem);

  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    CROBAR = 1;
    top0.ebox0.EBUS.ds = '0;
    top0.ebox0.EBUS.diagStrobe = '0;
    top0.ebox0.CLK.GO = '1;
    top0.ebox0.CLK.RATE_SEL = 2'b00;

    // Release system CROBAR reset
    repeat(10) @(posedge masterClk) ;
    CROBAR = 0;

    // After waiting a decent interval, pretend the frontend
    // does FUNC_SET_RESET, FUNC_CLR_RESET, FUNC_START.
    repeat(16) @(posedge masterClk) ;
    top0.ebox0.clk0.CLK.FUNC_GATE = '1;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000; // DIAG_CTL_FUNC_00x for CLK
    top0.ebox0.EBUS.ds[4:6] = 3'b111; // CLK.FUNC_SET_RESET
    top0.ebox0.EBUS.diagStrobe = '1;  // Strobe this

    repeat(16) @(posedge masterClk) ;    // Return to NOP
    top0.ebox0.EBUS.diagStrobe = '0;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000;
    top0.ebox0.EBUS.ds[4:6] = 3'b000;

    repeat(16) @(posedge masterClk) ;
    top0.ebox0.clk0.CLK.FUNC_GATE = '1;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000; // DIAG_CTL_FUNC_00x for CLK
    top0.ebox0.EBUS.ds[4:6] = 3'b110; // CLK.FUNC_CLR_RESET
    top0.ebox0.EBUS.diagStrobe = '1;  // Strobe this

    repeat(16) @(posedge masterClk) ;    // Return to NOP
    top0.ebox0.EBUS.diagStrobe = '0;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000;
    top0.ebox0.EBUS.ds[4:6] = 3'b000;

    repeat(16) @(posedge masterClk) ;
    top0.ebox0.clk0.CLK.FUNC_GATE = '1;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000; // DIAG_CTL_FUNC_00x for CLK
    top0.ebox0.EBUS.ds[4:6] = 3'b001; // CLK.FUNC_START
    top0.ebox0.EBUS.diagStrobe = '1;  // Strobe this
    
    repeat(16) @(posedge masterClk) ;    // Return to NOP
    top0.ebox0.EBUS.diagStrobe = '0;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000;
    top0.ebox0.EBUS.ds[4:6] = 3'b000;
  end
  
endmodule

