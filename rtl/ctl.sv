// XXX need to review this against schematics
`timescale 1ns/1ns
`include "ebox.svh"

// M8543 CTL
module ctl(iAPR APR,
           iCLK CLK,
           iCON CON,
           iCTL CTL,
           iCRAM CRAM,
           iEDP EDP,
           iMBOX MBOX,
           iMCL MCL,
           iPI PIC,
           iSHM SHM,

           iEBUS.mod EBUS
);

  bit CTL_36_BIT_EA;
  bit RESET;
  bit SPEC_MTR_CTL;

  // p.364: Decode all the things.
  // Dispatches
  assign CTL.DISP_AREAD = CRAM.DISP == dispDRAM_A_RD;
  assign CTL.DISP_RETURN = CRAM.DISP == dispRETURN;
  assign CTL.DISP_NICOND = CRAM.DISP == dispNICOND;
  assign CTL.DISP_MUL = CRAM.DISP == dispMUL;
  assign CTL.DISP_DIV = CRAM.DISP == dispDIV;
  assign CTL.DISP_NORM = CRAM.DISP == dispNORM;
  assign CTL.DISP_EA_MOD = CRAM.DISP == dispEA_MOD;
  
  // Special functions
  assign CTL.SPEC_INH_CRY_18 = CRAM.SPEC == specINH_CRY18;
  assign CTL.SPEC_MQ_SHIFT = CRAM.SPEC == specMQ_SHIFT;
  assign CTL.SPEC_SCM_ALT = CRAM.SPEC == specSCM_ALT;
  assign CTL.SPEC_CLR_FPD = CRAM.SPEC == specCLR_FPD;
  assign CTL.SPEC_LOAD_PC = CRAM.SPEC == specLOAD_PC;
  assign CTL.SPEC_XCRY_AR0 = CRAM.SPEC == specXCRY_AR0;
  assign CTL.SPEC_GEN_CRY_18 = CRAM.SPEC == specGEN_CRY18;
  assign CTL.SPEC_STACK_UPDATE = CRAM.SPEC == specSTACK_UPDATE;
  assign CTL.SPEC_ARL_IND = CRAM.SPEC == specARL_IND;
  assign CTL.SPEC_FLAG_CTL = CRAM.SPEC == specFLAG_CTL;
  assign CTL.SPEC_SAVE_FLAGS = CRAM.SPEC == specSAVE_FLAGS;
  assign CTL.SPEC_SP_MEM_CYCLE = CRAM.SPEC == specSP_MEM_CYCLE;
  assign CTL.SPEC_AD_LONG = CRAM.SPEC == specAD_LONG;

  // This one is internal because of reclock with APR_CLK below.
  assign SPEC_MTR_CTL = CRAM.SPEC == specMTR_CTL;

  // EBUS
  assign CTL.EBUSdriver.driving = CTL.DIAG_READ;

  always_comb unique case ({CTL.DIAG_READ, CTL.DIAG[4:6]})
              default: CTL.EBUSdriver.data[24:28] = 0;
              4'b1000: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_SCM_ALT,
                                                     CTL.SPEC_SAVE_FLAGS,
                                                     CTL.ARL_SEL[1],
                                                     CTL.ARR_LOAD,
                                                     CTL.AR00to08_LOAD};
              4'b1001: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_CLR_FPD,
                                                     CTL.SPEC_MTR_CTL,
                                                     CTL.ARL_SEL[0],
                                                     CTL.ARR_LOAD,
                                                     CTL.AR09to17_LOAD};
              4'b1010: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_GEN_CRY_18,
                                                     CTL.COND_AR_EXP,
                                                     CTL.ARR_SEL[1],
                                                     CTL.MQM_SEL[1],
                                                     CTL.ARX_LOAD};
              4'b1011: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_STACK_UPDATE,
                                                     CTL.DISP_RET,
                                                     CTL.ARR_SEL[0],
                                                     CTL.MQM_SEL[0],
                                                     CTL.ARL_SEL[2]};
              4'b1100: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_FLAG_CTL,
                                                     CTL.LOAD_PC,
                                                     CTL.ARXL_SEL[1],
                                                     CTL.MQ_SEL[1],
                                                     CTL.AR00to11_CLR};
              4'b1101: CTL.EBUSdriver.data[24:28] = {CTL.SPEC_SP_MEM_CYCLE,
                                                     CTL.SPEC_ADX_CRY_36,
                                                     CTL.ARXL_SEL[0],
                                                     CTL.MQ_SEL[0],
                                                     CTL.AR12to17_CLR};
              4'b1110: CTL.EBUSdriver.data[24:28] = {CTL.AD_LONG,
                                                     CTL.ADX_CRY_36,
                                                     CTL.ARXR_SEL[1],
                                                     CTL.MQM_EN,
                                                     CTL.ARR_CLR};
              4'b1111: CTL.EBUSdriver.data[24:28] = {CTL.INH_CRY_18,
                                                     MBOX.DIAG_MEM_RESET,
                                                     CTL.ARXR_SEL[0],
                                                     CTL.DIAG_LD_EBUS_REG,
                                                     CTL.SPEC_CALL};
              endcase
  
  // Miscellaneous control signals CTL1
  assign CTL.PI_CYCLE_SAVE_FLAGS = CON.PCplus1_INH & CTL.SPEC_SAVE_FLAGS;
  // This is "CRAM.AD & adCARRY" term is actually shown on CTL1
  // E8 pins 5 and 7 as CRAM AD CRY. I'm just guessing this is
  // what they mean since I don't have backplane wiring.
  assign CTL.ADX_CRY_36 = ~CTL.PI_CYCLE_SAVE_FLAGS &&
                          ((CRAM.AD & `adCARRY) !== 0) ^ (EDP.AR[0] & CTL.SPEC_XCRY_AR0);

  assign CTL.REG_CTL[0:2] = CRAM.MAGIC[0:2] & CTL.COND_REG_CTL;
  assign CTL.COND_AR_EXP = CRAM.MAGIC[5] & CTL.COND_REG_CTL;
  assign CTL.REG_CTL[7:8] = CRAM.MAGIC[7:8] & CTL.COND_REG_CTL;

  bit e12q15;
  assign e12q15 = ((~APR.CLK & e12q15) | ((CTL.SPEC_LOAD_PC | CTL.DISP_NICOND) & ~CLK.SBR_CALL));
  assign CTL.LOAD_PC = ~CON.PI_CYCLE & e12q15;

  assign CTL.GEN_CRY_18 = (CTL.SPEC_GEN_CRY_18 | CTL.SPEC_STACK_UPDATE) &
                          (CTL.SPEC_GEN_CRY_18 | MCL.SHORT_STACK);

  assign CTL.DISP_EN = CRAM.DISP[0:1];

  assign RESET = CLK.MR_RESET;

  assign CTL.AD_LONG = CTL.DISP_MUL |
                       CTL.DISP_DIV |
                       CTL.DISP_NORM |
                       CTL.SPEC_AD_LONG |
                       CTL.SPEC_MQ_SHIFT;

  assign CTL.DISP_RET = ~(~CLK.SBR_CALL | ~CTL.DISP_RETURN);
  assign CTL.SPEC_MTR_CTL = SPEC_MTR_CTL & APR.CLK;


  // CTL2 p.365
  bit load1;
  bit d2, d3;
  bit shortEA;
  bit FMandAR_LOAD;
  bit FMandARX_LOAD;
  bit diagLoadARorInd;
  bit diagLoadARorARM;
  bit respMBOXorSIM;
  bit resetOrREG_CTLorMQ_CLR;
  bit mathOrREG_CTLorMQ_CLR;

  assign CTL.ARR_LOAD = ~(CTL.REG_CTL[2] | |{CRAM.AR[2],
                                             CTL.ARR_SEL[1],
                                             CTL.ARR_SEL[0],
                                             CTL.ARR_CLR,
                                             CTL.COND_ARR_LOAD});
  assign load1 = |{CTL.AR00to11_CLR, CTL.ARL_SEL};
  assign CTL.AR09to17_LOAD = CTL.COND_ARLR_LOAD | CTL.REG_CTL[1] | load1;
  assign CTL.AR00to08_LOAD = CTL.COND_ARLL_LOAD | CTL.REG_CTL[0] | load1 |
                             CRAM.MAGIC[0] & CTL.ARL_IND;

  assign CTL.MQ_CLR = CTL.ARL_IND ? CRAM.MAGIC[2] : 0;
  assign CTL.ARX_CLR = CTL.ARL_IND ? CRAM.MAGIC[3] : CTL.COND_ARX_CLR;
  assign d2 = CTL.ARL_IND ? CRAM.MAGIC[4] : CTL.COND_AR_CLR;
  assign d3 = CTL.ARL_IND ? CRAM.MAGIC[5] : CTL.COND_AR_CLR;
  assign shortEA = CTL.DISP_EA_MOD & EDP.ARX[18];
  assign CTL.AR12to17_CLR = RESET | MCL._18_BIT_EA | d2 | shortEA;
  assign CTL.AR00to11_CLR = CTL.AR12to17_CLR | MCL._23_BIT_EA;

  assign CTL.SPEC_CALL = ~(CLK.SBR_CALL | (CTL.ARL_IND ? CRAM.MAGIC[0] : CTL.SPEC_SBR_CALL));
  assign CTL.ARL_SEL[2] = CTL.ARL_IND ? CRAM.MAGIC[6] : CRAM.AR[2];
  assign CTL.ARL_SEL[1] = CTL.ARL_IND ? CRAM.MAGIC[7] : CRAM.AR[1];
  assign CTL.ARL_IND_SEL[0] = CTL.ARL_IND ? CRAM.MAGIC[8] : CRAM.AR[0];

  assign FMandAR_LOAD = CON.FM_XFER & MCL.LOAD_AR;
  assign CTL.ARL_SEL[1] = CTL.ARL_IND_SEL[1] | CTL_36_BIT_EA | CTL.DIAG_AR_LOAD | FMandAR_LOAD;
  assign CTL.ARR_SEL[1] = CRAM.AR[1] | CTL.DISP_AREAD | CTL.DIAG_AR_LOAD | FMandAR_LOAD;

  assign FMandARX_LOAD = CON.FM_XFER & MCL.LOAD_ARX;
  assign CTL.ARXL_SEL[1] = CRAM.ARX[1] | FMandARX_LOAD;
  assign CTL.ARXR_SEL[1] = CTL.ARXL_SEL[1];

  assign CTL.ARX_LOAD = CRAM.ARX[0] | CTL.ARXR_SEL[1] | CTL.ARXR_SEL[2] | CTL.ARX_CLR | RESET;

  assign CTL.ARL_IND = MCL.MEM_ARL_IND | CTL.SPEC_ARL_IND | CTL.COND_ARL_IND;

  assign CTL.EBUS_XFER = CRAM.AR[0] & APR.CONO_OR_DATAO & ~(CRAM.AR[1] & CRAM.AR[2]);
  assign CTL_36_BIT_EA = CTL.DISP_AREAD & CTL.AR00to11_CLR;

  assign CTL.COND_ARLL_LOAD = CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b001);
  assign CTL.COND_ARLR_LOAD = CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b010);
  assign CTL.COND_ARR_LOAD =  CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b011);
  assign CTL.COND_AR_CLR =    CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b100);
  assign CTL.COND_ARX_CLR =   CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b101);
  assign CTL.COND_ARL_IND =   CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b110);
  assign CTL.COND_REG_CTL =   CON.COND_EN_00_07 & (CRAM.COND[3:5] == 3'b111);

  assign respMBOXorSIM = CLK.RESP_MBOX | CLK.RESP_SIM;
  assign diagLoadARorInd = CTL.ARL_IND | CTL.DIAG_AR_LOAD;
  assign diagLoadARorARM = CRAM.AR[2] | CTL.DIAG_AR_LOAD;
  assign CTL.ARL_SEL[0] = (MCL.LOAD_AR | diagLoadARorInd) & (diagLoadARorInd | respMBOXorSIM);
  assign CTL.ARR_SEL[0] = (MCL.LOAD_AR | diagLoadARorARM) & (diagLoadARorARM | respMBOXorSIM);
  assign CTL.ARXL_SEL[0] = (MCL.LOAD_ARX | CRAM.ARX[2]) & (CRAM.ARX[2] | respMBOXorSIM);
  assign CTL.ARXR_SEL[0] = CTL.ARXL_SEL[0];

  assign resetOrREG_CTLorMQ_CLR = RESET | CTL.REG_CTL[7] | CTL.MQ_CLR;
  assign mathOrREG_CTLorMQ_CLR = CTL.MQ_CLR | CTL.REG_CTL[8] | CTL.SPEC_MQ_SHIFT |
                                 CTL.DISP_MUL | CTL.DISP_DIV;
  assign CTL.MQM_EN = CRAM.MQ | RESET;
  assign CTL.MQM_SEL[1] = CTL.MQM_EN & resetOrREG_CTLorMQ_CLR;
  assign CTL.MQM_SEL[0] = CTL.MQM_EN & mathOrREG_CTLorMQ_CLR;
  assign CTL.MQ_SEL[1] = ~CTL.MQM_EN & resetOrREG_CTLorMQ_CLR;
  assign CTL.MQ_SEL[0] = ~CTL.MQM_EN & mathOrREG_CTLorMQ_CLR;


  // CTL3 p.366
  bit NOTds00AndDiagStrobe;
  bit en1xx;
  assign CTL.DIAG_READ = EDP.DIAG_READ_FUNC_10x;
  assign CTL.DIAG_STROBE = EBUS.diagStrobe;
  assign NOTds00AndDiagStrobe = ~EBUS.ds[0] & CTL.DIAG_STROBE;
  assign CTL.DIAG_CTL_FUNC_00x  = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b000;
  assign CTL.DIAG_CTL_FUNC_01x  = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b001;
  assign CTL.DIAG_LD_FUNC_04x   = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b100;
  assign CTL.DIAG_LOAD_FUNC_05x = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b101;
  assign CTL.DIAG_LOAD_FUNC_06x = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b110;
  assign CTL.DIAG_LOAD_FUNC_07x = NOTds00AndDiagStrobe && EBUS.ds[1:3] == 3'b111;

  assign CTL.DIAG_LOAD_FUNC_070 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b000;
  assign CTL.DIAG_LOAD_FUNC_071 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b001;
  assign CTL.DIAG_LOAD_FUNC_072 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b010;
  assign CTL.DIAG_LD_FUNC_073   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b011;
  assign CTL.DIAG_LD_FUNC_074   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b100;
  assign CTL.DIAG_SYNC_FUNC_075 = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b101;
  assign CTL.DIAG_LD_FUNC_076   = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b110;
  assign CTL.DIAG_CLK_EDP       = CTL.DIAG_LOAD_FUNC_07x && EBUS.ds[4:6] == 3'b111;

  assign en1xx = CTL.DIAG[0] & CTL.READ_STROBE;
  assign EDP.DIAG_READ_FUNC_10x = en1xx && CTL.DIAG[1:3] == 3'b000;
  assign CTL.DIAG_READ_FUNC_11x = en1xx && CTL.DIAG[1:3] == 3'b001;
  assign CTL.DIAG_READ_FUNC_12x = en1xx && CTL.DIAG[1:3] == 3'b010;
  assign CTL.DIAG_READ_FUNC_13x = en1xx && CTL.DIAG[1:3] == 3'b011;
  assign CTL.DIAG_READ_FUNC_14x = en1xx && CTL.DIAG[1:3] == 3'b100;
  assign CTL.DIAG_READ_FUNC_15x = en1xx && CTL.DIAG[1:3] == 3'b101;
  assign CTL.DIAG_READ_FUNC_16x = en1xx && CTL.DIAG[1:3] == 3'b110;
  assign CTL.DIAG_READ_FUNC_17x = en1xx && CTL.DIAG[1:3] == 3'b111;

  assign CTL.READ_STROBE = CTL.CONSOLE_CONTROL ?
                           CTL.DIAG_STROBE :
                           CON.COND_DIAG_FUNC & ~APR.CLK;

    // These next three lines are causing some concern. CTL.DIAG[4:6]
    // is the backplane signal used in most EBOX modules to drive EBUS
    // operations.
  assign CTL.CONSOLE_CONTROL = EBUS.ds[0] | EBUS.ds[1];
  assign CTL.DS = CTL.CONSOLE_CONTROL ? EBUS.ds : CRAM.MAGIC[2:8];
  assign CTL.DIAG = CTL.DS[4:6];

  assign CTL.AD_TO_EBUS_L = CTL.CONSOLE_CONTROL &
                            (APR.CONO_OR_DATAO |
                             (CON.COND_DIAG_FUNC |
                              CRAM.MAGIC[2] |
                              APR.CLK));
  assign CTL.AD_TO_EBUS_R = CTL.AD_TO_EBUS_L;

  assign CTL.DIAG_AR_LOAD = CTL.DIAG[0] & &EBUS.ds[1:3] & &CTL.DIAG[4:6];

  assign CTL.EBUS_T_TO_E_EN = (PIC.GATE_TTL_TO_ECL | APR.CONI_OR_DATAI) &
                              CTL.CONSOLE_CONTROL | EBUS.ds[0] & CTL.CONSOLE_CONTROL;
  assign CTL.EBUS_E_TO_T_EN = APR.EBUS_RETURN & CTL.EBUS_T_TO_E_EN |
                              CTL.CONSOLE_CONTROL & CTL.EBUS_T_TO_E_EN;
  assign CTL.EBUS_PARITY_OUT = SHM.AR_PAR_ODD | CTL.AD_TO_EBUS_L;

  always_ff @(posedge CTL.DIAG_LD_FUNC_076) begin
    MBOX.DIAG_MEM_RESET <= EBUS.data[24];
    CTL.DIAG_CHANNEL_CLK_STOP <= EBUS.data[25];
    CTL.DIAG_LD_EBUS_REG <= EBUS.data[26];
    CTL.DIAG_FORCE_EXTEND <= EBUS.data[27];
    CTL.DIAG[4] <= EBUS.data[28];
  end
endmodule // ctl
