`timescale 1ns / 1ps
module top(
           input clk,

           input STARTbutton,
           input CONTINUEbutton,

           output LED0R,
           output LED0G,
           output LED0B,

           output LED1R,
           output LED1G,
           output LED1B
           );

  wire mboxClk;
  wire eboxSync;
  wire vmaACRef;
  wire [37:35] mboxGateVMA;
  wire [0:35] cacheDataRead;
  wire [0:35] cacheDataWrite;
  wire [10:12] cacheClearer;

  wire anyEboxError;

  EBOX ebox0(.clk(clk),

             .eboxVMA(eboxVMA),
             .cacheClearer(cacheClearer),

             // XXX temporary
             .cshEBOXT0(0),
             .cshEBOXRetry(0),
             .mboxRespIn(0),

             .eboxSync(eboxSync),
             .mboxClk(mboxClk),

             .pfHold(0),
             .pfEBOXHandle(0),
             .pfPublic(0),

             .vmaACRef(vmaACRef),

             .mboxGateVMA(mboxGateVMA),
             .cacheDataRead(cacheDataRead),
             .cacheDataWrite(cacheDataWrite),

             //             output pageTestPriv,
             //             output pageIllEntry,
             //             output eboxUser,

             //             output eboxMayBePaged,
             //             output eboxCache,
             //             output eboxLookEn,
             //             output ki10PagingMode,
             //             output pageAdrCond,

             //             output eboxMap,

             .eboxReq(eboxReq),
             .eboxRead(eboxRead),
             .eboxPSE(eboxPSE),
             .eboxWrite(eboxWrite),

             //             output upt,
             //             output ept,
             //             output userRef,

             //             output eboxCCA,
             //             output eboxUBR,
             //             output eboxERA,
             //             output eboxEnRefillRAMWr,
             //             output eboxSBUSDiag,
             //             output eboxLoadReg,
             //             output eboxReadReg,

             //             output ptDirWrite,
             //             output ptWr,
             //             output mboxCtl03,
             //             output mboxCtl06,
             //             output wrPtSel0,
             //             output wrPtSel1,

             .cshAdrParErr(0),
             .mbParErr(0),
             .sbusErr(0),
             .nxmErr(0),
             .mboxCDirParErr(0),
             .anyEboxError(anyEboxError)
             );

  MBOX mbox0(.clk(mboxClk),
             .vma(eboxVMA),
             .cacheClearer(cacheClearer),
             .vmaACRef(vmaACRef),
             .mboxGateVMA(mboxGateVMA),
             .cacheData(cacheDataRead),
             .writeData(cacheDataWrite),
             .req(eboxReq),
             .read(eboxRead),
             .PSE(eboxPSE),
             .write(eboxWrite)
             );
endmodule
