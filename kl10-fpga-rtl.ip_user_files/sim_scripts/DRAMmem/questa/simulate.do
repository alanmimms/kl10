onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib DRAMmem_opt

do {wave.do}

view wave
view structure
view signals

do {DRAMmem.udo}

run -all

quit -force
