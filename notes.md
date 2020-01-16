# Notes About This Implementation

## Coding Conventions
* Use Verilog Auto Mode where possible.
* Use ALL UPPERCASE for CRAM field names.
* In ebox.v or top.v CRAM_XXX should be name for CRAM field XXX.
* Use ALL UPPERCASE for EDP, SHM, and other global register names.
  * In ebox.v and top.v EDP_XXX should be name for EDP register XXX.
  * Inside module code, EDP_XXX should be EDP_XXX.
* Use all lowercase for module names and their filenames must match.
* Use all lowercase and append "0" (increment as needed) to module
  name for instance names.
* Each module for an IP instance is called xxx_type
  * Where "xxx" is module's use case (e.g., "cram" or "fm")
  * Where "type" is module's use type (e.g., "mem")


## Differences from KL10PV
* Multiple drivers on a single bus are not the FPGA Way.
  * EBUS is multiplexed
    * This is used to drive the top.v mux to the EBUS register.
    * Each module that inputs from EBUS via its EBUS input.
    * Each module drives its XXX_EBUS via its XXX_EBUS output.
    * Each module driving EBUS generates an output XXXdrivingEBUS.
  * EBOX/MBOX cacheData split into cacheDataRead/cacheDataWrite


# TODO
- Fix bit ordering in module arguments to be one way or the other.
- Use sim to see if [0:3] is a four bit field we can use as a number.
