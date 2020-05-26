`ifndef _EBOX_SVH_
 `define _EBOX_SVH_ 1

// Universal shift register function selector values
typedef enum bit [0:1] {usrLOAD, usrSHL, usrSHR, usrHOLD} tUSRfunc;


///////////////////////////////////////////////////////////////
// EBUS
typedef enum bit [0:2] {
                ebusfCONO = 3'b000,
                ebusfCONI = 3'b001,
                ebusfDATAO = 3'b010,
                ebusfDATAI = 3'b011,
                ebusfPIserved = 3'b100,
                ebusfPIaddrIn = 3'b101
                } tEBUSfunction;


// EBUS.ds diagnostic functions driven by the DTE20.
typedef enum bit [0:6] {
                        diagfSTOP_CLOCK = 7'o000,
                        diagfSTART_CLOCK = 7'o001,
                        diagfSTEP_CLOCK = 7'o002,
                        diagfCOND_STEP = 7'o004,
                        diagfBURST = 7'o005,

                        diagfCLR_RESET = 7'o006,
                        diagfSET_RESET = 7'o007,
                        diagfCLR_RUN = 7'o010,
                        diagfSET_RUN = 7'o011,
                        diagfCONTINUE = 7'o012,

                        diagfCLR_BURST_CTR_RH = 7'o042,
                        diagfCLR_BURST_CTR_LH = 7'o043,
                        diagfCLR_CLK_SRC_RATE = 7'o044,
                        diagfSET_EBOX_CLK_DISABLES = 7'o045,
                        diagfRESET_PAR_REGS = 7'o046,
                        diagfCLR_MBOXDIS_PARCHK_ERRSTOP = 7'o047,

                        diagfCLR_CRAM_DIAG_ADR_RH = 7'o051,
                        diagfCLR_CRAM_DIAG_ADR_LH = 7'o052,

                        diagfENABLE_KL = 7'o067,

                        diagfINIT_CHANNELS = 7'o070,
                        diagfWRITE_MBOX = 7'o071,
                        diagfEBUS_LOAD = 7'o076,

                        diagfIdle = 7'o077
                        } tDiagFunction;


// Each driver of EBUS gets its own instance of this. These are all
// muxed onto the iEBUS.data member based on the one-hot
// tEBUSdriver.driving indicator.
typedef struct packed{
  bit [0:35] data;
  bit driving;
} tEBUSdriver;

interface iEBUS;
  bit [0:35] data;            // Driven by EBUS mux
  bit parity;                 // Parity for what exactly? XXX
  bit [0:6] cs;               // EBOX -> dev Controller select
  tEBUSfunction func;           // EBOX -> dev Function
  bit demand;                 // EBOX -> dev
  bit [0:7] pi;               // Dev -> EBOX Priority Interrupt
  bit ack;                    // Dev -> EBOX acknowledge
  bit xfer;                   // Dev -> EBOX transfer done
  bit reset;                  // EBOX -> dev
  tDiagFunction ds;           // DTE -> EBOX Diagnostic Select
  bit diagStrobe;             // DTE -> EBOX Diagnostic strobe
  bit dfunc;                  // Dev -> EBOX Diagnostic function


  modport dev(inout data,
              inout parity,
              input cs,
              input func,
              input demand,
              output pi,
              output ack,
              output xfer,
              input reset,
              input ds,
              input diagStrobe,
              input dfunc
              );

  modport dte(inout data,
              input parity,
              input cs,
              input func,
              input demand,
              input pi,
              input ack,
              input xfer,
              input reset,
              output ds,
              output diagStrobe,
              input dfunc
              );

  modport mod(input data,
              output parity,
              output cs,
              output func,
              output demand,
              input pi,
              input ack,
              input xfer,
              output reset,
              input ds,
              input diagStrobe,
              input dfunc
              );
endinterface


////////////////////////////////////////////////////////////////
// CRAM

typedef bit [0:10] tCRADR;

// CRAM_AD flag bits
 `define adCARRY 6'b100_000
 `define adBOOLEAN 6'b010_000

// CRAM_AD values
typedef enum bit [0:5] {
                        // ADDER LOGICAL FUNCTIONS
                        adSETCA =`adBOOLEAN | 6'b000_000,
                        adORC =`adBOOLEAN | 6'b000_001,      // NAND
                        adORCA =`adBOOLEAN | 6'b000_010,
                        adONES =`adBOOLEAN | 6'b000_011,
                        adNOR =`adBOOLEAN | 6'b000_100,
                        //      adANDC =`adBOOLEAN | adNOR,
                        adSETCB =`adBOOLEAN | 6'b000_101,
                        adEQV =`adBOOLEAN | 6'b000_110,
                        adORCB =`adBOOLEAN | 6'b000_111,
                        adANDCA =`adBOOLEAN | 6'b001_000,
                        adXOR =`adBOOLEAN | 6'b001_001,
                        adB =`adBOOLEAN | 6'b001_010,
                        adOR =`adBOOLEAN | 6'b001_011,
                        adZEROS =`adBOOLEAN | 6'b001_100,
                        adANDCB =`adBOOLEAN | 6'b001_101,
                        adAND =`adBOOLEAN | 6'b001_110,
                        adA =`adBOOLEAN | 6'b001_111,
                        // ADDER ARITHMETIC FUNCTIONS
                        adAplus1 =`adCARRY | 6'b000_000,
                        adAplusXCRY = 6'b000_000,
                        adAplusANDCB = 6'b000_001,
                        adAplusAND = 6'b000_010,
                        adA__2 = 6'b000_011,
                        adA__2plus1 =`adCARRY | adA__2,
                        adORplus1 =`adCARRY | 6'b000_100,
                        adORplusANDCB = 6'b000_101,
                        adAplusB = 6'b000_110,
                        adAplusBplus1 =`adCARRY | adAplusB,
                        adAplusOR = 6'b000_111,
                        adORCBplus1 =`adCARRY | adORCB,
                        adAminusBminus1 = 6'b001_001,
                        adAminusB =`adCARRY | adAminusBminus1,
                        adANDplusORCB =`adCARRY | 6'b001_010,
                        adAplusORCB =`adCARRY | 6'b001_011,
                        adXCRYminus1 =`adCARRY | 6'b001_100,
                        adANDCBminus1 = 6'b001_101,
                        adANDminus1 = 6'b001_110,
                        adAminus1 = 6'b001_111,
                        // BOOLEAN FUNCTIONS FOR WHICH CRY0 IS INTERESTING
                        adCRY_A_EQ_minus1 =`adCARRY |`adBOOLEAN | 6'b000_000,
                        adCRY_A_GE_B =`adCARRY |`adBOOLEAN | 6'b001_001
                        } tAD;

typedef enum bit [0:2] {
	                adaAR = 3'b000,
	                adaARX = 3'b001,
	                adaMQ = 3'b010,
	                adaPC = 3'b011,
                        adaZEROS = 3'b100
                        } tADA;

typedef enum bit [0:1] {
                        adbFM = 2'b00,
                        adbBRx2 = 2'b01,
                        adbBR = 2'b10,
                        adbARx4 = 2'b11
                        } tADB;

typedef enum bit [0:2] {
                        arAR = 3'b000, // also arARMM, arMEM
                        arCACHE = 3'b001,
                        arAD = 3'b010,
                        arEBUS = 3'b011,
                        arSH = 3'b100,
                        arADx2 = 3'b101,
                        arADX = 3'b110,
                        arADdiv4 = 3'b111
                        } tAR;

typedef enum bit [0:2] {
                        arxARX = 3'b000, // Also MEM
                        arxCACHE = 3'b001,
                        arxAD = 3'b010,
                        arxMQ = 3'b011,
                        arxSH = 3'b100,
                        arxADXx2 = 3'b101,
                        arxADX = 3'b110,
                        arxADXdiv4 = 3'b111
                        } tARX;

