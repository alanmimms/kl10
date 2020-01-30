`timescale 1ns/1ns
// M8525 CON
module con(input eboxClk,
           output logic loadIR,
           output logic loadDRAM,
           output logic CON_LONG_ENABLE,
           output logic CON_PI_CYCLE,
           output logic CON_PCplus1_INH,
           output logic CON_FM_XFER,
           output logic CON_COND_EN00_07,
           output logic CON_COND_DIAG_FUNC,
           output CON_fmWrite00_17,
           output CON_fmWrite18_35);
endmodule // con
