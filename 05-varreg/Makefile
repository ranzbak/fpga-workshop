
chip.bin: chip.v led.v upduino_v2.pcf
	yosys -q -p "synth_ice40 -blif chip.blif" chip.v led.v
	arachne-pnr -d 5k -P sg48 -p upduino_v2.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

flash: chip.bin
	iceprog chip.bin

clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin


# Simulate
SIMPROJ = led

%.blif: %.v $(SIMPROJ).v
	yosys -p 'synth_ice40 -top chip -blif $@' $< $(SIMPROJ).v

%_tb: %_tb.v %.v
	iverilog -o $@ $^

%_tb.vcd: %_tb
	vvp -N $< +vcd=$@

%_syn.v: %.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $< +vcd=$@

sim: $(SIMPROJ)_tb.vcd

gtkwave: $(SIMPROJ)_tb.vcd default.gtkw
	gtkwave $^

.SECONDARY:
.PHONY: gtkwave sim flash clean
