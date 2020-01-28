module kl10pv_tb;
  logic masterClk;
  top kl10pv0(.masterClk);

  always #20 masterClk = ~masterClk;

  initial begin
    masterClk = 0;
  end
endmodule
