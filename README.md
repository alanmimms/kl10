# Faithful-to-the-Original KL10PV CPU in SystemVerilog for Xilinx FPGA

![MIT licensed](https://img.shields.io/github/license/alanmimms/kl10?style=plastic)

I'm doing this while I learn SystemVerilog. The idea is to build an
FPGA implementation pretty much identical to the original schematics
from the [`MP00301_KL10PV_Jun80` schematic PDFs from the scans from Al
Kossow's Bit Savers
archive](http://bitsavers.org/pdf/dec/pdp10/KL10/MP00301_KL10PV_Jun80.pdf).

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


# EBOX Unit Description in Legible Form
I was forced to host the actually legible form of the
(http://alanmimms.com/images/EK-EBOX-UD-004-OCR.pdf)[EK-EBOX-004
document] because it's too big for GitHub. Thanks to `titan` on the
`alt.sys.pdp10` newsgroup who scanned his personal copy at good
resolution so I could make this possible.
