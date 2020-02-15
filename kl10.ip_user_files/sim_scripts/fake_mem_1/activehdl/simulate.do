onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+fake_mem -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fake_mem xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {fake_mem.udo}

run -all

endsim

quit -force