typedef enum bit {
                  brRECIRC = 1'b0,
                  brAR = 1'b1
                  } tBR;

typedef enum bit {
                  brxRECIRC = 1'b0,
                  brxARX = 1'b1
                  } tBRX;

typedef enum bit {
                  mqRECIRC = 1'b0,
                  mqSH = 1'b1
                  } tMQ;

typedef enum bit [0:2] {
                        fmadrAC0 = 3'b000,
                        fmadrAC1 = 3'b001,
                        fmadrXR = 3'b010,
                        fmadrVMA = 3'b011,
                        fmadrAC2 = 3'b100,
                        fmadrAC3 = 3'b101,
                        fmadrACplusMAGIC = 3'b110,
                        fmadrMAGIC = 3'b111
                        } tFMADR;

typedef enum bit [0:2] {
                        scadA = 3'b000,
                        scadAminusBminus1 = 3'b001,
                        scadAplusB = 3'b010,
                        scadAminus1 = 3'b011,
                        scadAplus1 = 3'b100,
                        scadAminusB = 3'b101,
                        scadOR = 3'b110,
                        scadAND = 3'b111
                        } tSCAD;

typedef enum bit [0:2] {
                        scadaFE = 3'b000,
                        scadaAR0_5 = 3'b001,
                        scadaAR_EXP = 3'b010,
                        scadaMAGIC = 3'b011,
                        scadaZEROS = 3'b100
                        } tSCADA;

typedef enum bit [0:1] {
                        scadbSC = 2'b00,
                        scadbAR6_11 = 2'b01,
                        scadbAR0_8 = 2'b10,
                        scadbMAGIC = 2'b11
                        } tSCADB;

typedef enum bit {
                  scRECIRC = 1'b0,
                  scSCAD = 1'b1
                  } tSC;

typedef enum bit {
                  feRECIRC = 1'b0,
                  feSCAD = 1'b1
                  } tFE;


typedef enum bit [0:1] {
                        shSHIFT_AR_ARX = 2'b00,
                        shAR = 2'b01,
                        shARX = 2'b10,
                        shAR_SWAP = 2'b11
                        } tSH;

typedef enum bit [0:1] {
                        armmMAGIC = 2'b00,
                        armmEXP_SIGN = 2'b01,
                        armmSCAD_EXP = 2'b10,
                        armmSCAD_POS = 2'b11
                        } tARMM;

typedef enum bit [0:1] {
                        vmaxVMAX = 2'b00,
                        vmaxPC_SEC = 2'b01,
                        vmaxPREV_SEC = 2'b10,
                        vmaxAD12_17 = 2'b11
                        } tVMAX;


typedef enum bit [0:1] {
                        vmaVMA = 2'b00,
                        vmaPC = 2'b01,
                        vmaPCplus1 = 2'b10,
                        vmaAD = 2'b11
                        } tVMA;

typedef enum bit [0:1] {
                        time2T = 2'b00,
                        time3T = 2'b01,
                        time4T = 2'b10,
                        time5T = 2'b11
                        } tTIME;

typedef enum bit [0:3] {
                        memNOP = 4'b0000,
                        memARL_IND = 4'b0001,
                        memMB_WAIT = 4'b0010,
                        memRESTORE_VMA = 4'b0011,
                        memA_RD = 4'b0100,
                        memB_WRITE = 4'b0101,
                        memFETCH = 4'b0110,
                        memREG_FUNC = 4'b0111,
                        memAD_FUNC = 4'b1000,
                        memEA_CALC = 4'b1001,
                        memLOAD_AR = 4'b1010,
                        memLOAD_ARX = 4'b1011,
                        memRW = 4'b1100,
                        memRPW = 4'b1101,
                        memWRITE = 4'b1110,
                        memIFET = 4'b1111
                        } tMEM;

typedef enum bit [0:5] {
                        skipNOP = 6'b000_000,
                        skipEVEN_PAR = 6'b100_001,
                        skipBR0 = 6'b100_010,
                        skipARX0 = 6'b100_011,
                        skipAR18 = 6'b100_100,
                        skipAR0 = 6'b100_101,
                        skipACne0 = 6'b100_110,
                        skipSC0 = 6'b100_111,

                        skipPC_SEC0 = 6'b101_000,
                        skipSCAD0 = 6'b101_001,
                        skipSCADne0 = 6'b101_010,
                        skipADX0 = 6'b101_011,
                        skipAD_CRY0 = 6'b101_100,
                        skipAD0 = 6'b101_101,
                        skipADne0 = 6'b101_110,
                        skipNotLOCAL_AC_ADDR = 6'b101_111,

                        skipFETCH = 6'b110_000,
                        skipKERNEL = 6'b110_001,
                        skipUSER = 6'b110_010,
                        skipPUBLIC = 6'b110_011,
                        skipRPW_REF = 6'b110_100,
                        skipPI_CYCLE = 6'b110_101,
                        skipNotEBUS_GRANT = 6'b110_110,
                        skipNotEBUS_XFER = 6'b110_111,

                        skipINTRPT = 6'b111_000,
                        skipNotSTART = 6'b111_001,
                        skipRUN = 6'b111_010,
                        skipIO_LEGAL = 6'b111_011,
                        skipPorSXCT = 6'b111_100,
                        skipNotVMA_SEC0 = 6'b111_101,
                        skipAC_REF = 6'b111_110,
                        skipNotMTR_REQ = 6'b111_111
                        } tSKIP;

typedef enum bit [0:5] {
                        condNOP = 6'b000_000,
                        condLD_AR0_8 = 6'b000_001,
                        condLD_AR9_17 = 6'b000_010,
                        condLD_AR18_35 = 6'b000_011,
                        condAR_CLR = 6'b000_100,
                        condARX_CLR = 6'b000_101,
                        condARX_IND = 6'b000_110,
                        condREG_CTL = 6'b000_111,

                        condFM_WRITE = 6'b001_000,
                        condPCF_MAGIC = 6'b001_001,
                        condFE_SHRT = 6'b001_010,
                        condAD_FLAGS = 6'b001_011,
                        condLOAD_IR = 6'b001_100,
                        condSPEC_INSTR = 6'b001_101,
                        condSRfromMAGIC = 6'b001_110,
                        condSEL_VMA = 6'b001_111,

                        condDIAG_FUNC = 6'b010_000,
                        condEBOX_STATE = 6'b010_001,
                        condEBUS_CTL = 6'b010_010,
                        condMBOX_CTL = 6'b010_011,

                        condLONG_EN = 6'b010_101,

                        condVMAfromMAGIC = 6'b011_000,
                        condVMAfromMAGICplusTRAP = 6'b011_001,
                        condVMAfromMAGICplusMODE = 6'b011_010,
                        condVMAfromMAGICplusAR32_35 = 6'b011_011,
                        condVMAfromMAGICplusPIx2 = 6'b011_100,
                        condVMA_DEC = 6'b011_101,
                        condVMA_INC = 6'b011_110,
                        condLD_VMA_HELD = 6'b011_111
                        } tCOND;


typedef enum bit [0:4] {
                        dispDIAG = 5'b00_000,
                        dispDRAM_J = 5'b00_001,
                        dispDRAM_A_RD = 5'b00_010,
                        dispRETURN = 5'b00_011,
                        dispPG_FAIL = 5'b00_100,
                        dispSR = 5'b00_101,
                        dispNICOND = 5'b00_110,
                        dispSH0_3 = 5'b00_111,

                        dispMUL = 5'b11_000,
                        dispDIV = 5'b11_001,
                        dispSIGNS = 5'b11_010,
                        dispDRAM_B = 5'b11_011,
                        dispBYTE = 5'b11_100,
                        dispNORM = 5'b11_101,
                        dispEA_MOD = 5'b11_110
                        } tDISP;

