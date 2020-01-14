`timescale 1ns / 1ps
module MBOX(input clk,
            input [13:35] vma,
            input vmaACRef,
            input [37:35] mboxGateVMA,
            input [0:35] writeData,
            output [0:35] cacheData,
            input req,
            input read,
            input PSE,
            input write
            );

  FAKE_MEM mem(.clka(clk),
               .addra(vma),
               .dina(writeData),
               .douta(cacheData),
               .ena(1),
               .wea(write)
               );
endmodule // MBOX
