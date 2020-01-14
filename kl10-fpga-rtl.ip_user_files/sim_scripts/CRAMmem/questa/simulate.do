onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib CRAMmem_opt

do {wave.do}

view wave
view structure
view signals

do {CRAMmem.udo}

run -all

quit -force
