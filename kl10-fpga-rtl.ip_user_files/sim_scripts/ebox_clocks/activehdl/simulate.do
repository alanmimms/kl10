onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ebox_clocks -L xilinx_vip -L xpm -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ebox_clocks xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ebox_clocks.udo}

run -all

endsim

quit -force