typedef enum bit [0:4] {
                        specNOP = 5'b01_000,
                        specINH_CRY18 = 5'b01_001,
                        specMQ_SHIFT = 5'b01_010,
                        specSCM_ALT = 5'b01_011,
                        specCLR_FPD = 5'b01_100,
                        specLOAD_PC = 5'b01_101,
                        specXCRY_AR0 = 5'b01_110,
                        specGEN_CRY18 = 5'b01_111,

                        specSTACK_UPDATE = 5'b10_000,
                        specARL_IND = 5'b10_010,
                        specMTR_CTL = 5'b10_011,
                        specFLAG_CTL = 5'b10_100,
                        specSAVE_FLAGS = 5'b10_101,
                        specSP_MEM_CYCLE = 5'b10_110,
                        specAD_LONG = 5'b10_111
                        } tSPEC;


typedef enum bit [0:2] {
                        acbPAGB = 3'b110,
                        acbMICROB = 3'b111
                        } tACB;

typedef enum bit [0:5] {
                        acopACplusMAGIC = 6'b000_110,
                        acopMAGIC = 6'b011_010,
                        acopOR_ACnumber = 6'b011_011
                        } tAC_OP;


typedef enum bit [0:3] {
                        clrNOP = 4'b0_000,
                        clrARR = 4'b0_001,
                        clrARL = 4'b0_010,
                        clrAR = 4'b0_011,
                        clrARX = 4'b0_100,
                        clrARLplusARX = 4'b0_110,
                        clrARplusARX = 4'b0_111,

                        clrMQ = 4'b1_000,
                        clrARRplusMQ = 4'b1_001,
                        clrARplusMQ = 4'b1_011,
                        clrARXplusMQ = 4'b1_100,
                        clrARLplusARXlusMQ = 4'b1_110,
                        clrARplusARXplusMQ = 4'b1_111
                        } tCLR;

typedef enum bit [0:2] {
                        arlARL = 3'b000,
                        arlCACHE = 3'b001,
                        arlAD = 3'b010,
                        arlEBUS = 3'b011,
                        arlSH = 3'b100,
                        arlADx2 = 3'b101,
                        arlADX = 3'b110,
                        arlADdiv4 = 3'b111
                        } tARL;

typedef enum bit [0:2] {
                        arctlNOP = 3'b000,
                        arctlARR_LOAD = 3'b001,
                        arctlAR9_17 = 3'b010,
                        arctlAR0_8 = 3'b100,
                        arctlARL_LOAD = 3'b110
                        } tAR_CTL;

typedef enum bit [0:1] {
                        mqctlMQ = 2'b00,
                        mqctlMQx2 = 2'b01,
                        mqctlMQdiv2 = 2'b10,
                        mqctlZEROS = 2'b11
                        } tMQ_CTL;

typedef enum bit [0:8] {
                        pcflagsNONE = 9'b000_000_000,
                        pcflagsOVERF = 9'b100_000_000,
                        pcflagsFLOVERF = 9'b010_000_000,
                        pcflagsFPD = 9'b001_000_000,
                        pcflagsTRAP2 = 9'b000_100_000,
                        pcflagsTRAP1 = 9'b000_010_000,
                        pcflagsEXPUND = 9'b000_001_000,
                        pcflagsNO_DIV = 9'b000_000_100,
                        pcflagsAROV = 9'b100_010_000,
                        pcflagsFLOV = 9'b110_010_000,
                        pcflagsFXU = 9'b110_011_000,
                        pcflagsDIV_CHK = 9'b100_010_100,
                        pcflagsFDV_CHK = 9'b110_010_100
                        } tPC_FLAGS;

typedef enum bit [0:8] {
                        flagctlNOP = 9'b000_000_000,
                        flagctlRSTR_FLAGS = 9'b100_010_000,
                        flagctlJFCL = 9'b110_000_010,
                        flagctlJFCLplusLD = 9'b110_010_010,
                        flagctlDISMISS = 9'b100_000_010,
                        flagctlDISMISSplusLD = 9'b101_010_010,
                        flagctlHALT = 9'b100_100_010,
                        flagctlSET_FLAGS = 9'b000_000_010,
                        flagctlPORTAL = 9'b100_001_010
                        } tFLAG_CTL;

typedef enum bit [0:8] {
                        specinstrSET_PI_CYCLE = 9'b111_001_100,
                        specinstrKERNEL_CYCLE = 9'b010_000_000,
                        specinstrINH_PCplus1 = 9'b001_000_000,
                        specinstrSXCT = 9'b000_100_000,
                        specinstrPXCT = 9'b000_010_000,
                        specinstrINTRPT_INH = 9'b000_001_000,
                        specinstrINSTR_ABORT = 9'b000_000_100,
                        specinstrHALTED = 9'b011_000_010,
                        specinstrCONS_XCT = 9'b011_001_000,
                        specinstrCONT = 9'b000_000_000
                        } tSPEC_INSTR;

typedef enum bit [0:8] {
                        fetchUNCOND = 9'b100_000_000,
                        fetchCOMP = 9'b010_000_000,
                        fetchSKIP = 9'b010_000_010,
                        fetchTEST = 9'b010_000_011,
                        fetchJUMP = 9'b101_000_010,
                        fetchJFCL = 9'b101_000_011
                        } tFETCH;

typedef enum bit [0:8] {
                        eacalcLOAD_AR = 9'b100_000_000,
                        eacalcLOAD_ARX = 9'b010_000_000,
                        eacalcPAUSE = 9'b001_000_000,
                        eacalcWRITE = 9'b000_100_000,
                        eacalcPREV_EN = 9'b000_010_000,
                        eacalcINDIRECT = 9'b000_001_000,
                        eacalcEA = 9'b000_000_010,
                        eacalcSTACK = 9'b000_000_001,
                        eacalcA_IND = 9'b010_011_000,
                        eacalcBYTE_LD = 9'b100_010_000,
                        eacalcBYTE_RD = 9'b110_010_000,
                        eacalcBYTE_RD_PCorPOP_AR_ARX = 9'b110_010_001,
                        eacalcBYTE_RPW = 9'b111_110_000,
                        eacalcBYTE_IND = 9'b110_001_000,
                        eacalcPUSH = 9'b000_100_001,
                        eacalcPOP_AR = 9'b100_010_001,
                        eacalcPOP_ARX = 9'b010_010_001,
                        eacalcWRITE_E = 9'b000_100_010,
                        eacalcWRITE_EA = 9'b100_000_010,
                        eacalcLD_AR_EA = 9'b100_100_010,
                        eacalcLD_ARplusWR = 9'b100_100_000,
                        eacalcLD_ARXplusWR = 9'b010_100_000
                        } tEA_CALC;


typedef enum bit [0:8] {
                        spmemFETCH = 9'b100_000_000,
                        spmemUSER = 9'b010_000_000,
                        spmemEXEC = 9'b001_000_000,
                        spmemSEC_0 = 9'b000_100_000,
                        spmemUPT_EN = 9'b000_010_000,
                        spmemEPT_EN = 9'b000_001_000,
                        spmemCACHE_INC = 9'b000_000_010,
                        spmemUNCSHplusUNPAGE = 9'b001_000_011,
                        spmemUNPAGEDplusCACHED = 9'b001_000_001,
                        spmemEPT = 9'b001_001_011,
                        spmemEPT_CACHE = 9'b001_001_001,
                        spmemEPT_FETCH = 9'b101_001_011,
                        spmemUPT = 9'b010_010_011,
                        spmemUPT_FETCH = 9'b110_010_011,
                        spmemPT = 9'b000_011_011,
                        spmemPT_FETCH = 9'b100_100_011
                        } tSP_MEM;

