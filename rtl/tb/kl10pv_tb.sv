`include "ebox.svh"

module kl10pv_tb;
  typedef enum bit [0:7] {
                          diagfCLR_BURST_CTR_RH = 8'o042,
                          diagfCLR_BURST_CTR_LH = 8'o043,
                          diagfCLR_CLK_SRC_RATE = 8'o044,
                          diagfSET_EBOX_CLK_DISABLES = 8'o045,
                          diagfRESET_PAR_REGS = 8'o046,
                          diagfCLR_MBOXDIS_PARCHK_ERRSTOP = 8'o047,

                          diagfCLR_CRAM_DIAG_ADR_RH = 8'o051,
                          diagfCLR_CRAM_DIAG_ADR_LH = 8'o052,

                          diagfENABLE_KL = 8'o067,

                          diagfINIT_CHANNELS = 8'o070,
                          diagfWRITE_MBOX = 8'o071,
                          diagfEBUS_LOAD = 8'o076
                          } tDiagFunction;

  typedef enum bit [0:7] {
                          dte20fSTOP_CLOCK = 8'o000,
                          dte20fSTART_CLOCK = 8'o001,
                          dte20fSTEP_CLOCK = 8'o002,
                          dte20fCOND_STEP = 8'o004,

                          dte20fCLR_RESET = 8'o006,
                          dte20fSET_RESET = 8'o007,

                          dte20fCLR_RUN = 8'o010
                          } tDTE20Function;

  // APRID hardware options
  const bit hw50Hz = 1'b0;
  const bit hwCache = 1'b1;
  const bit hwInternalChannels = 1'b1;
  const bit hwExtendedKL = 1'b1;
  const bit hwMasterOscillator = 1'b1;
  const bit [23:35] serialNumber = 4001;

  bit CROBAR;
  bit masterClk;
  bit clk;

  top top0(.*);

  var string indent = "";

  assign clk = masterClk;

  // 50MHz clock source
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  initial $readmemh("../../../../images/DRAM.mem", top0.ebox0.ir0.dram.mem);
  initial $readmemh("../../../../images/CRAM.mem", top0.ebox0.crm0.cram.mem);

  // Initialization because of ECL
  initial begin
    // Initialize our memories
    // Based on KLINIT.L20 $ZERAC subroutine.
    // Zero all ACs, including the ones in block #7 (microcode's ACs).
    // For now, MBOX memory is zero too.
    for (int a = 0; a < $size(top0.ebox0.edp0.fm.mem); ++a) top0.ebox0.edp0.fm.mem[a] = '0;
    for (int a = 0; a < $size(top0.memory0.mem0.mem); ++a) top0.memory0.mem0.mem[a] = '0;

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

    top.ebox0.MBOX.DIAG_MEM_RESET = '0;
    top.ebox0.CTL.DIAG_CHANNEL_CLK_STOP = '0;
    top.ebox0.CTL.DIAG_LD_EBUS_REG = '0;
    top.ebox0.CTL.DIAG_FORCE_EXTEND = '0;

    top.ebox0.CRM.PAR_16 = '0;
  end
  
  initial begin
    // Suck out fields from microcode in well known addresses to
    // retrieve microcode version.
    tCRAM cram136 = tCRAM'(top0.ebox0.crm0.cram.mem['o136]);
    tCRAM cram137 = tCRAM'(top0.ebox0.crm0.cram.mem['o137]);
    int microcodeMajorVersion = cram136.MAGIC[0:5];
    int microcodeMinorVersion = cram136.MAGIC[6:8];
    int microcodeEditNumber = cram137.MAGIC[0:8];

    // Define available hardware options and processor serial number
    top0.ebox0.edp0.HardwareOptionsWord = {
                                           18'b0, // Upper half is microcode's domain
                                           hw50Hz,
                                           hwCache,
                                           hwInternalChannels,
                                           hwExtendedKL,
                                           hwMasterOscillator,
                                           13'(serialNumber)
                                           };

    CROBAR = 1;               // CROBAR stays asserted for a long time
    #1000;                    // 1us CROBAR for the 21st century (and sims)
    CROBAR = 0;

    $display($time, " CRAM[0]=%028o", top0.ebox0.crm0.cram.mem[0]);
    #100 KLMasterReset();

    #100 KLBootDialog(microcodeMajorVersion, microcodeMinorVersion, microcodeEditNumber);
  end
  

  ////////////////////////////////////////////////////////////////
  // Request the specified CLK diagnostic function as if we were the
  // front-end setting up a KL10pv.
  task doDiagFunc(input tDiagFunction func,
                  input string name = func.name,
                  input [18:35] ebusRH = '0);
    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      string shortName;
      shortName = replace(name, "diagf", "");
      shortName = replace(shortName, "dte20f", "");
      $display($time, " %sEBUS=%06o %s", indent, ebusRH, shortName);
      top0.ebox0.EBUS.data[18:35] = ebusRH;
      top0.ebox0.EBUS.ds = func;
      top0.ebox0.EBUS.diagStrobe = '1;            // Strobe this
    end

    repeat (8) @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;

    @(negedge top0.ebox0.clk0.CLK.MHZ16_FREE) begin
      top0.ebox0.EBUS.diagStrobe = '0;
      top0.ebox0.EBUS.ds = '0;  // Idle
    end

    repeat(4) @(posedge top0.ebox0.clk0.CLK.MHZ16_FREE) ;
    $display($time, " %s[done]", indent);
  endtask


  // XXX For now, I think this is just the same as doDiagFunc.
  task doDTE20Func(input tDTE20Function func, input [18:35] ebusRH = '0);
    doDiagFunc(tDiagFunction'(func), func.name, ebusRH);
  endtask


  ////////////////////////////////////////////////////////////////
  // Patterned after PARSER .RESET function and table RESETT.
  task KLMasterReset();
    $display($time, " KLMasterReset() START");
    indent = "  ";
    // Functions from KLINIT.L20 $KLMR (DO A MASTER RESET ON THE KL)
    
    // $DFXC(.CLRUN=010)    ; Clear run
    doDTE20Func(dte20fCLR_RUN);

    // $DTRW2(DRESET=100)   ; Reset bit to .DTEDT via DTE-20 diag 2
    // With no DTE20, resetting the DTE is not very useful.
    // XXX TODO

    // $DTRWS(DON10C|ERR10C|INT11C|PERCLR|DON11C|ERR11C)        ; Clear DTE-20 status
    // With no DTE20, resetting the DTE error flags is not very useful.
    // XXX TODO

    // The codes below are either WRITE (no annotation) or EXECUTE
    // FUNCTIONS (EXEFN). The former is a simple diagnostic write. The
    // latter uses the equivalent of KLINIT.L20 $DFXC which is more
    // complex than a simple write and does some special things based
    // on which operation it is asked to perform.
    //
    // Execute first block of functions in DMRMRT:

    //         (072) Select KW20/22 (external clock oscillator) for MOS systems
    // Not necessary in this implementation
    
    //   .LDSEL(044) Clock load func #44
    //          (use DMRMOS MOS defaults = 0,,10 = EXTERNAL CLOCK, no divider)
    doDiagFunc(.func(diagfCLR_CLK_SRC_RATE), .ebusRH(18'o000010));

    //   .STPCL(EXEFN:000) Stop the clock
    doDTE20Func(dte20fSTOP_CLOCK);

    //   .SETMR(EXEFN:007) Set reset
    doDTE20Func(dte20fSET_RESET);

    //   .LDCK1(046) Load CLK partity check and FS check
    doDiagFunc(diagfRESET_PAR_REGS);

    //   .LDCK2(047) Load CLK MBOX cycle disables, parity check, error stop enable
    doDiagFunc(diagfCLR_MBOXDIS_PARCHK_ERRSTOP);

    //   .LDBRR(042) Load burst counter 8,4,2,1
    doDiagFunc(diagfCLR_BURST_CTR_RH);

    //   .LDBRL(043) Load burst counter 128.64,32,16
    doDiagFunc(diagfCLR_BURST_CTR_LH);

    //   .LDDIS(045) Load EBOX clock disable
    doDiagFunc(diagfSET_EBOX_CLK_DISABLES);

    //   .STRCL(EXEFN:001) Start the clock
    doDTE20Func(dte20fSTART_CLOCK);

    //   .INICL(070) Init channels
    doDiagFunc(diagfINIT_CHANNELS);

    //   .LDBRR(042) Load burst counter 8,4,2,1
    doDiagFunc(diagfCLR_BURST_CTR_RH);

    // Loop up to three times:
    //   Do diag function 162 via $DFRD test (A CHANGE COMING A L)=EBUS[32]
    //   If not set, $DFXC(.SSCLK=002) to single step the MBOX
    repeat (5) begin
      #500 ;
      if (!top0.mbox0.mbc0.MBC.A_CHANGE_COMING) break;
      #500 ;
      doDTE20Func(dte20fSTEP_CLOCK);
    end

    if (top0.mbox0.mbc0.MBC.A_CHANGE_COMING) begin
      $display($time, " ERROR: STEP of MBOX five times did not clear MBC.A_CHANGE_COMING");
    end

    // Execute second set of functions in DMRMRT:
    //   .CECLK(EXEFN:004) Conditional single step
    doDTE20Func(dte20fCOND_STEP);

    //   .CLRMR(EXEFN:006) Clear reset
    doDTE20Func(dte20fCLR_RESET);

    //   .EIOJA(067) Enable KL STL decoding of codes and ACs
    doDiagFunc(diagfENABLE_KL);

    //   .MEMRS(076) Set KL10 mem reset flop
    doDiagFunc(diagfEBUS_LOAD);

    //   .WRMBX(071) Write M-BOX to do a memory reset
    doDiagFunc(.func(diagfWRITE_MBOX), .ebusRH(18'o000012));

    $display($time, " DONE");
    indent = "";
  endtask


  task KLBootDialog(input int microcodeMajorVersion,
                    input int microcodeMinorVersion,
                    input int microcodeEditNumber);

    // Time to pretend a little...
    $display("");
    $display("KLISIM -- VERSION 0.0.1 RUNNING");
    $display("KLISIM -- KL10 S/N: %d., MODEL B, %2d HERTZ",
             serialNumber, hw50Hz ? 50 : 60);
    $display("KLISIM -- KL10 HARDWARE ENVIRONMENT");
    if (hwMasterOscillator) $display("   MOS MASTER OSCILLATOR");
    if (hwExtendedKL)       $display("   EXTENDED ADDRESSING");
    if (hwInternalChannels) $display("   INTERNAL CHANNELS");
    if (hwCache)            $display("   CACHE");
    $display("");
    $display("KLISIM -- MICROCODE VERSION %03o LOADED", microcodeEditNumber);
    $display("");

    $display($time, " KLBootDialog() START");
    indent = "  ";
    // XXX TODO

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
    // This was done earlier. XXX probably needs to be done again on reset.
//    for (int a = 0; a < $size(top0.ebox0.edp0.fm.mem); ++a) top0.ebox0.edp0.fm.mem[a] = '0;

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
    top0.PWR_WARN = '0;
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
    top0.ebox0.con0.WR_EVEN_PAR_DATA = '0;
    top0.ebox0.con0.WR_EVEN_PAR_DIR = '0;

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
    top0.mbox0.pma0.UBR = '0;

    // Invalidate the entire page table by setting the invalid bits in all lines.
/*      Sim already does this by initializing entire RAM to zeros.
    for (int a = 0; a < $size(top0.mbox0.pag0.ptDirA); ++a) begin
      top0.mbox0.pag0.ptDirA[a] = '0;
      top0.mbox0.pag0.ptDirB[a] = '0;
      top0.mbox0.pag0.ptDirC[a] = '0;
      top0.mbox0.pag0.ptParity[a] = '0;
    end
*/
    // XXX For now, we do not turn on the cache. Here is where it
    // should be enabled if we want it.
    // Set $SETCA (CONFIGURE CACHE) routine in KLINIT.L20 for details on how.

    //////////////////
    // Here is where AC0 should get:
    // - 1b0 for no boot prompting
    // - 1b1 for dump KL

    // (046) Load clock parity check and FS check (.LDCK1)
    doDiagFunc(diagfCLR_MBOXDIS_PARCHK_ERRSTOP);

    // (047) Load clock MBOX cycle disables, parity check, error stop enable (.LDCK2)
    doDiagFunc(diagfCLR_MBOXDIS_PARCHK_ERRSTOP);

    // Do contents of RESETT table:

    // FW.CA2 (052) Clear CRAM diag address LEFT
    doDiagFunc(diagfCLR_CRAM_DIAG_ADR_LH);

    // FW.CA1 (051) Clear CRAM diag address RIGHT
    doDiagFunc(diagfCLR_CRAM_DIAG_ADR_RH);

    $display($time, " DONE");
    indent = "";
  endtask


  // From https://stackoverflow.com/questions/27970151/string-search-and-replace-in-systemverilog
  function automatic string replace(string original, string old, string replacement);
    // First find the index of the old string
    int start_index = 0;
    int original_index = 0;
    int replace_index = 0;
    bit found = 0;

    while(1) begin
      if (original[original_index] == old[replace_index]) begin
        if (replace_index == 0) begin
          start_index = original_index;
        end
        replace_index++;
        original_index++;
        if (replace_index == old.len()) begin
          found = 1;
          break;
        end
      end else if (replace_index != 0) begin
        replace_index = 0;
        original_index = start_index + 1;
      end else begin
        original_index++;
      end
      if (original_index == original.len()) begin
        // Not found
        break;
      end
    end

    if (!found) return original;

    return {
            original.substr(0, start_index-1),
            replacement,
            original.substr(start_index+old.len(), original.len()-1)
            };

  endfunction  

endmodule
