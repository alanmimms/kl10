onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.ebox_clocks xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ebox_clocks.udo}

run -all

quit -force