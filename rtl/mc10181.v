`timescale 1ns / 1ps

module mc10181(input [3:0] S,
               input M,
               input [3:0] A,
               input [3:0] B,
               input CIN,
               output [3:0] F,
               output CG,
               output CP,
               output COUT
               );

  wire [3:0] G, P;
  wire notGG;
  wire [3:0] notF;

  assign G = ~(~(S[3] | B | A) | ~(S[2] | A | ~B));
  assign P = ~((S[1] | ~B) | ~(S[0] | B) | ~A);
  assign F = ~(G ^ P ^
               {~(M | G[2]) |
                ~(M | P[2] | G[1]) |
                ~(M | P[2] | P[1] | G[0]) |
                ~(M | P[2] | P[1] | P[0] | CIN),

                ~(M | G[1]) |
                ~(M | P[1] | G[0]) |
                ~(M | P[1] | P[0] | CIN),

                ~(M | G[0]) |
                ~(M | P[0] | CIN),

                ~(M | CIN)});
  assign notGG = ~G[3] | ~(P[3] | G[2]) | ~(P[3] | P[2] | G[1]) | ~(P[3] | P[2] | P[1] | G[0]);
  assign CG = ~notGG;
  assign CP = ~|P;
  assign COUT = ~(notGG | ~(CP | CIN));
endmodule // mc10181


`ifdef TESTBENCH
module mc10181_tb;

  reg clk;
  reg [3:0] S, A, B;
  wire [3:0] F;
  reg M, CIN;
  wire CG, CP, COUT;
  reg [31:0] s, a, b;
  reg [31:0] m, cin;

  mc10181 mc10181(.S(S), .M(M), .A(A), .B(B), .CIN(CIN), .F(F), .CG(CG), .CP(CP), .COUT(COUT));

  always #1 clk = ~clk;

  initial begin
    clk = 0;
    cin = 0;

    for (m = 0; m < 2; m = m + 1) begin
      M = m;

      for (s = 0; s < 16; s = s + 1) begin
        S = s;

        for (b = 0; b < 16; b = b + 1) begin
          B = b;

          for (a = 0; a < 16; a = a + 1) begin
            #1 A = a;
            cin = ~cin;
            CIN = cin;
          end
        end
      end
    end
  end

  initial begin
    $monitor("T=%-6D M=%b S=%4b A=%4b B=%4b CIN=%b F=%4b CG=%b CP=%b COUT=%b",
             $time, M, S, A, B, CIN, F, CG, CP, COUT);
    $dumpfile("mc10181_tb.vcd");
    $dumpvars(0, mc10181_tb);
  end
endmodule // mc10181_tb
`endif //  `ifdef TESTBENCH