typedef enum bit [0:8] {
                        mregfncSBUS_DIAG = 9'b100_000_111,
                        mregfncREAD_UBR = 9'b101_000_010,
                        mregfncREAD_EBR = 9'b101_000_011,
                        mregfncREAD_ERA = 9'b101_000_100,
                        mregfncWR_REFILL_RAM = 9'b101_000_101,
                        mregfncLOAD_CCA = 9'b110_000_110,
                        mregfncLOAD_UBR = 9'b110_000_010,
                        mregfncLOAD_EBR = 9'b110_000_011,
                        mregfncMAP = 9'b001_100_000
                        } tMREG_FNC;

typedef enum bit [0:8] {
                        mboxctlSET_PAGE_FAIL = 9'b010_000_000,
                        mboxctlSET_IO_PF_ERR = 9'b001_000_000,
                        mboxctlCLR_PT_LINE_NK = 9'b000_110_001,
                        mboxctlPT_DIR_CLR_NK = 9'b000_100_001,
                        mboxctlCLR_PT_LINE = 9'b000_011_001,
                        mboxctlPT_DIR_WR = 9'b000_010_000,
                        mboxctlPT_WR = 9'b000_001_000,
                        mboxctlPT_DIR_CLR = 9'b000_000_001,
                        mboxctlNORMAL = 9'b000_000_000
                        } tMBOX_CTL;

typedef enum bit [0:2] {
                        mtrctlCLR_TIME = 3'b000,
                        mtrctlCLR_PERF = 3'b001,
                        mtrctlCLR_E_CNT = 3'b010,
                        mtrctlCLR_M_CNT = 3'b011,
                        mtrctlLD_PA_LH = 3'b100,
                        mtrctlLD_PA_RH = 3'b101,
                        mtrctlCONO_MTR = 3'b110,
                        mtrctlCONO_TIM = 3'b111
                        } tMTR_CTL;

// ;I/O FUNCTIONS

typedef enum bit [0:8] {
                        ebusctlGRAB_EEBUS = 9'b100_000_000,
                        ebusctlREQ_EBUS = 9'b010_000_000,
                        ebusctlREL_EBUS = 9'b001_000_000,
                        ebusctlEBUS_DEMAND = 9'b000_110_000,
                        ebusctlEBUS_NODEMAND = 9'b000_010_000,
                        ebusctlCTL_IR = 9'b000_001_000,
                        ebusctlDISABLE_CS = 9'b000_000_100,
                        ebusctlDATAIO = 9'b000_000_010,
                        ebusctlINPUT = 9'b000_000_001,
                        ebusctlIO_INIT = 9'b000_011_000,
                        ebusctlDATAO = 9'b000_010_110,
                        ebusctlDATAI = 9'b000_010_111,
                        ebusctlREL_EEBUS = 9'b000_000_000
                        } tEBUS_CTL;

typedef enum bit [0:8] {
                        diagfunc500_NS = 9'b100_000_000,
                        diagfuncLD_PA_LEFT = 9'b100_000_100,
                        diagfuncLD_PA_RIGHT = 9'b100_000_101,
                        diagfuncCONO_MTR = 9'b100_000_110,
                        diagfuncCONO_TIM = 9'b100_000_111,
                        diagfuncCONO_APR = 9'b100_001_100,
                        diagfuncCONO_PI = 9'b100_001_101,
                        diagfuncCONO_PAG = 9'b100_001_110,
                        diagfuncDATAO_APR = 9'b100_001_111,
                        diagfuncDATAO_PAG = 9'b110_010_000,
                        diagfuncLD_AC_BLKS = 9'b100_010_101,
                        diagfuncLD_PCSplusCWSX = 9'b100_010_110,
                        diagfuncCONI_PI_R = 9'b101_000_000,
                        diagfuncCONI_PI_L = 9'b101_000_001,
                        diagfuncRD_TIME = 9'b101_010_000,
                        diagfuncDATAI_PAG_LorRD_PERF_CNT = 9'b101_001_001,
                        diagfuncCONI_APR_LorRD_EBOX_CNT = 9'b101_001_010,
                        diagfuncDATAI_APRorRD_CACHE_CNT = 9'b101_001_011,
                        diagfuncRD_INTRVL = 9'b101_001_100,
                        diagfuncRD_PERIOD = 9'b101_001_101,
                        diagfuncCONI_MTR = 9'b101_001_110,
                        diagfuncRD_MTR_REQ = 9'b101_001_111,
                        diagfuncCONI_PI_PAR = 9'b101_011_000,
                        diagfuncCONI_PAG = 9'b101_011_001,
                        diagfuncRD_EBUS_REG = 9'b101_110_111
                        } tDIAG_FUNC;

typedef struct packed {
  bit u0;
  bit [0:10] J;
  bit [0:5] AD;
  bit [0:2] ADA;
  bit u21;
  bit [0:1] ADB;
  bit [0:2] AR;
  bit [0:2] ARX;
  bit BR;
  bit  BRX;
  bit MQ;
  bit [0:2] FMADR;
  bit [0:2] SCAD;
  bit [0:2] SCADA;
  bit u42;
  bit [0:1] SCADB;
  bit u45;
  bit SC;
  bit FE;
  bit u48;
  bit [0:1] SH;
  bit u51;
  bit [0:1] VMA;
  bit [0:1] _TIME;
  bit [0:3] MEM;
  bit [0:5] COND;
  bit CALL;
  bit [0:4] DISP;
  bit [72:73] u73;
  bit MARK;
  bit [0:8] MAGIC;
} tCRAM;

interface iCRAM;
  bit [0:10] J;
  bit [0:5] AD;
  bit [0:2] ADA;
  bit [0:1] ADB;
  bit [0:2] AR;
  bit [0:2] ARX;
  bit BR;
  bit  BRX;
  bit MQ;
  bit [0:2] FMADR;
  bit [0:2] SCAD;
  bit [0:2] SCADA;
  bit [0:1] SCADB;
  bit SC;
  bit FE;
  bit [0:1] SH;
  bit [0:1] VMA;
  bit [0:1] _TIME;
  bit [0:3] MEM;
  bit [0:5] COND;
  bit CALL;
  bit [0:4] DISP;
  bit [0:4] SPEC;
  bit MARK;
  bit [0:8] MAGIC;

  modport crm(output J, AD, ADA, ADB, AR, ARX, BR, BRX, MQ, FMADR,
              SCAD, SCADA, SCADB, SC, FE, SH, VMA, _TIME, MEM, COND,
              CALL, DISP, MARK, MAGIC);

  modport mod(input J, AD, ADA, ADB, AR, ARX, BR, BRX, MQ, FMADR,
              SCAD, SCADA, SCADB, SC, FE, SH, VMA, _TIME, MEM, COND,
              CALL, DISP, MARK, MAGIC);
endinterface


