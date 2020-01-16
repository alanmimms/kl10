`timescale 1ns / 1ps
module mbox(input clk,
            input [13:35] vma,
            input vmaACRef,
            input [37:35] mboxGateVMA,
            input [0:35] writeData,
            input [0:35] cacheDataWrite,
            output reg [0:35] cacheDataRead,
            output reg [0:10] pfDisp,
            input req,
            input read,
            input PSE,
            input write
            );

  fake_mem mem0(.clka(clk),
                .addra(vma),
                .dina(writeData),
                .douta(cacheDataRead),
                .ena(1),
                .wea(write)
                );
endmodule // mbox
