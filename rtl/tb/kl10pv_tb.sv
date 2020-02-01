module kl10pv_tb;
  logic masterClk;
  logic eboxClk;
  logic fastMemClk;
  logic eboxReset;

  top top0(.*);

  // 50MHz EBOX clock
  initial eboxClk = 0;
  always #10 eboxClk = ~eboxClk;

  // fastMemClk is same frequency as eboxClk, but is delayed from
  // eboxClk posedge and has shorter positive duty cycle.
  initial fastMemClk = 0;
  always @(posedge eboxClk) begin
    #2 fastMemClk = 1;
    #4 fastMemClk = 0;
  end

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

  // Is this needed? clk.sv does not really need to provide our clocks
  // for testbench.
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    eboxReset = 1;
    repeat(10) @(posedge eboxClk) ;
    eboxReset = 0;
  end
  
endmodule
               
