`include "ebox.svh"
`include "mbox.svh"

module kl10pv_tb;
  logic CROBAR;
  logic masterClk;
  logic clk;

  top top0(.*);

  assign clk = masterClk;

  // 50MHz EBOX clock
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  // Initialize our memories
  initial begin                 // FM is always zero at start
    for (int a = 0; a < $size(top0.ebox0.edp0.fm.mem); ++a)
      top0.ebox0.edp0.fm.mem[a] = '0;
  end

  initial begin                 // For now, MBOX memory is zero too
    for (int a = 0; a < $size(top0.mbox0.fake_mem.mem); ++a)
      top0.mbox0.fake_mem.mem[a] = '0;
  end

  initial $readmemh("../../../../images/DRAM.mem", top0.ebox0.ir0.dram.mem);
  initial $readmemh("../../../../images/CRAM.mem", top0.ebox0.crm0.cram.mem);


  // XXX until implemented
  initial begin
    top0.ebox0.CON.MBOX_WAIT = '0;
    top0.ebox0.con0.CON_MEM_CYCLE = '0;
    top0.ebox0.CLK.RESP_MBOX = '0;
    top0.ebox0.CLK.SYNC = '0;
    top0.ebox0.VMA.AC_REF = '0;
    top0.ebox0.APR.APR_PAR_CHK_EN = '0;
    top0.ebox0.PAG.PF_EBOX_HANDLE = '0;

    top0.ebox0.CLK.FS_EN_A = '0;
    top0.ebox0.CLK.FS_EN_B = '0;
    top0.ebox0.CLK.FS_EN_C = '0;
    top0.ebox0.CLK.FS_EN_D = '0;
    top0.ebox0.CLK.FS_EN_E = '0;
    top0.ebox0.CLK.FS_EN_F = '0;
    top0.ebox0.CLK.FS_EN_G = '0;
    top0.ebox0.CLK.FS_EN_A = '0;
  end

  // XXX these should be initialized by front end via diag functions?
  initial begin
    top0.ebox0.CLK.SOURCE_SEL = '0;
    top0.ebox0.CLK.RATE_SEL = '0;
    top0.ebox0.CLK.EBOX_CRM_DIS = '0;
    top0.ebox0.CLK.EBOX_EDP_DIS = '0;
    top0.ebox0.CLK.EBOX_CTL_DIS = '0;
    top0.ebox0.CLK.FM_PAR_CHECK = '0;
    top0.ebox0.CLK.CRAM_PAR_CHECK = '0;
    top0.ebox0.CLK.DRAM_PAR_CHECK = '0;
    top0.ebox0.CLK.FS_CHECK = '0;
    top0.ebox0.CLK.MBOX_CYCLE_DIS = '0;
    top0.ebox0.clk0.MBOX_RESP_SIM = '0;
    top0.ebox0.clk0.AR_ARX_PAR_CHECK = '0;
    top0.ebox0.CLK.ERR_STOP_EN = '0;
  end

  initial begin
    top.ebox0.ctl0.DIAG_MEM_RESET = '0;
    top.ebox0.CTL.DIAG_CHANNEL_CLK_STOP = '0;
    top.ebox0.CTL.DIAG_LD_EBUS_REG = '0;
    top.ebox0.CTL.DIAG_FORCE_EXTEND = '0;
  end

  initial begin
    top.ebox0.CRM.PAR_16 = '0;
  end
  
  // Request the specified CLK diagnostic function as if we were the
  // front-end setting up a KL10pv.
  task doCLKFunction(input int func);
    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;          // DIAG_CTL_FUNC_00x for CLK
      top0.ebox0.EBUS.ds[4:6] = func;
      top0.ebox0.EBUS.diagStrobe = '1;            // Strobe this
    end

//    #100;                       // How long should this really hold?

    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;
    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;

    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      top0.ebox0.EBUS.diagStrobe = '0;
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;
      top0.ebox0.EBUS.ds[4:6] = 3'b000;
    end

    repeat(4) @(posedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;
  endtask


  // Patterned after PARSER .RESET function and table RESETT.
  task KLMasterReset();
    // Reset the DTE-20
    // D2.RST (100)
    // D3.RST (001)

    // Set and then clear EBOX_RESET (XXX not in .RESET function)
    doCLKFunction(3'b111);      // CLK.FUNC_SET_RESET
    doCLKFunction(3'b110);      // CLK.FUNC_CLR_RESET

    // (000) Stop the KL clock
    doCLKFunction(0);
    // (044) Clear the KL clock source and rate
    doCLKFunction(9'b000_100_100);
    // FW.IPE (046) Reset the parity registers
    doCLKFunction(9'b000_100_110);
    // Do contents of RESETT table:
    // FW.LBR (042) Clear burst counter RIGHT
    doCLKFunction(9'b000_100_010);
    // FW.LBL (043) Clear burst counter LEFT
    doCLKFunction(9'b000_100_011);
    // FW.CA2 (052) Clear CRAM diag address LEFT
    // FW.CA1 (051) Clear CRAM diag address RIGHT
    doCLKFunction(9'b000_101_001);
    // FW.KLO (067) Enable KL opcodes
    doCLKFunction(9'b000_110_111);
    // FW.EBL (076) EBUS load
    doCLKFunction(9'b000_111_110);
  endtask


  // FPGA_RESET resets each module separate from CROBAR mostly for
  // simulation since it depends on e.g., decrementing counters whose
  // values are indeterminate to run its startup processes (e.g., CLK
  // and CROBAR and e52Counter).
  logic FPGA_RESET;
  initial begin
    FPGA_RESET = 1;

    #100 FPGA_RESET = 0;
  end

  // CROBAR stays asserted for a long time
  initial begin
    CROBAR = 1;

    // Release system CROBAR reset
    repeat(50) @(posedge masterClk) ;
    CROBAR = 0;
  end
  

  initial begin                 // Smash RESET on for a few clocks
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    top0.ebox0.EBUS.ds = '0;
    top0.ebox0.EBUS.data = '0;
    top0.ebox0.EBUS.diagStrobe = '0;

    @(negedge CROBAR) ;
    repeat(10) @(posedge masterClk) ;

    KLMasterReset();

    // Do (as a front-end would) the CLK diagnostic functions:
    //
    // * FUNC_SET_RESET
    // * FUNC_START
    // * FUNC_CLR_RESET
    //
    // // XXX this needs to change when we have channels. See
    // PARSER.LST .MRCLR function.
    doCLKFunction(3'b001);      // CLK.FUNC_START
  end
  
endmodule

