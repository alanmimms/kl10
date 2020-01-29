`timescale 1ns/1ns
module sim_mem 
  #(parameter SIZE = 0,
    parameter WIDTH = 0,
    parameter NBYTES = 0)
  (input clk,
   input [0:WIDTH-1] din,
   output [0:WIDTH-1] dout,
   input [0:$clog2(SIZE-1)] addr,
   input [0:NBYTES-1] wea);

  localparam BYTE_WIDTH = WIDTH / NBYTES;

  logic [0:WIDTH-1] mem [SIZE-1:0];
  logic [0:BYTE_WIDTH - 1] byteLanes [NBYTES-1:0];

  mem = '{default: '0};

  // Read data follows address, unclocked.
  always_comb begin
    dout = mem[addr];
  end

  assign byteLanes = din;

  genvar n;
  generate

    for (n = 0; n < NBYTES; ++n) begin

      always_ff @(posedge clk) begin
        if (wea[n]) mem[addr][n * NBYTES : n * NBYTES + BYTE_WIDTH - 1] = byteLanes[n];
      end
    end
  endgenerate
endmodule
