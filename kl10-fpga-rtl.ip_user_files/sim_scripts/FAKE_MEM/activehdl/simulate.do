onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+FAKE_MEM -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.FAKE_MEM xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {FAKE_MEM.udo}

run -all

endsim

quit -force
