# Faithful-to-the-Original KL10PV CPU in SystemVerilog for Xilinx FPGA

![MIT licensed](https://img.shields.io/github/license/alanmimms/kl10?style=plastic)

I'm doing this while I learn SystemVerilog. The idea is to build an
FPGA implementation pretty much identical to the original schematics
from the [`MP00301_KL10PV_Jun80` schematic PDFs from the scans on
Archive.org](https://archive.org/details/bitsavers_decpdp10KL0_67493660).

# Status
This is a labor of love and it's a work in progress. I have about 80%
of the schematics coded and some of it is working in simulation.

I have a temporary memory interfaced via SBUS to my MBOX and thence to
my EBOX. All of this is starting to work with microcode executing some
microinstructions, memory reads working to supply instructions from
the bootstrap, and the beginnings of some life.

What can I say? It's a hobby. And I don't think I'm going to run out
of interesting puzzles to solve anytime soon.


# Plans
I hope to make this work on my [Digilent Cora-Z7-10 FPGA
board](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start)
eventually, with the ARM cores acting as memory interface, disk and
tape storage interface, PDP-10 Front End, and FPGA loading mechanism.
