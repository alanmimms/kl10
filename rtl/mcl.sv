// M8544 MCL
module mcl(input eboxClk,
           output eboxReqIn,
           input cshEBOXT0,
           input cshEBOXRetry,
           output mboxRespIn,
           output eboxSync,
           output mboxClk,
           input pfEBOXHandle,
           output mboxXfer,
           output pfHold,
           output ptPublic,
           output force1777,

           input pcp,
           input iot,
           input user,
           input public
           /*AUTOARG*/);
  timeunit 1ns;
  timeprecision 1ps;
endmodule // mcl
