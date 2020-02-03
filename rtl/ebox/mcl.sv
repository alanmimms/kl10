`timescale 1ns/1ns
// M8544 MCL
module mcl(input cshEBOXT0,
           input cshEBOXRetry,
           input pfEBOXHandle,

           iMCL MCL,

           input pcp,
           input iot,
           input user,
           input public,

           output logic eboxReqIn,
           output logic mboxRespIn,
           output logic mboxClk,

           output logic mboxXfer,
           output logic pfHold,
           output logic ptPublic,
           output logic force1777
);
endmodule // mcl
