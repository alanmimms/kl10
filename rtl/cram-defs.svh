`ifndef _CRAM_DEFS_
 `define _CRAM_DEFS_ 1

typedef logic [0:10] tCRADR;
typedef logic [0:10] tJ;
typedef logic [0:8] tMAGIC;
typedef logic [0:5] tMAJVER;
typedef logic [0:2] tMINVER;
typedef logic [0:2] tPXCT;
typedef logic [0:3] tACmagic;
typedef logic [0:83] tCRAM_ALL;

// CRAM_AD flag bits
 `define adCARRY 6'b100_000
 `define adBOOLEAN 6'b010_000

// CRAM_AD values
typedef enum logic [0:5] {
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

typedef enum logic [0:2] {
	                  adaAR = 3'b000,
	                  adaARX = 3'b001,
	                  adaMQ = 3'b010,
	                  adaPC = 3'b011,
                          adaZEROS = 3'b100
                          } tADA;

typedef enum logic [0:1] {
                          adbFM = 2'b00,
                          adbBRx2 = 2'b01,
                          adbBR = 2'b10,
                          adbARx4 = 2'b11
                          } tADB;

typedef enum logic [0:2] {
                          arAR = 3'b000, // also arARMM, arMEM
                          arCACHE = 3'b001,
                          arAD = 3'b010,
                          arEBUS = 3'b011,
                          arSH = 3'b100,
                          arADx2 = 3'b101,
                          arADX = 3'b110,
                          arADdiv4 = 3'b111
                          } tAR;

typedef enum logic [0:2] {
                          arxARX = 3'b000, // Also MEM
                          arxCACHE = 3'b001,
                          arxAD = 3'b010,
                          arxMQ = 3'b011,
                          arxSH = 3'b100,
                          arxADXx2 = 3'b101,
                          arxADX = 3'b110,
                          arxADXdiv4 = 3'b111
                          } tARX;

typedef enum logic {
                    brRECIRC = 1'b0,
                    brAR = 1'b1
                    } tBR;

typedef enum logic {
                    brxRECIRC = 1'b0,
                    brxARX = 1'b1
                    } tBRX;

typedef enum logic {
                    mqRECIRC = 1'b0,
                    mqSH = 1'b1
                    } tMQ;

typedef enum logic [0:2] {
                          fmadrAC0 = 3'b000,
                          fmadrAC1 = 3'b001,
                          fmadrXR = 3'b010,
                          fmadrVMA = 3'b011,
                          fmadrAC2 = 3'b100,
                          fmadrAC3 = 3'b101,
                          fmadrACplusMAGIC = 3'b110,
                          fmadrMAGIC = 3'b111
                          } tFMADR;

typedef enum logic [0:2] {
                          scadA = 3'b000,
                          scadAminusBminus1 = 3'b001,
                          scadAplusB = 3'b010,
                          scadAminus1 = 3'b011,
                          scadAplus1 = 3'b100,
                          scadAminusB = 3'b101,
                          scadOR = 3'b110,
                          scadAND = 3'b111
                          } tSCAD;

typedef enum logic [0:2] {
                          scadaFE = 3'b000,
                          scadaAR0_5 = 3'b001,
                          scadaAR_EXP = 3'b010,
                          scadaMAGIC = 3'b011,
                          scadaZEROS = 3'b100
                          } tSCADA;

typedef enum logic [0:1] {
                          scadbSC = 2'b00,
                          scadbAR6_11 = 2'b01,
                          scadbAR0_8 = 2'b10,
                          scadbMAGIC = 2'b11
                          } tSCADB;

typedef enum logic {
                    scRECIRC = 1'b0,
                    scSCAD = 1'b1
                    } tSC;

typedef enum logic {
                    feRECIRC = 1'b0,
                    feSCAD = 1'b1
                    } tFE;


typedef enum logic [0:1] {
                          shSHIFT_AR_ARX = 2'b00,
                          shAR = 2'b01,
                          shARX = 2'b10,
                          shAR_SWAP = 2'b11
                          } tSH;

typedef enum logic [0:1] {
                          armmMAGIC = 2'b00,
                          armmEXP_SIGN = 2'b01,
                          armmSCAD_EXP = 2'b10,
                          armmSCAD_POS = 2'b11
                          } tARMM;

typedef enum logic [0:1] {
                          vmaxVMAX = 2'b00,
                          vmaxPC_SEC = 2'b01,
                          vmaxPREV_SEC = 2'b10,
                          vmaxAD12_17 = 2'b11
                          } tVMAX;


typedef enum logic [0:1] {
                          vmaVMA = 2'b00,
                          vmaPC = 2'b01,
                          vmaPCplus1 = 2'b10,
                          vmaAD = 2'b11
                          } tVMA;

typedef enum logic [0:1] {
                          time2T = 2'b00,
                          time3T = 2'b01,
                          time4T = 2'b10,
                          time5T = 2'b11
                          } tTIME;

typedef enum logic [0:3] {
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

typedef enum logic [0:5] {
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

typedef enum logic [0:5] {
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


typedef enum logic [0:4] {
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

typedef enum logic [0:4] {
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


typedef enum logic [0:2] {
                          acbPAGB = 3'b110,
                          acbMICROB = 3'b111
                          } tACB;

typedef enum logic [0:5] {
                          acopACplusMAGIC = 6'b000_110,
                          acopMAGIC = 6'b011_010,
                          acopOR_ACnumber = 6'b011_011
                          } tAC_OP;


typedef enum logic [0:3] {
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

typedef enum logic [0:2] {
                          arlARL = 3'b000,
                          arlCACHE = 3'b001,
                          arlAD = 3'b010,
                          arlEBUS = 3'b011,
                          arlSH = 3'b100,
                          arlADx2 = 3'b101,
                          arlADX = 3'b110,
                          arlADdiv4 = 3'b111
                          } tARL;

typedef enum logic [0:2] {
                          arctlNOP = 3'b000,
                          arctlARR_LOAD = 3'b001,
                          arctlAR9_17 = 3'b010,
                          arctlAR0_8 = 3'b100,
                          arctlARL_LOAD = 3'b110
                          } tAR_CTL;

typedef enum logic [0:1] {
                          mqctlMQ = 2'b00,
                          mqctlMQx2 = 2'b01,
                          mqctlMQdiv2 = 2'b10,
                          mqctlZEROS = 2'b11
                          } tMQ_CTL;

typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
                          fetchUNCOND = 9'b100_000_000,
                          fetchCOMP = 9'b010_000_000,
                          fetchSKIP = 9'b010_000_010,
                          fetchTEST = 9'b010_000_011,
                          fetchJUMP = 9'b101_000_010,
                          fetchJFCL = 9'b101_000_011
                          } tFETCH;

typedef enum logic [0:8] {
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


typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
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

typedef enum logic [0:2] {
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

typedef enum logic [0:8] {
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

typedef enum logic [0:8] {
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
  logic u0;
  tJ J;
  tAD AD;
  tADA ADA;
  logic u21;
  tADB ADB;
  tAR AR;
  tARX ARX;
  tBR BR;
  tBRX BRX;
  tMQ MQ;
  tFMADR FMADR;
  tSCAD SCAD;
  tSCADA SCADA;
  logic u42;
  tSCADB SCADB;
  logic u45;
  tSC SC;
  tFE FE;
  logic u48;
  tSH SH;
  logic u51;
  tVMA VMA;
  tTIME TIME;
  tMEM MEM;
  tCOND COND;
  logic CALL;
  tDISP DISP;
  logic [72:73] u73;
  logic MARK;
  tMAGIC MAGIC;
} tCRAM;

`endif