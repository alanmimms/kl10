onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.fake_mem xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {fake_mem.udo}

run -all

quit -force