////////////////////////////////////////////////////////////////
// Modules
interface iAPR;
  bit ANY_EBOX_ERR_FLG;
  bit APR_INTERRUPT;
  bit APR_PAR_CHK_EN;
  bit CLK;
  bit CONI_OR_DATAI;
  bit CONO_OR_DATAO;
  bit C_DIR_P_ERR;
  bit EBOX_CCA;
  bit EBOX_DISABLE_CS;
  bit EBOX_EBR;
  bit EBOX_ERA;
  bit EBOX_LOAD_REG;
  bit EBOX_READ_REG;
  bit EBOX_SBUS_DIAG;
  bit EBOX_SEND_F02;
  bit EBOX_SPARE;
  bit EBOX_UBR;
  bit EBUS_DEMAND;
  bit EBUS_DISABLE_CS;
  bit EBUS_F01;
  bit EBUS_REQ;
  bit EBUS_RETURN;
  bit EN_REFILL_RAM_WR;
  bit FETCH_COMP;
  bit FM_BIT_36;
  bit FM_EXTENDED;
  bit FM_ODD_PARITY;
  bit MB_PAR_ERR;
  bit NXM_ERR;
  bit PT_DIR_WR;
  bit PT_WR;
  bit READ_COMP;
  bit SBUS_ERR;
  bit SET_IO_PF_ERR;
  bit SET_PAGE_FAIL;
  bit SPARE;
  bit SWEEP_BUSY;
  bit S_ADR_P_ERR;
  bit USER_COMP;
  bit WRITE_COMP;
  bit WR_BAD_ADR_PAR;
  bit WR_PT_SEL_0;
  bit WR_PT_SEL_1;
  bit [0:2] CURRENT_BLOCK;
  bit [0:2] FM_BLOCK;
  bit [0:2] PREV_BLOCK;
  bit [0:2] VMA_BLOCK;
  bit [0:2] XR_BLOCK;
  bit [0:3] FM_ADR;
  bit [3:6] MBOX_CTL;
  bit [9:12] AC;
  tEBUSdriver EBUSdriver;
endinterface


interface iCLK;
  bit APR;
  bit CCL;
  bit CCW;
  bit CHC;
  bit CHX;
  bit CON;
  bit CRA;
  bit CRAM_PAR_ERR;
  bit CRC;
  bit CRM;
  bit CROBAR;
  bit CSH;
  bit DRAM_PAR_ERR;
  bit EBOX_CYC_ABORT;
  bit EBOX_REQ;
  bit EBOX_SYNC;
  bit EBUS_CLK;
  bit EBUS_RESET;
  bit EDP;
  bit ERROR;
  bit ERROR_HOLD_A;
  bit ERROR_HOLD_B;
  bit ERROR_STOP;
  bit ERR_STOP_EN;
  bit FM_ODD_PARITY;
  bit FM_PAR_ERR;
  bit FORCE_1777;
  bit FS_ERROR;
  bit FUNC_042;
  bit FUNC_043;
  bit FUNC_044;
  bit FUNC_045;
  bit FUNC_046;
  bit FUNC_047;
  bit FUNC_BURST;
  bit FUNC_CLR_RESET;
  bit FUNC_COND_SS;
  bit FUNC_EBOX_SS;
  bit FUNC_GATE;
  bit FUNC_SET_RESET;
  bit FUNC_SINGLE_STEP;
  bit FUNC_START;
  bit GO;
  bit INSTR_1777;
  bit IR;
  bit MB;
  bit MBC;
  bit MBOX_13;
  bit MBOX_14;
  bit MBOX_CYCLE_DIS;
  bit MBOX_RESP;
  bit MBX;
  bit MBZ;
  bit MB_XFER;
  bit MCL;
  bit MHZ16_FREE;
  bit MR_RESET;
  bit MTR;
  bit PAGE_ERROR;
  bit PAGE_FAIL;
  bit PAGE_FAIL_EN;
  bit PF_DLYD;
  bit PF_DLYD_A;
  bit PF_DLYD_B;
  bit PIC;
  bit PMA;
  bit PT_DIR_WR;
  bit PT_WR;
  bit RESET;
  bit RESP_MBOX;
  bit RESP_SIM;
  bit SBR_CALL;
  bit SBUS_CLK;
  bit SCD;
  bit SYNC;
  bit SYNC_EN;
  bit SYNC_HOLD;
  bit TENELEVEN_CLK;
  bit VMA;
  bit [0:1] RATE_SEL;
  bit [0:1] SOURCE_SEL;
  bit [7:10] PF_DISP;
  bit _1777_EN;
  tEBUSdriver EBUSdriver;
endinterface


interface iCON;
  bit ARX_36;
  bit ARX_LOADED;
  bit AR_36;
  bit AR_FROM_EBUS;
  bit AR_LOADED;
  bit CACHE_LOAD_EN;
  bit CACHE_LOOK_EN;
  bit CLR_PRIVATE_INSTR;
  bit COND_024;
  bit COND_026;
  bit COND_027;
  bit COND_ADR_10;
  bit COND_AD_FLAGS;
  bit COND_DIAG_FUNC;
  bit COND_EBOX_STATE;
  bit COND_EBUS_CTL;
  bit COND_EBUS_STATE;
  bit COND_EN_00_07;
  bit COND_EN_10_17;
  bit COND_EN_20_27;
  bit COND_EN_30_37;
  bit COND_FE_SHRT;
  bit COND_FM_WRITE;
  bit COND_INSTR_ABORT;
  bit COND_LOAD_IR;
  bit COND_LOAD_VMA_HELD;
  bit COND_LONG_EN;
  bit COND_MBOX_CTL;
  bit COND_PCF_MAGIC;
  bit COND_SEL_VMA;
  bit COND_SPEC_INSTR;
  bit COND_SR_MAGIC;
  bit COND_VMAX_MAGIC;
  bit COND_VMA_DEC;
  bit COND_VMA_INC;
  bit COND_VMA_MAGIC;
  bit CONO_200000;
  bit CONO_APR;
  bit CONO_MTR;
  bit CONO_PAG;
  bit CONO_PI;
  bit DATAO_APR;
  bit DELAY_REQ;
  bit EBOX_HALTED;
  bit EBUS_GRANT;
  bit EBUS_REL;
  bit FM_WRITE00_17;
  bit FM_WRITE18_35;
  bit FM_WRITE_PAR;
  bit FM_XFER;
  bit IO_LEGAL;
  bit KI10_PAGING_MODE;
  bit KL10_PAGING_MODE;
  bit LOAD_ACCESS_COND;
  bit LOAD_AC_BLOCKS;
  bit LOAD_DRAM;
  bit LOAD_IR;
  bit LOAD_PREV_CONTEXT;
  bit LOAD_SPEC_INSTR;
  bit LONG_EN;
  bit MBOX_WAIT;
  bit NICOND_TRAP_EN;
  bit PCplus1_INH;
  bit PI_CYCLE;
  bit PI_DISABLE;
  bit PI_DISMISS;
  bit RESET;
  bit RUN;
  bit SEL_CLR;
  bit SEL_DIS;
  bit SEL_EN;
  bit SEL_SET;
  bit SET_PIH;
  bit SKIP_EN_40_47;
  bit SKIP_EN_50_57;
  bit SKIP_EN_60_67;
  bit SKIP_EN_70_77;
  bit START;
  bit TRAP_EN;
  bit UCODE_STATE1;
  bit UCODE_STATE3;
  bit UCODE_STATE5;
  bit UCODE_STATE7;
  bit WR_EVEN_PAR_ADR;
  bit [0:1] VMA_SEL;
  bit [0:3] SR;
  bit [7:10] NICOND;
  tEBUSdriver EBUSdriver;
endinterface


interface iCRA;
  tCRADR CRADR;
  bit [1:10] AREAD;
  bit DISP_PARITY;
  bit DIA_FUNC_050;
  bit DIA_FUNC_051;
  bit DIA_FUNC_052;
  bit DIA_FUNC_053;
  tEBUSdriver EBUSdriver;
endinterface


interface iCRM;
  bit PAR_16;
endinterface


