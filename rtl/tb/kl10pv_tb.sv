`include "ebox.svh"
`include "mbox.svh"

module kl10pv_tb;
  typedef enum logic [0:8] {
                            clkfSTOP_CLOCK = 9'o000,
                            clkfSTART_CLOCK = 9'o001,
                            clkfCLR_CLK_SRC_RATE = 9'o044,

                            clkfSET_RESET = 9'o007,
                            clkfCLR_RESET = 9'o006,

                            clkfRESET_PAR_REGS = 9'o046,
                            clkfCLR_BURST_CTR_RH = 9'o042,
                            clkfCLR_BURST_CTR_LH = 9'o043,
                            clkfCLR_CRAM_DIAG_ADR_RH = 9'o051,
                            clkfCLR_CRAM_DIAG_ADR_LH = 9'o052,

                            clkfENABLE_KL = 9'o067,
                            clkfEBUS_LOAD = 9'o076
                            } tCLKFunction;

  logic CROBAR;
  logic masterClk;
  logic clk;

  top top0(.*);

  var string indent = "";

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


  // Initialization because of ECL
  initial begin
    // EBUS
    top0.ebox0.EBUS.data = '0;
    top0.ebox0.EBUS.parity = '0;
    top0.ebox0.EBUS.cs = '0;
    top0.ebox0.EBUS.ds = '0;
    top0.ebox0.EBUS.func = tEBUSfunction'('0);
    top0.ebox0.EBUS.demand = '0;
    top0.ebox0.EBUS.pi = '0;
    top0.ebox0.EBUS.ack = '0;
    top0.ebox0.EBUS.xfer = '0;
    top0.ebox0.EBUS.reset = '0;
    top0.ebox0.EBUS.diagStrobe = '0;
    top0.ebox0.EBUS.dfunc = '0;

    top0.ebox0.APR.EBUSdriver.driving = '0;
    top0.ebox0.APR.EBUSdriver.data = '0;
    top0.ebox0.CON.EBUSdriver.driving = '0;
    top0.ebox0.CON.EBUSdriver.data = '0;
    top0.ebox0.CRA.EBUSdriver.driving = '0;
    top0.ebox0.CRA.EBUSdriver.data = '0;
    top0.ebox0.CTL.EBUSdriver.driving = '0;
    top0.ebox0.CTL.EBUSdriver.data = '0;
    top0.ebox0.EDP.EBUSdriver.driving = '0;
    top0.ebox0.EDP.EBUSdriver.data = '0;
    top0.ebox0.IR.EBUSdriver.driving = '0;
    top0.ebox0.IR.EBUSdriver.data = '0;
    top0.ebox0.MTR.EBUSdriver.driving = '0;
    top0.ebox0.MTR.EBUSdriver.data = '0;
    top0.ebox0.PI.EBUSdriver.driving = '0;
    top0.ebox0.PI.EBUSdriver.data = '0;
    top0.ebox0.SCD.EBUSdriver.driving = '0;
    top0.ebox0.SCD.EBUSdriver.data = '0;
    top0.ebox0.SHM.EBUSdriver.driving = '0;
    top0.ebox0.SHM.EBUSdriver.data = '0;
    top0.ebox0.VMA.EBUSdriver.driving = '0;
    top0.ebox0.VMA.EBUSdriver.data = '0;

    top0.ebox0.CON.CONO_200000 = '0;
  end


  // XXX until implemented
  initial begin
    top0.ebox0.CON.MBOX_WAIT = '0;
    top0.ebox0.con0.MEM_CYCLE = '0;
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
  
  logic uninitLogic;
  bit uninitBit;

  initial begin
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    $display($time, " uninitLogic=%01b uninitBit=%01b", uninitLogic, uninitBit);
    CROBAR = 1;               // CROBAR stays asserted for a long time
    #1000;                    // 1us CROBAR for the 21st century (and simulations)
    CROBAR = 0;

    #100 KLMasterReset();

    // Do (as a front-end would) the CLK diagnostic functions:
    //
    // * FUNC_SET_RESET
    // * FUNC_START
    // * FUNC_CLR_RESET
    //
    // // XXX this needs to change when we have channels. See
    // PARSER.LST .MRCLR function.
    doCLKFunction(clkfSTART_CLOCK);
  end
  
  ////////////////////////////////////////////////////////////////
  // Request the specified CLK diagnostic function as if we were the
  // front-end setting up a KL10pv.
  task doCLKFunction(input tCLKFunction func);
    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      $display($time, " %sdoCLKFunction(%s) START", indent, func.name);
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;          // DIAG_CTL_FUNC_00x for CLK
      top0.ebox0.EBUS.ds[4:6] = func;
      top0.ebox0.EBUS.diagStrobe = '1;            // Strobe this
    end

    repeat (8) @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;

    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      top0.ebox0.EBUS.diagStrobe = '0;
      top0.ebox0.EBUS.ds[0:3] = 4'b0000;
      top0.ebox0.EBUS.ds[4:6] = 3'b000;
    end

    repeat(4) @(posedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;
    $display($time, " %sDONE", indent);
  endtask


  ////////////////////////////////////////////////////////////////
  // Patterned after PARSER .RESET function and table RESETT.
  task KLMasterReset();
    $display($time, " KLMasterReset() START");
    indent = "    ";
    // Reset the DTE-20
    // D2.RST (100)
    // D3.RST (001)

    // Set and then clear EBOX_RESET (XXX not in .RESET function)
    doCLKFunction(clkfSET_RESET);
    doCLKFunction(clkfCLR_RESET);

    // (000) Stop the KL clock
    doCLKFunction(clkfSTOP_CLOCK);
    // (044) Clear the KL clock source and rate
    doCLKFunction(clkfCLR_CLK_SRC_RATE);
    // FW.IPE (046) Reset the parity registers
    doCLKFunction(clkfRESET_PAR_REGS);
    // Do contents of RESETT table:
    // FW.LBR (042) Clear burst counter RIGHT
    doCLKFunction(clkfCLR_BURST_CTR_RH);
    // FW.LBL (043) Clear burst counter LEFT
    doCLKFunction(clkfCLR_BURST_CTR_LH);
    // FW.CA2 (052) Clear CRAM diag address LEFT
    doCLKFunction(clkfCLR_CRAM_DIAG_ADR_LH);
    // FW.CA1 (051) Clear CRAM diag address RIGHT
    doCLKFunction(clkfCLR_CRAM_DIAG_ADR_RH);
    // FW.KLO (067) Enable KL opcodes
    doCLKFunction(clkfENABLE_KL);
    // FW.EBL (076) EBUS load
    doCLKFunction(clkfEBUS_LOAD);
    $display($time, " DONE");
    indent = "";
  endtask

endmodule

