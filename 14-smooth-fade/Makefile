PROJ = chip
SIMPROJ = simulate

PIN_DEF = upduino_v2.pcf
DEVICE = 5k
TIME_DEVICE = up5k

PROJ_SOURCE = $(shell ls -1 *.v | egrep -v '($(SIMPROJ)|$(PROJ))' )

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v $(SIMPROJ).v $(PROJ_SOURCE)
	yosys -p 'read_verilog -noautowire $^; tribuf; hierarchy; opt; proc; opt; fsm; opt; clean; synth_ice40 -top chip -blif $@; tribuf -logic'

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(TIME_DEVICE) -mtr $@ $<

%_tb: %_tb.v $(SIMPROJ).v $^ $(PROJ_SOURCE)
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

flash: $(PROJ).bin
	iceprog $<

clean:
	# Remove the synthesis files
	$(RM) $(SIMPROJ).blif $(SIMPROJ).asc $(SIMPROJ).rpt $(SIMPROJ).bin
	$(RM) $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin
	# Removing the simulation files
	$(RM) $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb $(SIMPROJ)_syn.v

.SECONDARY:
.PHONY: all flash clean sim