interface iCTL;
  bit ADX_CRY_36;
  bit AD_CRY_36;
  bit AD_LONG;
  bit AD_TO_EBUS_L;
  bit AD_TO_EBUS_R;
  bit AR00to08_LOAD;
  bit AR00to11_CLR;
  bit AR09to17_LOAD;
  bit AR12to17_CLR;
  bit ARL_IND;
  bit ARR_CLR;
  bit ARR_LOAD;
  bit ARX_CLR;
  bit ARX_LOAD;
  bit AR_CLR;
  bit COND_ARLL_LOAD;
  bit COND_ARLR_LOAD;
  bit COND_ARL_IND;
  bit COND_ARR_LOAD;
  bit COND_ARX_CLR;
  bit COND_AR_CLR;
  bit COND_AR_EXP;
  bit COND_REG_CTL;
  bit CONSOLE_CONTROL;
  bit DIAG_AR_LOAD;
  bit DIAG_CHANNEL_CLK_STOP;
  bit DIAG_CLK_EDP;
  bit DIAG_CTL_FUNC_00x;
  bit DIAG_CTL_FUNC_01x;
  bit DIAG_FORCE_EXTEND;
  bit DIAG_LD_EBUS_REG;
  bit DIAG_LD_FUNC_04x;
  bit DIAG_LD_FUNC_073;
  bit DIAG_LD_FUNC_074;
  bit DIAG_LD_FUNC_076;
  bit DIAG_LOAD_FUNC_05x;
  bit DIAG_LOAD_FUNC_06x;
  bit DIAG_LOAD_FUNC_070;
  bit DIAG_LOAD_FUNC_071;
  bit DIAG_LOAD_FUNC_072;
  bit DIAG_LOAD_FUNC_07x;
  bit DIAG_READ;
  bit DIAG_READ_FUNC_11x;
  bit DIAG_READ_FUNC_12x;
  bit DIAG_READ_FUNC_13x;
  bit DIAG_READ_FUNC_14x;
  bit DIAG_READ_FUNC_15x;
  bit DIAG_READ_FUNC_16x;
  bit DIAG_READ_FUNC_17x;
  bit DIAG_STROBE;
  bit DIAG_SYNC_FUNC_075;
  bit DISP_AREAD;
  bit DISP_EA_MOD;
  bit DISP_DIV;
  bit DISP_MUL;
  bit DISP_NORM;
  bit DISP_NICOND;
  bit DISP_RET;
  bit DISP_RETURN;
  bit [0:6] DS;
  bit EBUS_E_TO_T_EN;
  bit EBUS_PARITY_OUT;
  bit EBUS_T_TO_E_EN;
  bit EBUS_XFER;
  bit GEN_CRY_18;
  bit INH_CRY_18;
  bit LOAD_PC;
  bit MQM_EN;
  bit MQ_CLR;
  bit PI_CYCLE_SAVE_FLAGS;
  bit READ_STROBE;
  bit SPEC_ADX_CRY_36;
  bit SPEC_AD_LONG;
  bit SPEC_ARL_IND;
  bit SPEC_CALL;
  bit SPEC_CLR_FPD;
  bit SPEC_FLAG_CTL;
  bit SPEC_GEN_CRY_18;
  bit SPEC_INH_CRY_18;
  bit SPEC_LOAD_PC;
  bit SPEC_MQ_SHIFT;
  bit SPEC_MTR_CTL;
  bit SPEC_SAVE_FLAGS;
  bit SPEC_SBR_CALL;
  bit SPEC_SCM_ALT;
  bit SPEC_SP_MEM_CYCLE;
  bit SPEC_STACK_UPDATE;
  bit SPEC_XCRY_AR0;
  bit [0:1] ARL_IND_SEL;
  bit [0:1] DISP_EN;
  bit [0:1] MQM_SEL;
  bit [0:1] MQ_SEL;
  bit [0:2] ARL_SEL;
  bit [0:2] ARR_SEL;
  bit [0:2] ARXL_SEL;
  bit [0:2] ARXR_SEL;
  bit [0:6] DIAG;
  bit [0:8] REG_CTL;
  bit adToEBUS_L;
  bit adToEBUS_R;
  tEBUSdriver EBUSdriver;
endinterface


interface iEDP;
  bit DIAG_READ_FUNC_10x;
  bit FM_PARITY;
  bit FM_WRITE;
  bit [-2:35] AD;
  bit [-2:36] AD_CRY;
  bit [0:35] ADX;
  bit [0:35] AD_OVERFLOW;
  bit [0:35] AR;
  bit [0:35] ARX;
  bit [0:35] BR;
  bit [0:35] BRX;
  bit [0:35] FM;
  bit [0:35] MQ;
  bit [0:36] ADX_CRY;
  bit [0:8] ARMM_SCD;
  bit [13:17] ARMM_VMA;
  tEBUSdriver EBUSdriver;
endinterface


interface iIR;
  bit IO_LEGAL;
  bit ADeq0;
  bit ACeq0;
  bit JRST0;
  bit TEST_SATISFIED;

  bit [8:10] NORM;
  bit [0:12] IR;
  bit [9:12] AC;
  bit [0:2] DRAM_A;
  bit [0:2] DRAM_B;
  bit [0:10] DRAM_J;
  bit DRAM_ODD_PARITY;
  tEBUSdriver EBUSdriver;
endinterface


interface iMCL;
  bit _18_BIT_EA;
  bit _23_BIT_EA;
  bit LOAD_AR;
  bit STORE_AR;
  bit LOAD_ARX;
  bit LOAD_VMA;
  bit MBOX_CYC_REQ;
  bit PAGED_FETCH;
  bit MEM_ARL_IND;
  bit SHORT_STACK;
  bit SKIP_SATISFIED;
  bit PC_SECTION_0;
  bit EBOX_MAP;
  bit EBOX_CACHE;
  bit REQ_EN;
  bit MEM_REG_FUNC;
  bit VMA_AD;
  bit VMA_ADR_ERR;
  bit VMA_INC;
  bit VMA_FETCH;
  bit VMA_EXTENDED;
  bit VMA_SECTION_0;
  bit VMA_SECTION_01;
  bit VMA_READ;
  bit VMA_READ_OR_WRITE;
  bit VMAX_EN;
  bit VMA_PAUSE;
  bit VMA_WRITE;
  bit VMA_PREV_EN;
  bit LOAD_VMA_CONTEXT;
  bit VMA_EXEC;
  bit VMA_USER;
  bit VMA_PUBLIC;
  bit VMA_PREVIOUS;
  bit XR_PREVIOUS;
  bit [0:1] VMAX_SEL;
  bit LOAD_VMA_HELD;
  bit PAGE_UEBR_REF;
  bit PAGE_UEBR_REF_A;
  bit [27:33] VMA_G;
  bit ADR_ERR;
  bit VMA_EPT;
  bit VMA_UPT;
  bit EBOX_MAY_BE_PAGED;
  bit PAGE_ILL_ENTRY;
  bit PAGE_TEST_PRIVATE;
  bit PAGE_ADDRESS_COND;
  tEBUSdriver EBUSdriver;
endinterface


interface iMTR;
  bit CCA_WRITEBACK;
  bit INTERRUPT_REQ;
  bit CONO_MTR;
  bit VECTOR_INTERRUPT;
  bit _1_MHZ;
  tEBUSdriver EBUSdriver;
endinterface


interface iPI;
  bit GATE_TTL_TO_ECL;
  bit EBUS_CP_GRANT;
  bit EXT_TRAN_REC;
  bit READY;
  bit MTR_HONOR;
  bit XOR_ON_BUS;
  bit SEND_2H;
  bit [0:2] HOLD;
  bit [0:2] MTR_PIA;
  bit [0:2] PIC;
  bit [0:2] APR_PIA;
  tEBUSdriver EBUSdriver;
endinterface


