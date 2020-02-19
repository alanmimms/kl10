# Faithful-to-the-Original KL10PV CPU in SystemVerilog for Xilinx FPGA

I'm doing this while I learn Verilog. The idea is to build an FPGA
implementation pretty clearly identical to the original schematics
from the [`MP00301_KL10PV_Jun80` schematic PDFs from the scans on
Archive.org](https://archive.org/details/bitsavers_decpdp10KL0_67493660).

# Status
This is a labor of love and it's a work in progress. I have about half
of the schematics coded and some of it is working a bit in simulation.

I'm currently debugging the CLK (M8526-YA) module. This design is
particularly complicated because the DEC designers seemed to disdain
the use of RESET signals, instead working an automatic startup from
any state sort of mechanism into their designs. But the FPGA sims
represent the states as 1, 0, X, or Z, and it is the X that is causing
me so much grief. While the designer of the CLK board knew that a
counter would have _some_ value, I cannot know this. (Incrementing a
counter full of XXXXs doesn't give you a number, it gives you more
XXXXs.) I have to go through and find the states the CLK board's
startup mechanism depends on and make them happen through more modern
reset methods.

Without a CLK board to probe around in to see how it works, I'm having
to guess from schematics and names of signals what the desired
behavior.

What can I say? It's a hobby. And I don't think I'm going to run out
of interesting puzzles to solve anytime soon.


# Plans
I hope to make this work on my [Digilent Cora-Z7-10 FPGA
board](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start)
eventually, with the ARM cores acting as memory interface, disk and
tape storage interface, PDP-10 Front End, and FPGA loading mechanism.
