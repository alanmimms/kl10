`timescale 1ns/1ns
module sim_mem 
  #(parameter SIZE=0,
    parameter WIDTH=0,
    parameter NBYTES=0)
  (input clk,
   input [0:WIDTH-1] din,
   output [0:WIDTH-1] dout,
   input [0:$clog2(SIZE-1)] addr,
   input [0:NBYTES-1] wea);

  localparam BYTE_WIDTH = WIDTH / NBYTES;

  typedef logic [0:NBYTES-1] [0:BYTE_WIDTH-1] tByteWord;
  tByteWord mem [SIZE];
  tByteWord lanes;

  // Convert to form that is simpler to address
  assign lanes = tByteWord'(din);

  genvar byteN;
  generate

    for (byteN = 0; byteN < NBYTES; ++byteN) begin

      always_ff @(posedge clk) begin
        if (wea[byteN]) mem[addr][byteN] <= lanes[byteN];
      end
    end
  endgenerate

  // Read data follows address unclocked.
  assign dout = WIDTH'(mem[addr]);
endmodule
