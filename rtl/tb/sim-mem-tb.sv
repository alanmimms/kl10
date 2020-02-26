`timescale 1ns/1ns
module sim_mem_tb;
  localparam SIZE3=100, WIDTH3=36, NBYTES3=3;
  localparam ADDR_WIDTH3 = $clog2(SIZE3-1);
  bit clk;
  bit [0:WIDTH3-1] din3;
  bit [0:WIDTH3-1] dout3;
  bit [0:NBYTES3-1] wea3;
  bit [0:ADDR_WIDTH3] addr3;

  sim_mem
    #(.SIZE(SIZE3), .WIDTH(WIDTH3), .NBYTES(NBYTES3))
  dut3(.clk(clk),
       .din(din3),
       .dout(dout3),
       .addr(addr3),
       .wea(wea3));
  
  initial begin
    $display(">>>>> SIZE3=%d WIDTH3=%d NBYTES3=%d ADDR_WIDTH3=%d",
             SIZE3, WIDTH3, NBYTES3, ADDR_WIDTH3);
    $display($time, ">>>>> initialize mem['h13]=36'h123456789 mem['h17]=36'h987654321");
    dut3.mem['h13] = 36'h123456789;
    dut3.mem['h17] = 36'h987654321;
    clk = 0;
    wea3 = 0;
    addr3 = 0;
    din3 = 0;
    
    $monitor($time, " addr3=%2h din3=%9h dout3=%9h wea3=%3b", addr3, din3, dout3, wea3);

    #10 $display($time, ">>>>> Read['h13]");
    addr3 = 'h13;

    #10 $display($time, ">>>>> Read[h'17]");
    addr3 = 'h17;

    #10 $display($time, ">>>>> Write['h7]=36'h111_111_111");
    addr3 = 'h7;                // Write['h7] = 111111111
    din3 = 36'h111_111_111;
    wea3 = 3'b111;              // Write full word (all three byte lanes)
    clk = 1;

    #10 clk = 0;                // Should read['h7] with updated data
    $display($time, ">>>>> Write['h7] left lane=9'h222");
    din3 = 36'h222_ddd_ccc;
    wea3 = 3'b100;              // Write leftmost lane
    #10 clk = 1;                // Should read['h7] showing 222 in leftmost lane

    #10 clk = 0;
    $display($time, ">>>>> Write['h7] middle lane=9'333");
    din3 = 36'heee_333_ccc;     // Make sure we only write the lane we select
    wea3 = 3'b010;              // Write middle lane
    #10 clk = 1;

    #10 clk = 0;
    $display($time, ">>>>> Write['h7] right lane=9'444");
    din3 = 36'heee_ddd_444;     // Make sure we only write the lane we select
    wea3 = 3'b001;              // Write rightmost lane
    #10 clk = 1;

    #10 clk = 0;
    din3 = 'z;
    wea3 = '0;
    $display($time, ">>>>> Read[h'13]");
    addr3 = 'h13;               // Read['h13] again

    #10 $display($time, ">>>>> Read[h'17]");
    addr3 = 'h17;               // Read['h17] again
  end

endmodule
