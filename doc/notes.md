# TODO
* Convert cram-defs.svh to package
* Convert ebus-defs.svh to package
* Use associative array to build list of iEBUSdriver modules for top.v synthesis?
* Define methods for EBUS access in iEBUS
* Go through the rev 'F' CON and make sure that is what I implemented.
* `DIAG_READ` is assigned to `DIAG_READ_FUNC_01x` in EDP and in CLK.
  * Elsewhere too?
  * This should just be done in one place.

# System Organization
* EBOX implementation in FPGA running KL10pv final microcode
  * EBUS
    * RH20 FPGA module to ARM Linux emulated storage (channel controls)
    * DTE2 FPGA module to ARM Linux emulated front end (diagnostics, FE I/O)
  * CBUS (control/data) attachment to
    * RH20
  * E/M bus
    * FPGA implemented cache
    * FPGA implemented pager and PMA
    * FPGA DMA interface to ARM Linux provided RAM

# EBUS
  * The front end can read/write DS00-06 any time.
    * See EK-DTE20-UD-003 p. 18.
  * `DIAG_STROBE` indicates DS00-06 lines are stable.
  * DFUNC ("remove status") assertion
    * KL relenquishes control of EBUS DS lines
    * Puts EBUS translator for DS lines under DB00/DB01 control.

# Notes About This Implementation

## Coding Conventions
* Use Verilog Auto Mode where possible.
* Use ALL UPPERCASE for CRAM field names.
* In ebox.v or top.v `CRAM_XXX` should be name for CRAM field XXX.
* Use ALL UPPERCASE for EDP, SHM, and other global register names.
  * In ebox.v and top.v `EDP_XXX` should be name for EDP register XXX.
  * Inside module code, `EDP_XXX` should be `EDP_XXX`.
* Use all lowercase for module names and their filenames must match.
* Use all lowercase and append "0" (increment as needed) to module
  name for instance names.
* Each module for an IP instance is called `xxx_type`
  * Where "xxx" is module's use case (e.g., "cram" or "fm")
  * Where "type" is module's use type (e.g., "mem")

## Differences from KL10PV
* Multiple drivers on a single bus are not the FPGA Way.
  * EBUS is multiplexed
    * This is used to drive the top.v mux to the EBUS register.
    * Each module that inputs from EBUS via its EBUS input.
    * Each module drives its `XXX_EBUS` via its `XXX_EBUS` output.
    * Each module driving EBUS generates an output XXXdrivingEBUS.
  * EBOX/MBOX cacheData split into cacheDataRead/cacheDataWrite


# Documentation Pointers

* DTE20 is where the 10/11 interface lives
  * Documented in `EK-DTE20-UD-003_Oct76.pdf`.
  * Also from SAIL in ETHDES.txt.

* EBOX/MBUS interface is shown in
  * `EK-OKL10-TM_KL10_TechRef_Aug84_text.pdf` starting on p.48

* EBUS in `EK-OKL10-TM_KL10_TechRef_Aug84_text.pdf` starting on p.81

* RP07 registers `EK-OKL10-MG-004_KL10_Maintenance_Guide_Update_Jun86_text.pdf` p.98

* Diagnostic commands p. 71
  `EK-OKL10-MG-003_KL10_Maintenance_Guide_Volume_1_Rev_3_Apr85_text.pdf`
  * KL10PV diagnostic read commands numerically p.98, alphabetically p.108

* KL CPU module utilitization charts p.383
  `EK-OKL10-MG-003_KL10_Maintenance_Guide_Volume_1_Rev_3_Apr85_text.pdf`

* Module B compatibility and versions p.306 `LCG_GoodStuffNewsletters-OCR.pdf`

* KLAD20 for KL10-PV is tape BB-F287M-D1.
  * Superseded July'81 by BB-E543Q-DD@1600, AP-E542Q-DD@800.
    

* CONVRT.EXE is documented p.353 `LCG_GoodStuffNewsletters-OCR.pdf`

* TOPS20 V7 documents at http://bitsavers.trailing-edge.com/pdf/dec/pdp10/TOPS20/V7/


# KL10 Options

CD20	card reader controller
CD20-A	card reader (table top) cap=1000; 285 cards/min (via RSX20F Unibus)
CD20-C	card reader (console) cap=2250; 1200 cards/min (via RSX20F Unibus)
CI20	"KLIPA" CI channel (takes RH20 slots 6&7)
DC20-F	DH11's in KL front end (available in 8 or 16 ports)
DIA20	KI10 I/O bus adaptor (on 1090)
DIB20	KI10 I/O bus adaptor (on 1091)
DMA20	KL10D S-Bus to KI10 external memory bus controller
DX20	Massbus RP20, TU70-73 data controller (on RH20) PDP-8 (micro?) based
LP05	Line printer on LP20 (Modified DPC 2230)
LP07	Line printer on LP20 (Modified DPC 2550)
LP10	Line printer on LP20 (Modified DPC 2470) no software defined DAVFU
LP14	Line printer on LP20 (Modified DPC 2290)
LP20	Unibus Line printer interface (RSX20F or DN20/21)
LP26/27
LP29

MA20	32-256KW 1.0us parity internal memory (2 ctrls w/ 4 modules of 32K)
MB20	64-512KW 1.2us parity internal memory (2 ctrls w/ 4 modules of 64K)
MCA20	pager/cache memory (109x/2060)
MCA25	pager/cache memory (2065)
MF20	256K-1563KW 667ns ECC (36+6ECC+1parity+1spare) internal MOS (16K chips)
MG20	1-4MW 467ns ECC (36+7ECC+1spare) internal MOS (64K chips)
NIA20	"KLNI" Ethernet channel (takes RH20 slots 4&5?)
RH20	Massbus (internal) channel
TM78	Massbus tape controller for TU78/TU79 (on RH20 or RH11)


# KL10 models and backplanes

Engineering   Marketing     Type of
Designation   Designation   Backplane    Model
  KL10-A         1080        KL10-PA       A
  KL10-B         1090        KL10-PA       A
  KL10-C         2040        KL10-PA       A
  KL10-D         1090        KL10-PV       B
  KL10-E         2040,2050   KL10-PV       B
                 2060,1091

# TODO
- Fix bit ordering in module arguments to be one way or the other.
- Use sim to see if [0:3] is a four bit field we can use as a number.