interface iSBUS;
  bit ACKN_A;
  bit ACKN_B;
  bit ADR_HOLD;
  bit ADR_PAR;
  bit ADR_PAR_ERR;
  bit CLK_EXT;
  bit CLK_INT;
  bit DATA_PAR;
  bit DATA_VALID;
  bit DATA_VALID_A;
  bit DATA_VALID_B;
  bit DIAG;
  bit ERROR;
  bit MEM_RESET;
  bit START_A;
  bit START_B;
  bit [0:35] D;
  bit [0:3] RD_RQ;
  bit [0:3] RQ;
  bit [0:3] WR_RQ;
  bit [14:35] ADR;
  bit CROBAR;

  modport mbox(
               output START_A,
               output START_B,
               output RD_RQ,
               output WR_RQ,
               output RQ,
               output ADR,
               output ADR_PAR,
               output DIAG,
               output CLK_INT,
               output CLK_EXT,
               output MEM_RESET,
               output CROBAR,

               inout D,
               inout DATA_PAR,
               inout DATA_VALID_A,
               inout DATA_VALID_B,


               input ACKN_A,
               input ACKN_B,
               input ERROR,
               input ADR_PAR_ERR
               );

  modport memory(
                 input START_A,
                 input START_B,
                 input RD_RQ,
                 input WR_RQ,
                 input RQ,
                 input ADR,
                 input ADR_PAR,
                 input DIAG,
                 input CLK_INT,
                 input CLK_EXT,
                 input MEM_RESET,
                 input CROBAR,

                 inout D,
                 inout DATA_PAR,
                 inout DATA_VALID_A,
                 inout DATA_VALID_B,

                 output ACKN_A,
                 output ACKN_B,
                 output ERROR,
                 output ADR_PAR_ERR
                 );
endinterface


interface iSCD;
  bit SC_GE_36;
  bit SC_36_TO_63;
  bit [0:9] FE;
  bit [0:9] SC;
  bit [0:35] SCADA;
  bit [0:35] SCADB;
  bit SCADeq0;
  bit SCAD_SIGN;
  bit SC_SIGN;
  bit FE_SIGN;
  bit OV;
  bit CRY0;
  bit CRY1;
  bit FOV;
  bit FXU;
  bit FPD;
  bit PCP;
  bit DIV_CHK;
  bit TRAP_REQ_1;
  bit TRAP_REQ_2;
  bit TRAP_CYC_1;
  bit TRAP_CYC_2;
  bit [32:35] TRAP_MIX;
  bit KERNEL_MODE;
  bit USER;
  bit USER_IOT;
  bit KERNEL_USER_IOT;
  bit PUBLIC;
  bit PUBLIC_EN;
  bit PRIVATE;
  bit PRIVATE_INSTR;
  bit ADR_BRK_PREVENT;
  bit ADR_BRK_INH;
  bit ADR_BRK_CYC;
  tEBUSdriver EBUSdriver;
endinterface


interface iSHM;
  bit [0:35] SH;
  bit [0:35] XR;
  bit AR_PAR_ODD;
  bit INDEXED;
  bit AR_EXTENDED;
  bit ARX_PAR_ODD;
  tEBUSdriver EBUSdriver;
endinterface


interface iVMA;
  bit LOCAL_AC_ADDRESS;
  bit AC_REF;
  bit [12:35] PC;
  bit [12:35] VMA;
  bit [12:35] ADR_BRK;
  bit [12:17] PREV_SEC;
  bit [12:35] HELD;
  bit [0:35] HELD_OR_PC;
  bit PC_SECTION_0;
  bit PCS_SECTION_0;
  bit VMA_SECTION_0;
  bit LOAD_PC;
  bit LOAD_VMA_HELD;
  bit MATCH_13_35;
  tEBUSdriver EBUSdriver;
endinterface


////////////////////////////////////////////////////////////////
// MBOX definitions

interface iMBOX;
  bit ACKN_PULSE;
  bit A_CHANGE_COMING_IN;
  bit CACHE_EXISTS;
  bit CACHE_TO_MB_T4;
  bit CACHE_WR_00;
  bit CACHE_WR_09;
  bit CACHE_WR_18;
  bit CACHE_WR_27;
  bit CBUS_OUT_HOLD;
  bit CBUS_PAR_LEFT_RE;
  bit CBUS_PAR_LEFT_TE;
  bit CBUS_PAR_RIGHT_RE;
  bit CBUS_PAR_RIGHT_TE;
  bit CCL_HOLD_MEM;
  bit CCW_BUF_IN;
  bit CCW_BUF_WR;
  bit CHAN_ADR_PAR_ERR;
  bit CHAN_NXM_ERR;
  bit CHAN_PAR_ERR;
  bit CHAN_READ;
  bit CH_BUF_WR;
  bit CH_REVERSE;
  bit CH_T0;
  bit CH_T1;
  bit CH_T2;
  bit CNT_MB_XFER;
  bit CORE_BUSY;
  bit CORE_RD_IN_PROG;
  bit CSH_ADR_PAR_BAD;
  bit CSH_ADR_PAR_ERR;
  bit CSH_ADR_WR_PULSE;
  bit CSH_CHAN_CYC;
  bit CSH_EN_CSH_DATA;
  bit CSH_PAR_BIT_IN;
  bit CSH_SEL_LRU;
  bit CSH_VAL_SEL_ALL;
  bit CSH_VAL_WR_DATA;
  bit CSH_VAL_WR_PULSE;
  bit CSH_WR_OUT_EN;
  bit CSH_WR_SEL_ALL;
  bit CSH_WR_WR_PULSE;
  bit DATA_VALID_A_OUT;
  bit DATA_VALID_B_OUT;
  bit DIAG_MEM_RESET;
  bit FORCE_NO_MATCH;
  bit HOLD_ERA;
  bit LOAD_EBUS_REG;
  bit MB0_HOLD_IN;
  bit MB1_HOLD_IN;
  bit MB2_HOLD_IN;
  bit MB3_HOLD_IN;
  bit MB_DATA_CODE_1;
  bit MB_DATA_CODE_2;
  bit MB_PAR;
  bit MB_PAR_BIT_IN;
  bit MB_PAR_ERR;
  bit MB_PAR_ODD;
  bit MB_REQ_HOLD;
  bit MB_SEL_1_EN;
  bit MB_SEL_2_EN;
  bit MB_SEL_HOLD;
  bit MBOX_ADR_PAR_ERR;
  bit MEM_ACKN_A;
  bit MEM_ACKN_B;
  bit MEM_ADR_PAR;
  bit MEM_ADR_PAR_ERR;
  bit MEM_BUSY;
  bit MEM_DATA_TO_MEM;
  bit MEM_DATA_VALID_A;
  bit MEM_DATA_VALID_B;
  bit MEM_DIAG;
  bit MEM_ERROR;
  bit MEM_PAR;
  bit MEM_PAR_IN;
  bit MEM_RD_RQ;
  bit MEM_START_A;
  bit MEM_START_B;
  bit MEM_TO_C_DIAG_EN;
  bit MEM_TO_C_EN;
  bit MEM_WR_RQ;
  bit NXM_ACK;
  bit NXM_ACKN;
  bit NXM_ANY;
  bit NXM_DATA_VAL;
  bit NXM_ERR;
  bit NXM_ERR_CLR;
  bit PAGED_REF;
  bit PHASE_CHANGE_COMING;
  bit PROBE;
  bit RQ_HOLD_FF;
  bit SBUS_ADR_HOLD;
  bit SBUS_ERR;
  bit SEL_1;
  bit SEL_2;
  bit S_ADR_P_ERR;
  bit [0:10] pfDisp;
  bit [0:1] CAM_SEL;
  bit [0:2] MB_IN_SEL;
  bit [0:35] CACHE_DATA;
  bit [0:35] CBUS_D_RE;
  bit [0:35] CBUS_D_TE;
  bit [0:35] CCW_MIX;
  bit [0:35] MB;
  bit [0:35] MEM_DATA_IN;
  bit [0:35] MEM_TO_CACHE;
  bit [0:3] CSH_PAR_BIT_A;
  bit [0:3] CSH_PAR_BIT_B;
  bit [0:3] CSH_WD_VAL;
  bit [0:3] CSH_WR_EN;
  bit [0:3] CSH_WR_WD_EN;
  bit [0:3] CSH_WR_WR_EN;
  bit [0:3] FORCE_VALID_MATCH;
  bit [0:3] MEM_RQ;
  bit [0:6] CCW_BUF_ADR;
  bit [0:1] MEM_TO_C_SEL;
  bit [14:35] PMA;
  bit [2:1] MB_SEL;
  bit [27:35] CACHE_ADR;
  bit [27:35] MBOX_GATE_VMA;
  bit [34:35] SBUS_ADR;
