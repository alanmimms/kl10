`include "cram-defs.svh"
module testPacked;
  tCRAM CRAM;
  logic [0:35] AD_CG, AD_CP;
  logic [-2:36] result, EDP_ADcarry;
  logic [0:5] myAD;

  usePacked user0(.myAD(CRAM.AD), .*);

  initial begin
    $monitor($time, " CRAM=%084b, result=%010b", CRAM, result);
    CRAM = '{default: 0};
    myAD = '0;
    AD_CG = '0;
    AD_CP = '0;
    EDP_ADcarry = '0;

    #300 CRAM.AD = adA;		myAD = adA;
    #300 CRAM.AD = adAplusB;	myAD = adAplusB;
    #300 CRAM.AD = adAminus1;	myAD = adAminus1;
  end
endmodule
