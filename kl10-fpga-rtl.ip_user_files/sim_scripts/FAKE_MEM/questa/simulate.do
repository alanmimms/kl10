onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib FAKE_MEM_opt

do {wave.do}

view wave
view structure
view signals

do {FAKE_MEM.udo}

run -all

quit -force
