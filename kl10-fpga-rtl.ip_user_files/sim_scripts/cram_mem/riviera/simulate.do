onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+cram_mem -L xilinx_vip -L xpm -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.cram_mem xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {cram_mem.udo}

run -all

endsim

quit -force
