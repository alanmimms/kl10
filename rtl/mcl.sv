`timescale 1ns/1ns
// M8544 MCL
module mcl(input eboxClk,
           input cshEBOXT0,
           input cshEBOXRetry,
           input pfEBOXHandle,

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
           output logic force1777,

           output logic MCL_VMA_SECTION_0,
           output logic MCL_MBOX_CYC_REQ,
           output logic MCL_VMA_FETCH,
           output logic MCL_LOAD_AR,
           output logic MCL_LOAD_ARX,
           output logic MCL_LOAD_VMA,
           output logic MCL_STORE_AR,
           output logic MCL_SKIP_SATISFIED,

           output logic MCL_SHORT_STACK,
           output logic MCL_18_BIT_EA,
           output logic MCL_23_BIT_EA,
           output logic MCL_LOAD_AR,
           output logic MCL_LOAD_ARX,
           output logic MCL_MEM_ARL_IND
);
endmodule // mcl
