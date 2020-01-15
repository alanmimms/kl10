`timescale 1ns / 1ps
// M8544 MCL
module mcl(output eboxReqIn,
           input cshEBOXT0,
           input cshEBOXRetry,
           output mboxRespIn,
           output eboxSync,
           output mboxClk,
           input pfEBOXHandle,
           output mboxXfer,
           output pfHold,
           output ptPublic,
           output clkForce1777,

           input pcp,
           input iot,
           input user,
           input public
           );
endmodule // mcl
