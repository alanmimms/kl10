module kl10pv_tb;
  logic masterClk;
  logic eboxClk;
  logic fastMemClk;
  logic eboxReset;

  sim_mem fm #(SIZE=128, WIDTH=36, NBYTES=1)();

  logic [0:35] fm[0:127];
  logic [0:14] dram[0:511];
  logic [0:83] cram[0:2047];

  top kl10pv0(.*);

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
  initial begin
    for (int a = 0; a < 128; ++a) fm[a] = '0;
  end

  initial $readmemh("images/DRAM.coe", dram);
  initial $readmemh("images/CRAM.coe", cram);

  // Is this needed? clk.sv does not really need to provide our clocks
  // for testbench.
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  initial begin                 // Smash RESET on for a few clocks
    eboxReset = 1;
    repeat(10) @(posedge eboxClk) ;
    eboxReset = 0;
  end
  
endmodule


module sim_mem 
  #(parameter SIZE = 0,
    parameter WIDTH = 0,
    parameter NBYTES = 0)
  (input clk,
   input [0:WIDTH-1] din,
   output [0:WIDTH-1] dout,
   input [0:$clog2(SIZE-1)] addr,
   input [0:NBYTES-1] wea,
   output [0:WIDTH-1] backingMemory[0:SIZE-1]
   );

endmodule
               
