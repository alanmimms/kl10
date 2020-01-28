`include "cram-defs.svh"
module usePacked(input tCRAM CRAM,
                 input logic [0:5] myAD,
                 output logic [-2:36] result,
                 output logic [0:35] AD_CG,
                 output logic [0:35] AD_CP,
                 output logic [-2:36] EDP_ADcarry);

  logic [-2:36] resultEX;
  logic [-2:35] ADA, ADB;

  logic M;
  logic [0:3] S;

`define USEMYAD 1

`ifdef USEMYAD
  assign M = myAD[1];
  assign S = myAD[2:5];
`else
  assign M = CRAM.AD[1];
  assign S = CRAM.AD[2:5];
`endif

  initial begin
    ADA = 38'h0123456789;
    ADB = 38'h0876543210;
    resultEX = '0;
  end

  // AD
  genvar n;
  generate
    for (n = 0; n < 18; n = n + 6) begin : ADaluE1E2

      mc10181 alu0(.M(M),
                   .S(S),
                   .A({{3{CRAM.ADA[n+0]}}, CRAM.ADA[n+1]}),
                   .B(CRAM.ADB[n-2:n+1]),
                   .CIN(EDP_ADcarry[n+2]),
                   .F({resultEX[n-2:n-1], result[n:n+1]}),
                   .CG(AD_CG[n+0]),
                   .CP(AD_CP[n+0]),
                   .COUT(EDP_ADcarry[n-2]));
      mc10181 alu1(.M(M),
                   .S(CRAM.AD[2:5]),
                   .A(CRAM.ADA[n+2:n+5]),
                   .B(CRAM.ADB[n+2:n+5]),
                   .CIN(EDP_ADcarry[n+6]),
                   .F(result[n+2:n+5]),
                   .CG(AD_CG[n+2]),
                   .CP(AD_CP[n+2]),
                   .COUT(EDP_ADcarry[n+2]));
    end
  endgenerate
  
  localparam staticN = 18;

  mc10181 aluStatic0(.M(M),
                     .S(S),
                     .A({{3{CRAM.ADA[staticN+0]}}, CRAM.ADA[staticN+1]}),
                     .B(CRAM.ADB[staticN-2:staticN+1]),
                     .CIN(EDP_ADcarry[staticN+2]),
                     .F({resultEX[staticN-2:staticN-1], result[staticN:staticN+1]}),
                     .CG(AD_CG[staticN+0]),
                     .CP(AD_CP[staticN+0]),
                     .COUT(EDP_ADcarry[staticN-2]));
  mc10181 aluStatic1(.M(M),
                     .S(CRAM.AD[2:5]),
                     .A(CRAM.ADA[staticN+2:staticN+5]),
                     .B(CRAM.ADB[staticN+2:staticN+5]),
                     .CIN(EDP_ADcarry[staticN+6]),
                     .F(result[staticN+2:staticN+5]),
                     .CG(AD_CG[staticN+2]),
                     .CP(AD_CP[staticN+2]),
                     .COUT(EDP_ADcarry[staticN+2]));
endmodule
