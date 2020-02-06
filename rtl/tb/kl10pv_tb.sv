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


  // Request the specified CLK diagnostic function as if we were the
  // front-end setting up a KL10pv.
  task doCLKFunction(input int func);
    localparam N = 6;
    top0.ebox0.clk0.CLK.FUNC_GATE = '1;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000;          // DIAG_CTL_FUNC_00x for CLK
    top0.ebox0.EBUS.ds[4:6] = func;
    top0.ebox0.EBUS.diagStrobe = '1;            // Strobe this

    repeat(N) @(posedge masterClk) ;
    top0.ebox0.EBUS.diagStrobe = '1;
    top0.ebox0.EBUS.ds[0:3] = 4'b0000;
    top0.ebox0.EBUS.ds[4:6] = 3'b000;

    repeat(N) @(posedge masterClk) ;
    top0.ebox0.EBUS.diagStrobe = '0;
    repeat(N) @(posedge masterClk) ;
  endtask


  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    CROBAR = 1;
    top0.ebox0.EBUS.ds = '0;
    top0.ebox0.EBUS.data = '0;
    top0.ebox0.EBUS.diagStrobe = '0;

    // Release system CROBAR reset
    repeat(10) @(posedge masterClk) ;
    CROBAR = 0;

    // Do (as a front-end would) the CLK diagnostic functions:
    //
    // * FUNC_SET_RESET
    // * FUNC_START
    // * FUNC_CLR_RESET
    //
    // // XXX this needs to change when we have channels. See
    // PARSER.LST .MRCLR function.
    doCLKFunction(3'b111);      // CLK.FUNC_SET_RESET
    doCLKFunction(3'b001);      // CLK.FUNC_START
    doCLKFunction(3'b110);      // CLK.FUNC_CLR_RESET
  end
  
endmodule

