# TODO
* Find all UCR4/USR4 uses and look for active-low schematic symbol and
  switch sense on .SEL signals. This has already been done in clk.sv.
  
* Convert cram-defs.svh to package?
* Convert ebus.svh to package?

* Use associative array to build list of iEBUSdriver modules for top.v synthesis?
* Define methods for EBUS access in iEBUS
* Go through the rev 'F' CON and make sure that is what I implemented.
* `DIAG_READ` is assigned to `DIAG_READ_FUNC_01x` in EDP and in CLK.
  * Elsewhere too?
  * This should just be done in one place.

## Modules to do
* MB0 memory buffer
* MBC MBOX control
* MBX MBOX control logic
* MBZ MBOX control

* CCL channel control logic
* CCW channel control word
* CHA cache directory
* CHC channel control
* CHD cache data (or substitute M8549-YH)
* CHX cache extension (or substitute M8549-YH)
* CRC channel RAM control
* DTE20 (CNT 10/11 interface)
* MTR meter board
