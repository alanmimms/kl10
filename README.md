# Faithful-to-the-Original KL10PV CPU in SystemVerilog for Xilinx FPGA

I'm doing this while I learn Verilog. The idea is to build an FPGA
implementation pretty clearly identical to the original schematics
from the [`MP00301_KL10PV_Jun80` schematic PDFs from the scans on
Archive.org](https://archive.org/details/bitsavers_decpdp10KL0_67493660).

# Status
This is a labor of love and it's a work in progress. I have about half
of the schematics coded and some of it is working a bit in simulation.

I'm currently stuck waiting for a solution to a [Xilinx xelab tool
crash](https://forums.xilinx.com/t5/Simulation-and-Verification/xelab-crashes-with-SIGSEGV-Vivado-2019-2/td-p/1075281).
Of course I can continue entering code for schematic pages to make
progress, but I cannot simulate or run my code any other way until I
get this resolved.

To be clear this is probably my fault due to naivete or stupidity or
bad coding practices or whatever. But it's a crash in a black hole of
a tool that I can't find a solution to on my own.

# Plans
I hope to make this work on my [Digilent Cora-Z7-10 FPGA
board](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start)
eventually, with the ARM cores acting as memory interface, disk and
tape storage interface, PDP-10 Front End, and FPGA loading mechanism.
