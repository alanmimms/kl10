`timescale 1ns / 1ps
module mbox(input clk,
            input [13:35] EBOX_VMA,
            input vmaACRef,
            input [37:35] mboxGateVMA,
            input [0:35] cacheDataWrite,
            output reg [0:35] cacheDataRead,
            output reg [0:10] pfDisp,
            input req,
            input read,
            input PSE,
            input write
            /*AUTOARG*/);

  fake_mem mem0(.clka(clk),
                .addra(EBOX_VMA),
                .dina(cacheDataWrite),
                .douta(cacheDataRead),
                .ena(1),
                .wea(write)
                /*AUTOINST*/);
endmodule // mbox
// Local Variables:
// verilog-library-files:("../ip/fake_mem/fake_mem_stub.v")
// End:
