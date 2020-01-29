`timescale 1ns/1ns
module sim_mem_tb;

  parameter SIZE3=100, WIDTH3=36, NBYTES3=3;

  logic clk;
  logic [0:WIDTH3-1] din3;
  logic [0:WIDTH3-1] dout3;
  logic [0:NBYTES3-1] wea3;

  sim_mem twobyte
    #(SIZE=SIZE3, WIDTH=WIDTH3, NBYTES=NBYTES3)
  (.clk(clk),
   .din(din3),
   .dout(dout3),
   .addr(addr3),
   .wea(wea3));
  
  initial begin
    twobyte.mem[13] = 36'h123456789;
    twobyte.mem[17] = 36'h987654321;
    clk = 0;
    wea3 = 0;
    addr3 = 0;
    din3 = 0;
    
    $monitor($time, " addr3=%2h din3=%9h dout3=%9h wea3=%3b", addr3, din3, dout3, wea3);

    #10 addr3 = 13;             // Read[13]
    #10 addr3 = 17;             // Read[17]

    #10 addr3 = 7;              // Write[7] = 111111111
    din3 = 36'h111_111_111;
    wea3 = 2b111;               // Write full word (all three byte lanes)
    clk = 1;
    #10 clk = 0;                // Should read[7] with updated data

    #10 wea3 = 0;               // Now write one lane at a time
    din3 = 36'222_ddd_ccc;
    wea3 = 3'b100;              // Write leftmost lane
    clk = 1;                    // Should read[7] showing 222 in leftmost lane

    #10 clk = 0;
    din3 = 36'eee_333_ccc;      // Make sure we only write the lane we select
    wea3 = 3'b010;              // Write middle lane
    #10 clk = 1;

    #10 clk = 0;
    din3 = 36'eee_ddd_444;      // Make sure we only write the lane we select
    wea3 = 3'b010;              // Write rightmost lane
    #10 clk = 1;

    #10 clk = 0;
    addr3 = 13;                 // Read[13] again

    #10 clk = 0;
    addr3 = 17;                 // Read[17] again
  end

endmodule
