`timescale 1ns / 1ps
// M8522 IR
module IR(input clk,
          output [10:12] irac,
          input [0:35] cacheData,
          output irIOLegal,
          input [0:35] AD,
          input [0:35] EBUS,
          input [0:8] CRAM_magic,
          output JRST0,
          output [3:0] DRAM_A,
          output [3:0] DRAM_B,
          output [10:0] DRAM_J
          );

  reg [23:0] DRAMdata;
  reg [0:12] DRADR;

  DRAMmem dram(.clka(clk),
               .addra(DRADR),
               .douta(DRAMdata),
               .dina(0),
               .wea(0),
               .ena(1)
               );
endmodule // IR
