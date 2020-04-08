`include "ebox.svh"

module kl10pv_tb;
  typedef enum bit [0:8] {
                          clkfSTOP_CLOCK = 9'o000,
                          clkfSTART_CLOCK = 9'o001,

                          clkfSET_RESET = 9'o007,
                          clkfCLR_RESET = 9'o006,

                          clkfCLR_CLK_SRC_RATE = 9'o044,
                          clkfCLR_BURST_CTR_RH = 9'o042,
                          clkfCLR_BURST_CTR_LH = 9'o043,
                          clkfRESET_PAR_REGS = 9'o046,
                          clkfCLR_MBOXDIS_PARCHK_ERRSTOP = 9'o047,

                          clkfCLR_CRAM_DIAG_ADR_RH = 9'o051,
                          clkfCLR_CRAM_DIAG_ADR_LH = 9'o052,

                          clkfENABLE_KL = 9'o067,

                          clkfEBUS_LOAD = 9'o076
                          } tCLKFunction;

  bit CROBAR;
  bit masterClk;
  bit clk;

  top top0(.*);

  var string indent = "";

  assign clk = masterClk;

  // 50MHz EBOX clock
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  // Initialize our memories
  zeroAllACs();

  initial begin                 // For now, MBOX memory is zero too
    for (int a = 0; a < $size(top0.memory0.mem0.mem); ++a)
      top0.memory0.mem0.mem[a] = '0;
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
    top0.ebox0.PIC.EBUSdriver.driving = '0;
    top0.ebox0.PIC.EBUSdriver.data = '0;
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
    top.ebox0.MBOX.DIAG_MEM_RESET = '0;
    top.ebox0.CTL.DIAG_CHANNEL_CLK_STOP = '0;
    top.ebox0.CTL.DIAG_LD_EBUS_REG = '0;
    top.ebox0.CTL.DIAG_FORCE_EXTEND = '0;
  end

  initial begin
    top.ebox0.CRM.PAR_16 = '0;
  end
  
  bit uninitLogic;
  bit uninitBit;

  initial begin
    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    $display($time, " uninitLogic=%01b uninitBit=%01b", uninitLogic, uninitBit);
    CROBAR = 1;               // CROBAR stays asserted for a long time
    #1000;                    // 1us CROBAR for the 21st century (and simulations)
    CROBAR = 0;

    // Define available hardware options and processor serial number
    top0.ebox0.edp0.HardwareOptionsWord = {
                                           18'b0, // Upper half is microcode's domain
                                           1'b0, // 50Hz
                                           1'b1, // Cache
                                           1'b1, // Channel
                                           1'b1, // Extended KL10
                                           1'b0, // Master oscillator
                                           13'd4001 // (made up) processor serial number
                                           };

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
  

  // Based on KLINIT.L20 $ZERAC subroutine.
  // Zero all ACs, including the ones in block #7 (microcode's ACs).
  task zeroAllACs();

    for (int a = 0; a < $size(top0.ebox0.edp0.fm.mem); ++a)
      top0.ebox0.edp0.fm.mem[a] = '0;
  endtask
  

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

    // Functions from KLINIT.L20 $KLMR (DO A MASTER RESET ON THE KL)
    // $DFXC(.CLRUN)    ; Clear run
    // $DTRW2(DRESET=0o100)   ; Reset bit to .DTEDT via DTE-20 diag 2
    // $DTRWS(DON10C|ERR10C|INT11C|PERCLR|DON11C|ERR11C)        ; Clear DTE-20 status
    // Execute first block of functions in DMRMRT:
    //         (072) Select KW20/22 for MOS systems
    //   .LDSEL(044) Clock load func #44
    //          (use DMRMOS MOS defaults = 0,,10 = EXTERNAL CLOCK, no divider)
    //   .STPCL(000) Stop the clock
    //   .SETMR(007) Set reset
    //   .LDCK1(046) Load CLK partity check and FS check
    //   .LDCK2(047) Load CLK MBOX cycle disables, parity check, error stop enable
    //   .LDBRR(042) Load burst counter 8,4,2,1
    //   .LDBRL(043) Load burst counter 128.64,32,16
    //   .LDDIS(045) Load EBOX clock disable
    //   .STRCL(001) Start the clock
    //   .INICL(070) Init channels
    //   .LDBRR(042) Load burst counter 8,4,2,1
    // Loop up to three times:
    //   Do diag function 162 via $DFRD test bit #10 (A CHANGE COMING A L)=EBUS[32]
    //   If not set, $DFXC(.SSCLK) to single step the MBOX
    // Execute second set of functions in DMRMRT:
    //   .CECLK(004) Conditional single step
    //   .CLRMR(006) Clear reset
    //   .EIOJA(067) Enable KL STL decoding of codes and ACs
    //   .MEMRS(076) Set KL10 mem reset flop
    //   .WRMBX(071) Write M-BOX


    // Functions from KLINIT.L20 $DLGEN (ASK IF ENTERING DIALOG IS REQUIRED)
    // (starting at 71:)
    // HLTNOE   ; Halt the KL and disable -20F interruptions
    //   ..DTSP ; Turn off 20F interrupts and turn off protocols
    //   $DFXC(.CLRUN)  ; Halt the KL if running
    // LQSCSW   ; Sweep the cache
    //   do BLKO CCA,0  ; Sweep each cache block
    //   $DFXC(.CONBT)  ; Push the CONTINUE button
    //   $DFXC(.STRCL)  ; Start KL clocks
    // LQSHDW   ; Determine the hardware features of the KL
    //   LQSHWO ; Get RH(APRID) through a very sick hack
    // LQSCHO   ; Make sure no conflicting HW options (not needed here)

    // fall through into $CFGBT
    // Test for presence of cache and configure it.

    // Functions from KLINIT.L20 $EXBLD (LOAD THE BOOT) routine


    // Functions from KLINIT.L20 $TENST (START KL BOOT) routine
    zeroAllACs();

    // Execute equivalent of a series of CONO/DATAO instructions to do
    // the following operations.

    ////////////
    // CONO APR,267760                  ; Reset APR and I/O

    // Clear all IO devices
    // XXX NOTE THIS IS NOT DOING ANYTHING RIGHT NOW

    // Clear/disable selected flags
    // SBUS error, NXM, IO page fail
    top0.ebox0.apr0.MBOX.SBUS_ERR = '0;
    top0.ebox0.apr0.SBUS_ERR_EN = '0;
    top0.ebox0.apr0.MBOX.NXM_ERR = '0;
    top0.ebox0.apr0.NXM_ERR_EN = '0;
    top0.ebox0.apr0.APR.SET_IO_PF_ERR = '0;
    top0.ebox0.apr0.IO_PF_ERR_EN = '0;
    
    // MB parity, cache dir, addr parity
    top0.ebox0.apr0.MBOX.MB_PAR_ERR = '0;
    top0.ebox0.apr0.MB_PAR_ERR_EN = '0;
    top0.ebox0.apr0.MBOX.CSH_ADR_PAR_ERR = '0;
    top0.ebox0.apr0.C_DIR_P_ERR_EN = '0;
    top0.ebox0.apr0.MBOX.ADR_PAR_ERR = '0;
    top0.ebox0.apr0.S_ADR_P_ERR_EN = '0;

    // power fail, sweep done
    top0.ebox0.apr0.PWR_WARN = '0;
    top0.ebox0.apr0.PWR_FAIL = '0;
    top0.ebox0.apr0.APR.SWEEP_BUSY = '0;
    top0.ebox0.apr0.SWEEP_DONE_EN = '0;

    // PI interrupt level #0
    top0.ebox0.pi0.PIC.APR_PIA = '0;
    
    ////////////
    // CONO PI,10000            ; Reset PI
    top0.ebox0.pi0.ON = '0;
    top0.ebox0.pi0.GEN = '0;
    top0.ebox0.pi0.PIR_EN = '0;
    top0.ebox0.pi0.PI_REQ_SET = '0;
    top0.ebox0.pi0.PIH = '0;
    top0.ebox0.pi0.ACTIVE = '0;

    ////////////
    // CONO PAG, 0              ; Paging system clear
    top0.ebox0.con0.CON.CACHE_LOOK_EN = '0;
    top0.ebox0.con0.CON.CACHE_LOAD_EN = '0;
    top0.ebox0.con0.CON.WR_EVEN_PAR_DATA = '0;
    top0.ebox0.con0.CON.WR_EVEN_PAR_DIR = '0;

    ////////////
    // DATAO PAG, 0             ; User base clear

    // Set current and previous AC blocks to zero.
    top0.ebox0.apr0.APR.CURRENT_BLOCK = '0;
    top0.ebox0.apr0.APR.PREV_BLOCK = '0;
    top0.ebox0.apr0.APR.CURRENT_BLOCK = '0;
    top0.ebox0.apr0.APR.CURRENT_BLOCK = '0;
    
    // Set current section context to zero.
    // XXX Not 100% certain this is what this is supposed to do. 
    top0.ebox0.vma0.VMA.PREV_SEC = '0;

    // Load UPT page number with zero.
    // XXX Not 100% certain this is what this is supposed to do. 
    top0.ebox0.pma0.UBR = '0;

    // Invalidate the entire page table by setting the invalid bits in all lines.
    for (int a = 0; a < $size(top0.ebox0.pag0.ptDirA); ++a) begin
      top0.ebox0.pag0.ptDirA[a] = '0;
      top0.ebox0.pag0.ptDirB[a] = '0;
      top0.ebox0.pag0.ptDirC[a] = '0;
      top0.ebox0.pag0.ptParity[a] = '0;
    end

    // XXX For now, we do not turn on the cache. Here is where it
    // should be enabled if we want it.
    // Set $SETCA (CONFIGURE CACHE) routine in KLINIT.L20 for details on how.

    //////////////////
    // Here is where AC0 should get:
    // - 1b0 for no boot prompting
    // - 1b1 for dump KL

    // (044) Clear the KL clock source and rate (.LDSEL)
    doCLKFunction(clkfCLR_CLK_SRC_RATE);

    // (000) Stop the KL clock STPCLK (.STPCL)
    doCLKFunction(clkfSTOP_CLOCK);

    // (007) Set master reset SETMR (.SETMR)
    doCLKFunction(clkfSET_RESET);

    // FW.IPE (046) Reset the parity registers (.LDCK1)
    doCLKFunction(clkfRESET_PAR_REGS);

    // (047) Load clock MBOX cycle disables, parity check, error stop enable (.LDCK1)
    doCLKFunction(clkfCLR_MBOXDIS_PARCHK_ERRSTOP);

    // (047) Load clock MBOX cycle disables, parity check, error stop enable (.LDCK1)
    doCLKFunction(clkfCLR_MBOXDIS_PARCHK_ERRSTOP);

    // (047) Load clock MBOX cycle disables, parity check, error stop enable (.LDCK1)
    doCLKFunction(clkfCLR_MBOXDIS_PARCHK_ERRSTOP);

    // Do contents of RESETT table:
    // FW.LBR (042) Clear burst counter RIGHT
    doCLKFunction(clkfCLR_BURST_CTR_RH);

    // FW.LBL (043) Clear burst counter LEFT
    doCLKFunction(clkfCLR_BURST_CTR_LH);

    // FW.CA2 (052) Clear CRAM diag address LEFT
    doCLKFunction(clkfCLR_CRAM_DIAG_ADR_LH);

    // FW.CA1 (051) Clear CRAM diag address RIGHT
    doCLKFunction(clkfCLR_CRAM_DIAG_ADR_RH);

`ifdef notdef
    // FW.KLO (067) Enable KL opcodes
    doCLKFunction(clkfENABLE_KL);
    // FW.EBL (076) EBUS load
    doCLKFunction(clkfEBUS_LOAD);
`endif

    $display($time, " DONE");
    indent = "";
  endtask

endmodule