endinterface


interface iCCL;
  bit CH_LOAD_MB;
  bit CHAN_REQ;
  bit CHAN_TO_MEM;
  bit CHAN_EPT;
  bit CH_BUF_EN;
  bit START_MEM;
  bit ODD_WC_PAR;
  bit MIX_MB_SEL;
  bit DATA_REVERSE;
  bit CH_TEST_MB_PAR;
  bit [2:1] CH_MB_SEL;
endinterface


interface iCCW;
  bit [0:3] WD_REQ;
  bit ODD_ADR_PAR;
  bit [34:35] CHA;
endinterface


interface iCHA;
  bit [0:3] CSH_WR_WD_SEL;
  bit [0:3] WR_WD_EN;
endinterface


interface iCHC;
  bit CBUS_READY;
endinterface


interface iCRC;
  bit CBUS_OUT_HOLD;
  bit BUF_MB_SEL;
  bit CH_BUF_ADR;
  bit [0:2] SEL;
endinterface


interface iCSH;
  bit ADR_PMA_EN;
  bit ADR_READY;
  bit ANY_VAL_HOLD;
  bit ANY_VAL_HOLD_IN;
  bit CACHE_WR_IN;
  bit CCA_CYC;
  bit CCA_CYC_DONE;
  bit CCA_INVAL_T4;
  bit CCA_REQ_EN;
  bit CCA_REQ_GRANT;
  bit CCA_WRITEBACK;
  bit CHAN_CYC;
  bit CHAN_RD_T5;
  bit CHAN_REQ_GRANT;
  bit CHAN_T3;
  bit CHAN_T4;
  bit CHAN_WR_CACHE;
  bit CHAN_WR_T5_IN;
  bit CLEAR_WR_T0;
  bit DATA_CLR_DONE;
  bit EBOX_CCA_GRANT;
  bit EBOX_CYC;
  bit EBOX_ERA_GRANT;
  bit EBOX_LOAD_REG;
  bit EBOX_REQ_GRANT;
  bit EBOX_RETRY_REQ;
  bit EBOX_T0_IN;
  bit EBOX_T3;
  bit EBOX_WR_T4_IN;
  bit E_CACHE_WR_CYC;
  bit E_CORE_RD_RQ;
  bit E_WRITEBACK;
  bit FILL_CACHE_RD;
  bit GATE_VMA_27_33;
  bit LRU_1;
  bit LRU_2;
  bit MBOX_PT_DIR_WR;
  bit MBOX_RESP_IN;
  bit MB_CYC;
  bit MB_REQ_GRANT;
  bit MB_WR_RQ_CLR_NXT;
  bit ONE_WORD_RD;
  bit ONE_WORD_WR_T0;
  bit PAGE_FAIL_HOLD;
  bit PAGE_REFILL_ERROR;
  bit PAGE_REFILL_T0;
  bit PAGE_REFILL_T12;
  bit PAGE_REFILL_T13;
  bit PAGE_REFILL_T4;
  bit PAGE_REFILL_T8;
  bit PAGE_REFILL_T9;
  bit PAR_BIT_A;
  bit PAR_BIT_B;
  bit PGRF_CYC;
  bit RD_PAUSE_2ND_HALF;
  bit READY_TO_GO;
  bit REFILL_RAM_WR;
  bit T2;
  bit USE_HOLD;
  bit USE_WR_EN;
  bit VAL_WR_PULSE;
  bit WR_WR_PULSE;
  bit ADR_WR_PULSE;
  bit WRITEBACK_T1;
  bit WR_FROM_MEM_NXT;
  bit [0:1] MATCH_HOLD_IN;
  bit [0:3] ANY_WR;
  bit [0:3] VALID_MATCH;
  bit [0:3] WD_WR;
  tEBUSdriver EBUSdriver;
endinterface


interface iMBC;
  bit A_CHANGE_COMING;
  bit A_PHASE_COMING;
  bit B_CHANGE_COMING;
  bit CORE_BUSY;
  bit CORE_DATA_VALID;
  bit CORE_DATA_VALminus1;
  bit CORE_DATA_VALminus2;
  bit CSH_DATA_CLR_T1;
  bit CSH_DATA_CLR_T2;
  bit CSH_DATA_CLR_T3;
  bit CSH_WR_WR_DATA;
  bit INH_1ST_MB_REQ;
  bit DATA_CLR_DONE_IN;
  bit FIRST_WD_ADR_SEL;
  bit MEM_START;
  bit WRITE_OK;
  bit [27:35] PMA_HOLD;
  bit [34:35] CORE_ADR;
  tEBUSdriver EBUSdriver;
endinterface


interface iMBX;
  bit CACHE_BIT;
  bit CACHE_TO_MB_DONE;
  bit CACHE_TO_MB_T2;
  bit CCA_ALL_PAGES_CYC;
  bit CCA_INVAL_T4;
  bit CCA_REQ;
  bit CHAN_WR_CYC;
  bit CSH_ADR_PAR_ERR;
  bit CSH_CCA_INVAL_CSH;
  bit CSH_CCA_VAL_CORE;
  bit EBOX_LOAD_REG;
  bit FORCE_MATCH_EN;
  bit MB_REQ_IN;
  bit MB_SEL_HOLD_FF;
  bit MEM_RD_RQ_IN;
  bit MEM_TO_C_EN;
  bit MEM_WR_RQ_IN;
  bit REFILL_ADR_EN;
  bit REFILL_ADR_EN_NXT;
  bit REFILL_HOLD;
  bit SBUS_DIAG_3;
  bit WRITEBACK_T2;
  bit [1:2] CCA_SEL;
  bit [0:3] RQ_IN;
  bit [27:35] CSH_ADR;
  bit [34:35] CACHE_TO_MB;
  tEBUSdriver EBUSdriver;
endinterface


interface iMBZ;
  bit RD_PSE_WR;
  bit RD_PSE_WR_REF;
  tEBUSdriver EBUSdriver;
endinterface

interface iPAG;
  bit PF_EBOX_HANDLE;
  bit PAGE_OK;
  bit PAGE_FAIL;
  bit PAGE_REFILL;
  bit PAGE_REFILL_CYC;
  bit PF_HOLD_01_IN;
  bit PF_HOLD_02_IN;
  bit PF_HOLD_03_IN;
  bit PF_HOLD_04_IN;
  bit PF_HOLD_05_IN;
  bit [14:35] PT;
  bit [0:35] PT_IN;
  bit PT_ACCESS;
  bit PT_PUBLIC;
  bit PT_WRITABLE;
  bit PT_SOFTWARE;
  bit PT_CACHE;
  bit [18:26] PT_ADR;
  bit MB_00to17_PAR;
  bit MB_18to35_PAR;
endinterface


interface iPMA;
  bit ADR_PAR;
  bit CCA_CRY_OUT;
  bit CSH_EBOX_CYC;
  bit CSH_WRITEBACK_CYC;
  bit CYC_TYPE_HOLD;
  bit EBOX_PAGED;
  bit PAGE_REFILL_CYC;
  bit [14:35] CCW_CHA;
  bit [14:35] PA;
  bit [14:35] PMA;
  bit _14_26_PAR;
endinterface

`endif
