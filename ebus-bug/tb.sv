`include "ebox.svh"

module tb(iCON CON, iEBUS EBUS);

  // 50MHz clock source
  initial clk = '0;
  always #10 clk = ~clk;

  initial begin
    #100 KLMasterReset();
    #12000 $display($time, " done");
  end


  task KLMasterReset;
    $display($time, " KLMasterReset() START");
    indent = "  ";

    doDiagFunc(diagfSTART_CLOCK);

    $display($time, " KLMasterReset() DONE");
  endtask
  

  task doDiagFunc(input tDiagFunction func,
                  input [18:35] ebusRH = '0);
    @(negedge clk) begin
      EBUS.data[18:35] <= ebusRH;
      EBUS.ds <= func;
      EBUS.diagStrobe <= '1;            // Strobe this

      if (func !== diagfSTEP_CLOCK) 
        $display($time, " ASSERT EBUS.data.rh=%06o and ds=%s", ebusRH, func.name);
    end

    repeat (8) @(negedge clk) ;

    @(negedge clk) begin
      EBUS.data[18:35] <= '0;
      EBUS.diagStrobe <= '0;
      EBUS.ds <= diagfIdle;

      if (func !== diagfSTEP_CLOCK) 
        $display($time, " DEASSERT EBUS.data.rh=%06o and ds=%s", ebusRH, func.name);
    end

    repeat(16) @(posedge clk) ;
  endtask
endmodule
