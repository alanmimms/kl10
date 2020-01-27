`timescale 1ns/1ns
`include "cram-defs.svh"

// M8548 CRM
//
// 2K words of CRAM storage.
//
// In a real KL10PV there are five instances of M8548. This is coded
// to act as all five slots.
module crm(input eboxClk,
           input eboxReset,
           input tCRADR CRADR,
           output tuCRAM CRAM);

  cram_mem cram0(.clka(eboxClk),
                 .addra(CRADR),
                 .dina(84'd0),
                 .douta(CRAM.all),
                 .wea(1'b0));

/*
  always_comb begin
    CRAM_J = tCRAM_J'(CRAMdata[1:11]);
    CRAM_AD = tCRAM_AD'(CRAMdata[12:17]);
    CRAM_ADA = tCRAM_ADA'(CRAMdata[18:20]);
    CRAM_ADA_EN = tCRAM_ADA_EN'(CRAMdata[18:18]);
    CRAM_ADB = tCRAM_ADB'(CRAMdata[22:23]);
    CRAM_AR = tCRAM_AR'(CRAMdata[24:26]);
    CRAM_ARX = tCRAM_ARX'(CRAMdata[27:29]);
    CRAM_BR = tCRAM_BR'(CRAMdata[30:30]);
    CRAM_BRX = tCRAM_BRX'(CRAMdata[31:31]);
    CRAM_MQ = tCRAM_MQ'(CRAMdata[32:32]);
    CRAM_FMADR = tCRAM_FMADR'(CRAMdata[33:35]);
    CRAM_SCAD = tCRAM_SCAD'(CRAMdata[36:38]);
    CRAM_SCADA = tCRAM_SCADA'(CRAMdata[39:41]);
    CRAM_SCADA_EN = tCRAM_SCADA_EN'(CRAMdata[39:39]);
    CRAM_SCADB = tCRAM_SCADB'(CRAMdata[43:44]);
    CRAM_SC = tCRAM_SC'(CRAMdata[46:46]);
    CRAM_FE = tCRAM_FE'(CRAMdata[47:47]);
    CRAM_SH = tCRAM_SH'(CRAMdata[49:50]);
    CRAM_ARMM = tCRAM_ARMM'(CRAMdata[49:50]);
    CRAM_VMAX = tCRAM_VMAX'(CRAMdata[49:50]);
    CRAM_VMA = tCRAM_VMA'(CRAMdata[52:53]);
    CRAM_TIME = tCRAM_TIME'(CRAMdata[54:55]);
    CRAM_MEM = tCRAM_MEM'(CRAMdata[56:59]);
    CRAM_SKIP = tCRAM_SKIP'(CRAMdata[60:65]);
    CRAM_COND = tCRAM_COND'(CRAMdata[60:65]);
    CRAM_CALL = tCRAM_CALL'(CRAMdata[66:66]);
    CRAM_DISP = tCRAM_DISP'(CRAMdata[67:71]);
    CRAM_SPEC = tCRAM_SPEC'(CRAMdata[67:71]);
    CRAM_MARK = tCRAM_MARK'(CRAMdata[74:74]);
    CRAM_MAGIC = tCRAM_MAGIC'(CRAMdata[75:83]);
    CRAM_MAJVER = tCRAM_MAJVER'(CRAMdata[75:80]);
    CRAM_MINVER = tCRAM_MINVER'(CRAMdata[81:83]);
    CRAM_KLPAGE = tCRAM_KLPAGE'(CRAMdata[75:75]);
    CRAM_LONGPC = tCRAM_LONGPC'(CRAMdata[76:76]);
    CRAM_NONSTD = tCRAM_NONSTD'(CRAMdata[77:77]);
    CRAM_PV = tCRAM_PV'(CRAMdata[78:78]);
    CRAM_PMOVE = tCRAM_PMOVE'(CRAMdata[79:79]);
    CRAM_ISTAT = tCRAM_ISTAT'(CRAMdata[83:83]);
    CRAM_PXCT = tCRAM_PXCT'(CRAMdata[75:77]);
    CRAM_ACB = tCRAM_ACB'(CRAMdata[77:79]);
    CRAM_ACmagic = tCRAM_ACmagic'(CRAMdata[80:83]);
    CRAM_AC_OP = tCRAM_AC_OP'(CRAMdata[75:79]);
    CRAM_AR0_8 = tCRAM_AR0_8'(CRAMdata[76:76]);
    CRAM_CLR = tCRAM_CLR'(CRAMdata[77:80]);
    CRAM_ARL = tCRAM_ARL'(CRAMdata[81:83]);
    CRAM_AR_CTL = tCRAM_AR_CTL'(CRAMdata[75:77]);
    CRAM_EXP_TST = tCRAM_EXP_TST'(CRAMdata[80:80]);
    CRAM_MQ_CTL = tCRAM_MQ_CTL'(CRAMdata[82:83]);
    CRAM_PC_FLAGS = tCRAM_PC_FLAGS'(CRAMdata[75:83]);
    CRAM_FLAG_CTL = tCRAM_FLAG_CTL'(CRAMdata[75:83]);
    CRAM_SPEC_INSTR = tCRAM_SPEC_INSTR'(CRAMdata[75:83]);
    CRAM_FETCH = tCRAM_FETCH'(CRAMdata[75:83]);
    CRAM_EA_CALC = tCRAM_EA_CALC'(CRAMdata[75:83]);
    CRAM_SP_MEM = tCRAM_SP_MEM'(CRAMdata[75:83]);
    CRAM_MREG_FNC = tCRAM_MREG_FNC'(CRAMdata[75:83]);
    CRAM_MBOX_CTL = tCRAM_MBOX_CTL'(CRAMdata[75:83]);
    CRAM_MTR_CTL = tCRAM_MTR_CTL'(CRAMdata[81:83]);
    CRAM_EBUS_CTL = tCRAM_EBUS_CTL'(CRAMdata[75:83]);
    CRAM_DIAG_FUNC = tCRAM_DIAG_FUNC'(CRAMdata[75:83]);
  end
*/
  
  always_ff @(posedge eboxClk) begin
    if (eboxReset) CRAM.all = 84'd0;
  end
endmodule
// Local Variables:
// verilog-library-files:("../ip/cram_mem/cram_mem_stub.v")
// End:
