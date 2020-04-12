`include "ebox.svh"

module kl10pv_tb(iAPR APR,
                 iCCL CCL,
                 iCCW CCW,
                 iCHA CHA,
                 iCHC CHC,
                 iCLK CLK,
                 iCON CON,
                 iCRA CRA,
                 iCRAM CRAM,
                 iCRC CRC,
                 iCRM CRM,
                 iCSH CSH,
                 iCTL CTL,
                 iEDP EDP,
                 iIR IR,
                 iMBC MBC,
                 iMBX MBX,
                 iMBZ MBZ,
                 iMCL MCL,
                 iMTR MTR,
                 iPAG PAG,
                 iPI PIC,
                 iPMA PMA,
                 iSCD SCD,
                 iSHM SHM,
                 iVMA VMA,

                 iEBUS EBUS,
                 iMBOX MBOX,
                 iSBUS SBUS,

                 output bit CROBAR,
                 output bit clk,
                 output bit clk30,
                 output bit clk31,
                 output bit EXTERNAL_CLK,

                 output bit PWR_WARN
                 );
  bit masterClk;

  var string indent = "";

  tCRAM cram137;

  assign clk = masterClk;
  assign EXTERNAL_CLK = masterClk;
  assign clk30 = masterClk;
  assign clk31 = masterClk;     // XXX for now

  // 50MHz clock source
  initial masterClk = 0;
  always #10 masterClk = ~masterClk;

  initial $readmemh("../../../../images/DRAM.mem", ebox0.ir0.dram.mem);
  initial $readmemh("../../../../images/CRAM.mem", ebox0.crm0.cram.mem);

  // Initialization because of ECL
  initial begin
    cram137 = ebox0.crm0.cram.mem['o137];

    // Initialize our memories
    // Based on KLINIT.L20 $ZERAC subroutine.
    // Zero all ACs, including the ones in block #7 (microcode's ACs).
    // For now, MBOX memory is zero too.
    for (int a = 0; a < $size(ebox0.edp0.fm.mem); ++a) ebox0.edp0.fm.mem[a] = '0;
    for (int a = 0; a < $size(memory0.mem0.mem); ++a) memory0.mem0.mem[a] = '0;

    // EBUS
    APR.EBUSdriver.driving <= '0;
    APR.EBUSdriver.data = '0;
    CON.EBUSdriver.driving = '0;
    CON.EBUSdriver.data = '0;
    CRA.EBUSdriver.driving = '0;
    CRA.EBUSdriver.data = '0;
    CTL.EBUSdriver.driving = '0;
    CTL.EBUSdriver.data = '0;
    EDP.EBUSdriver.driving = '0;
    EDP.EBUSdriver.data = '0;
    IR.EBUSdriver.driving = '0;
    IR.EBUSdriver.data = '0;
    MTR.EBUSdriver.driving = '0;
    MTR.EBUSdriver.data = '0;
    PIC.EBUSdriver.driving = '0;
    PIC.EBUSdriver.data = '0;
    SCD.EBUSdriver.driving = '0;
    SCD.EBUSdriver.data = '0;
    SHM.EBUSdriver.driving = '0;
    SHM.EBUSdriver.data = '0;
    VMA.EBUSdriver.driving = '0;
    VMA.EBUSdriver.data = '0;

    CON.CONO_200000 = '0;
  end

  initial begin
    #10 CROBAR = '1;     // CROBAR stays asserted for a long time
    #1000 CROBAR = '0;   // 1us CROBAR for the 21st century (and sims)

    #100 KLMasterReset();

    // Suck out field from microcode in well known address to retrieve
    // microcode edit number.
    #100 KLBootDialog(cram137.MAGIC[0:8], EDP.hwOptions);
  end


  task KLMasterReset;
    $display($time, " KLMasterReset() START");
    indent = "  ";

    // Functions from KLINIT.L20 $KLMR (DO A MASTER RESET ON THE KL)
    
    // $DFXC(.CLRUN=010)    ; Clear run
    doDiagFunc(diagfCLR_RUN);

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
    
    //   .LDSEL(044) Clock load func #044
    //          (use DMRMOS MOS defaults = 0,,10 = EXTERNAL CLOCK, no divider)
    doDiagFunc(diagfCLR_CLK_SRC_RATE, 18'o000010);

    //   .STPCL(EXEFN:000) Stop the clock
    doDiagFunc(diagfSTOP_CLOCK);

    //   .SETMR(EXEFN:007) Set reset
    doDiagFunc(diagfSET_RESET);

    //   .ldck1(046) Load CLK partity check and FS check
    doDiagFunc(diagfRESET_PAR_REGS);

    //   .LDCK2(047) Load CLK MBOX cycle disables, parity check, error stop enable
    doDiagFunc(diagfCLR_MBOXDIS_PARCHK_ERRSTOP);

    //   .LDBRR(042) Load burst counter 8,4,2,1
    doDiagFunc(diagfCLR_BURST_CTR_RH);

    //   .LDBRL(043) Load burst counter 128,64,32,16
    doDiagFunc(diagfCLR_BURST_CTR_LH);

    //   .LDDIS(045) Load EBOX clock disable
    doDiagFunc(diagfSET_EBOX_CLK_DISABLES);

    //   .STRCL(EXEFN:001) Start the clock
    doDiagFunc(diagfSTART_CLOCK);

    //   .INICL(070) Init channels
    doDiagFunc(diagfINIT_CHANNELS);

    //   .LDBRR(042) Load burst counter 8,4,2,1
    doDiagFunc(diagfCLR_BURST_CTR_RH);

    // Loop up to three times:
    //   Do diag function 162 via $DFRD test (A CHANGE COMING A L)=EBUS[32]
    //   If not set, $DFXC(.SSCLK=002) to single step the MBOX
    repeat (5) begin
      #500 ;
      if (!mbox0.mbc0.MBC.A_CHANGE_COMING) break;
      #500 ;
      doDiagFunc(diagfSTEP_CLOCK);
    end

    if (mbox0.mbc0.MBC.A_CHANGE_COMING) begin
      $display($time, " ERROR: STEP of MBOX five times did not clear MBC.A_CHANGE_COMING");
    end

    // Execute second set of functions in DMRMRT:
    //   .CECLK(EXEFN:004) Conditional single step
    doDiagFunc(diagfCOND_STEP);

    //   .CLRMR(EXEFN:006) Clear reset
    doDiagFunc(diagfCLR_RESET);

    //   .EIOJA(067) Enable KL STL decoding of codes and ACs
    doDiagFunc(diagfENABLE_KL);

    //   .MEMRS(076) Set KL10 mem reset flop
    doDiagFunc(diagfEBUS_LOAD);

    //   .WRMBX(071) Write M-BOX to do a memory reset
    doDiagFunc(diagfWRITE_MBOX, 18'o000012);

    $display($time, " DONE");
    indent = "";
  endtask
  

  ////////////////////////////////////////////////////////////////
  task KLBootDialog(input int microcodeEditNumber, input [0:35] hwo);
    // Time to pretend a little...
    $display("");
    $display("KLISIM -- VERSION 0.0.1 RUNNING");
    $display("KLISIM -- KL10 S/N: %0d., MODEL B, %0d HERTZ",
             hwo[23:35], hwo[18] ? 50 : 60);
    $display("KLISIM -- KL10 HARDWARE ENVIRONMENT");
    if (hwo[22]) $display("   MOS MASTER OSCILLATOR");
    if (hwo[21]) $display("   EXTENDED ADDRESSING");
    if (hwo[20]) $display("   INTERNAL CHANNELS");
    if (hwo[19]) $display("   CACHE");
    $display("");
    $display("KLISIM -- MICROCODE VERSION %0o LOADED", microcodeEditNumber);
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

    // Sweep the cache
    // XXX TBD

    // Turn off the NXM bit (FE uses CONO APR,,22000).
    MBOX.NXM_ERR = '0;

    ////////////////////////////////////////////////////////////////
    // Falls through into LXBRC 10$ symbol for end of boot loader
    // file, check for NXM during load, then if all goes well enters
    // $TENST as shown below.
    //
    // Functions from KLINIT.L20 $TENST (START KL BOOT) routine
    // This was done earlier. XXX probably needs to be done again on reset.
    //    for (int a = 0; a < $size(ebox0.edp0.fm.mem); ++a) ebox0.edp0.fm.mem[a] = '0;

    // Execute equivalent of a series of CONO/DATAO instructions to do
    // the following operations.

    ////////////
    // CONO APR,267760                  ; Reset APR and I/O
    begin
      // Clear all IO devices
      // XXX NOTE THIS IS NOT DOING ANYTHING RIGHT NOW

      // Clear/disable selected flags
      // SBUS error, NXM, IO page fail
      MBOX.SBUS_ERR = '0;
      ebox0.apr0.SBUS_ERR_EN = '0;
      MBOX.NXM_ERR = '0;
      ebox0.apr0.NXM_ERR_EN = '0;
      APR.SET_IO_PF_ERR = '0;
      ebox0.apr0.IO_PF_ERR_EN = '0;
      
      // MB parity, cache dir, addr parity
      MBOX.MB_PAR_ERR = '0;
      ebox0.apr0.MB_PAR_ERR_EN = '0;
      MBOX.CSH_ADR_PAR_ERR = '0;
      ebox0.apr0.C_DIR_P_ERR_EN = '0;
      ebox0.apr0.MBOX.ADR_PAR_ERR = '0;
      ebox0.apr0.S_ADR_P_ERR_EN = '0;

      // power fail, sweep done
      PWR_WARN = '0;
      ebox0.apr0.PWR_FAIL = '0;
      APR.SWEEP_BUSY = '0;
      ebox0.apr0.SWEEP_DONE_EN = '0;

      // PI interrupt level #0
      ebox0.pi0.PIC.APR_PIA = '0;
    end
    
    ////////////
    // CONO PI,10000            ; Reset PI
    begin
      ebox0.pi0.ON = '0;
      ebox0.pi0.GEN = '0;
      ebox0.pi0.PIR_EN = '0;
      ebox0.pi0.PI_REQ_SET = '0;
      ebox0.pi0.PIH = '0;
      ebox0.pi0.ACTIVE = '0;
    end

    ////////////
    // CONO PAG, 0              ; Paging system clear
    begin
      CON.CACHE_LOOK_EN = '0;
      CON.CACHE_LOAD_EN = '0;
      ebox0.con0.WR_EVEN_PAR_DATA = '0;
      ebox0.con0.WR_EVEN_PAR_DIR = '0;
    end

    ////////////
    // DATAO PAG, 0             ; User base clear
    begin
      // Set current and previous AC blocks to zero.
      APR.CURRENT_BLOCK = '0;
      APR.PREV_BLOCK = '0;
      APR.CURRENT_BLOCK = '0;
      APR.CURRENT_BLOCK = '0;
      
      // Set current section context to zero.
      // XXX Not 100% certain this is what this is supposed to do. 
      VMA.PREV_SEC = '0;

      // Load UPT page number with zero.
      // XXX Not 100% certain this is what this is supposed to do. 
      mbox0.pma0.UBR = '0;

      // Invalidate the entire page table by setting the invalid bits in all lines.
      /*      Sim already does this by initializing entire RAM to zeros.
       for (int a = 0; a < $size(mbox0.pag0.ptDirA); ++a) begin
       mbox0.pag0.ptDirA[a] = '0;
       mbox0.pag0.ptDirB[a] = '0;
       mbox0.pag0.ptDirC[a] = '0;
       mbox0.pag0.ptParity[a] = '0;
       end
       */
      // XXX For now, we do not turn on the cache. Here is where it
      // should be enabled if we want it.
      // Set $SETCA (CONFIGURE CACHE) routine in KLINIT.L20 for details on how.
    end

    //////////////////
    // Here is where FE looks at .KLISV to detrmine which bits AC0 should get:
    // - 1b0 for no boot prompting
    // - 1b1 for dump KL

    // (047) Load clock MBOX cycle disables, parity check, error stop enable (.LDCK2)
    // FE loads 3 and calls .LDCK2
    doDiagFunc(diagfCLR_MBOXDIS_PARCHK_ERRSTOP, 4'b0011);

    // (046) Load clock parity check and FS check (.LDCK1)
    // FE loads 0o16 (#FM!CM!DM) and calls .LDCK1
    doDiagFunc(diagfRESET_PAR_REGS, 4'b1110);

    // Start clocks (.STRCL=001)
    doDiagFunc(diagfSTART_CLOCK);

    //////////////////////////////////////////////////////////////////
    // Functions from $STRKL (START THE KL PROCESSOR)
    //
    // THIS IS DONE BY LOADING THE AR WITH THE ADDRESS, PUSHING
    // THE RUN AND CONTINUE BUTTONS, AND STARTING THE CLOCK.
    // WE STEP THE MICROCODE OUT OF THE HALT LOOP TO MAKE SURE IT
    // IS RUNNING BEFORE WE LEAVE.
    //
    // XXX for now boot address is wrongly set to zero.
    EDP.AR = {14'b0, 22'b0};

    // Set the RUN flop.
    doDiagFunc(diagfSET_RUN);
    if (!CON.RUN) begin
      $display($time, " diagfSET_RUN should set the RUN flop and it didn't");
    end

    // Set the CONTINUE button.
    doDiagFunc(diagfCONTINUE);

    // Single step the MBOX clock up to 1000 times waiting for
    // microcode to exit from the HALT loop.

    repeat (1000) begin
      doDiagFunc(diagfSTEP_CLOCK);
      if (!CON.EBOX_HALTED) break;
    end

    if (CON.EBOX_HALTED) begin
      $display($time, " ERROR: STEP MBOX < 1000 times waiting for HALT loop didn't clear CON.EBOX_HALTED");
    end

    // Verify RUN flop is still set.
    if (!CON.RUN) begin
      $display($time, " ???ERROR: STEP MBOX < 1000 times waiting for HALT loop cleared the RUN flop???");
    end

    // Start the clock.
    doDiagFunc(diagfSTART_CLOCK);

    $display($time, " DONE");
    indent = "";
  endtask


  ////////////////////////////////////////////////////////////////
  // Request the specified CLK diagnostic function as if we were the
  // front-end setting up a KL10pv.
  task doDiagFunc(input tDiagFunction func,
                  input [18:35] ebusRH = '0);
    @(negedge CLK.MHZ16_FREE) begin
      string shortName;
      shortName = replace(func.name, "diagf", "");
      EBUS.data[18:35] <= ebusRH;
      EBUS.ds <= func;
      EBUS.diagStrobe <= '1;            // Strobe this
      $display($time, " %sEBUS.data=0,,%0o and ds=%s", indent, ebusRH, shortName);
    end

    repeat (8) @(negedge CLK.MHZ16_FREE) ;

    @(negedge CLK.MHZ16_FREE) begin
      EBUS.data[18:35] <= '0;
      EBUS.diagStrobe <= '0;
      EBUS.ds <= tDiagFunction'('0);
    end

    repeat(4) @(posedge CLK.MHZ16_FREE) ;
//    $display($time, " %s[done]", indent);
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
