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
           /*AUTOARG*/);

  wire mboxClk;
  wire eboxSync;
  wire vmaACRef;
  wire [37:35] mboxGateVMA;
  wire [0:35] cacheDataRead;
  wire [0:35] cacheDataWrite;
  wire [10:12] cacheClearer;

  wire anyEboxError;

  ebox ebox0(.cshEBOXRetry(0),
             .mboxRespIn(0),

             .pfHold(0),
             .pfEBOXHandle(0),
             .pfPublic(0),

             .cshAdrParErr(0),
             .mbParErr(0),
             .sbusErr(0),
             .nxmErr(0),
             .mboxCDirParErr(0),
             /*AUTOINST*/
             // Outputs
             .eboxVMA                   (eboxVMA[13:35]),
             .cacheClearer              (cacheClearer[10:12]),
             .eboxReq                   (eboxReq),
             .eboxSync                  (eboxSync),
             .mboxClk                   (mboxClk),
             .vmaACRef                  (vmaACRef),
             .pageTestPriv              (pageTestPriv),
             .pageIllEntry              (pageIllEntry),
             .eboxUser                  (eboxUser),
             .eboxMayBePaged            (eboxMayBePaged),
             .eboxCache                 (eboxCache),
             .eboxLookEn                (eboxLookEn),
             .ki10PagingMode            (ki10PagingMode),
             .pageAdrCond               (pageAdrCond),
             .eboxMap                   (eboxMap),
             .eboxRead                  (eboxRead),
             .eboxPSE                   (eboxPSE),
             .eboxWrite                 (eboxWrite),
             .upt                       (upt),
             .ept                       (ept),
             .userRef                   (userRef),
             .eboxCCA                   (eboxCCA),
             .eboxUBR                   (eboxUBR),
             .eboxERA                   (eboxERA),
             .eboxEnRefillRAMWr         (eboxEnRefillRAMWr),
             .eboxSBUSDiag              (eboxSBUSDiag),
             .eboxLoadReg               (eboxLoadReg),
             .eboxReadReg               (eboxReadReg),
             .ptDirWrite                (ptDirWrite),
             .ptWr                      (ptWr),
             .mboxCtl03                 (mboxCtl03),
             .mboxCtl06                 (mboxCtl06),
             .wrPtSel0                  (wrPtSel0),
             .wrPtSel1                  (wrPtSel1),
             .anyEboxError              (anyEboxError),
             // Inputs
             .clk                       (clk),
             .cshEBOXT0                 (cshEBOXT0),
             .mboxGateVMA               (mboxGateVMA[27:35]),
             .cacheData                 (cacheData[0:35]));

  mbox mbox0(.clk(mboxClk),
             .vma(eboxVMA),
             .cacheData(cacheDataRead),
             .writeData(cacheDataWrite),
             .req(eboxReq),
             .read(eboxRead),
             .PSE(eboxPSE),
             .write(eboxWrite),
             /*AUTOINST*/
             // Inputs
             .vmaACRef                  (vmaACRef),
             .mboxGateVMA               (mboxGateVMA[37:35]));
endmodule
