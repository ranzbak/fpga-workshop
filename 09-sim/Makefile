PROJ = chip
SIMPROJ = simulate

PIN_DEF = upduino_v2.pcf
DEVICE = 5k
TIME_DEVICE = up5k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v $(SIMPROJ).v
	yosys -p 'synth_ice40 -top chip -blif $@' $< $(SIMPROJ).v

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(TIME_DEVICE) -mtr $@ $<

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

prog: $(PROJ).bin
	iceprog $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog $<

clean:
	# Remove the synthesis files
	rm -f $(SIMPROJ).blif $(SIMPROJ).asc $(SIMPROJ).rpt $(SIMPROJ).bin 
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin 
	# Removing the simulation files
	rm -f $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb

.SECONDARY:
.PHONY: all prog clean sim postsim
