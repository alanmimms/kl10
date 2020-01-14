onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib FMmem_opt

do {wave.do}

view wave
view structure
view signals

do {FMmem.udo}

run -all

quit -force
