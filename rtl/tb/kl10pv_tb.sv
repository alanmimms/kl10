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
    @(negedge top0.ebox0.clk0.CLK.EBUS_CLK) begin
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;          // DIAG_CTL_FUNC_00x for CLK
      top0.ebox0.EBUS.ds[4:6] = func;
      top0.ebox0.EBUS.diagStrobe = '1;            // Strobe this
    end

    @(negedge top0.ebox0.clk0.CLK.EBUS_CLK) begin
      top0.ebox0.EBUS.diagStrobe = '0;
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;
      top0.ebox0.EBUS.ds[4:6] = 3'b000;
    end

    repeat(4) @(posedge top0.ebox0.clk0.CLK.EBUS_CLK) ;
  endtask


  // FPGA_RESET resets each module separate from CROBAR mostly for
  // simulation since it depends on e.g., decrementing counters whose
  // values are indeterminate to run its startup processes (e.g., CLK
  // and CROBAR and e52Counter).
  logic FPGA_RESET;
  initial begin
    FPGA_RESET = 1;

    #100 FPGA_RESET = 0;
  end

  // CROBAR stays asserted for a long time
  initial begin
    CROBAR = 1;

    // Release system CROBAR reset
    repeat(100) @(posedge masterClk) ;
    CROBAR = 0;
  end
  

  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    top0.ebox0.EBUS.ds = '0;
    top0.ebox0.EBUS.data = '0;
    top0.ebox0.EBUS.diagStrobe = '0;

    repeat(100) @(posedge masterClk) ;

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

