# Notes About This Implementation

## Coding Conventions
* Use Verilog Auto Mode where possible.
* Use ALL UPPERCASE for CRAM field names.
* In ebox.v or top.v CRAM_XXX should be name for CRAM field XXX.
* Use ALL UPPERCASE for EDP register names.
  * In ebox.v and top.v EDP_XXX should be name for EDP register XXX.
  * Inside module code, EDP_XXX should be input XXX.
* Use all lowercase for module names and their filenames must match.
* Use all lowercase and append "0" (or whatever) to module name for
  instance names.
* Each module for an IP instance is called xxx_type
  * Where "xxx" is module's use case (e.g., "cram" or "fm")
  * Where "type" is module's use type (e.g., "mem")


## Differences from KL10PV
* Multiple drivers on a single bus are not the FPGA Way.
  * EBUS is multiplexed
    * Each module that drives EBUS generates output drivingEBUS.
    * This is used to drive the top.v mux to the EBUS register.
    * ebox.v convention is MODULENAMEdrivingEBUS is name of this
      signal for uppercased module named "modulename".
    * Each module that inputs from EBUS uses its ebusIn input.
    * Each module that drives EBUS uses its ebusOut output.
  * EBOX/MBOX cacheData split into cacheDataRead/cacheDataWrite


# TODO
- Fix bit ordering in module arguments to be one way or the other.
- Use sim to see if [0:3] is a four bit field we can use as a number.
