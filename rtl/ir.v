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

  // DRAM write port is never needed?
  reg [23:0] DRAMwriteData;
  reg [8:0] DRAMwriteAddr;
  wire DRAMwriteClk;
  wire DRAMwriteEnable;

  assign DRAMwriteEnable = 0;
  assign DRAMwriteClk = 0;

  reg [23:0] DRAMdata;
  reg [0:12] DRADR;

 DRAMblockRAM dramRAM(.clka(DRAMwriteClk),
                      .addra(DRAMwriteAddr),
                      .dina(DRAMwriteData),
                      .wea(DRAMwriteEnable),

                      .clkb(clk),
                      .addrb(DRADR),
                      .doutb(DRAMdata),
                      .enb(1)
                      );
endmodule // IR
