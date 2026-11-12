# DE10-Lite workflow
#   make          compile with Quartus  -> output_files/blink.sof
#   make prog     load into FPGA (temporary, lost on power-off)
#   make flash    write to on-chip flash (stays after power-off)
#   make sim      run testbench with Icarus Verilog
#   make wave     open waveforms in GTKWave
#   make lint     quick check with Verilator (no Quartus needed)
#   make clean

PROJECT := blink
RTL     := $(wildcard rtl/*.v rtl/*.sv)
TB      := sim/$(PROJECT)_tb.v

.PHONY: all prog flash sim wave lint clean

all: output_files/$(PROJECT).sof

output_files/$(PROJECT).sof: $(RTL) $(PROJECT).qsf $(PROJECT).sdc
	quartus_sh --flow compile $(PROJECT)

prog: output_files/$(PROJECT).sof
	quartus_pgm -m jtag -o "p;$<"

flash: output_files/$(PROJECT).sof   # Quartus writes the .pof alongside the .sof
	quartus_pgm -m jtag -o "p;output_files/$(PROJECT).pof"

sim: $(RTL) $(TB)
	iverilog -g2012 -Wall -o sim/$(PROJECT)_tb.vvp $(TB) $(RTL)
	cd sim && vvp -n $(PROJECT)_tb.vvp

wave: sim
	gtkwave sim/$(PROJECT)_tb.vcd &

lint:
	verilator --lint-only -Wall --top-module $(PROJECT) $(RTL)

clean:
	rm -rf output_files db incremental_db qdb tmp-clearbox *.rpt *.summary *.smsg *.qws sim/*.vvp sim/*.vcd
