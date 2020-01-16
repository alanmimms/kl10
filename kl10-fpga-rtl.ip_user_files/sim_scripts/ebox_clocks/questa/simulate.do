onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ebox_clocks_opt

do {wave.do}

view wave
view structure
view signals

do {ebox_clocks.udo}

run -all

quit -force
