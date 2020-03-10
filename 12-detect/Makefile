PROJ = chip
SIMPROJ = simulate
GTKWAVE_CFG = default.gtkw
CLK_FREQ = 24 # The frequency in MHz the clock runs at

PIN_DEF = upduino_v2.pcf
DEVICE = 5k
TIME_DEVICE = up5k

PROJ_SOURCE = $(shell ls -1 *.v | egrep -v '($(SIMPROJ)|$(PROJ))' )

all: $(PROJ).rpt $(PROJ).bin

test:
	echo $(PROJ_SOURCE)

%.blif: %.v $(SIMPROJ).v $(PROJ_SOURCE)
	yosys -p 'proc; opt; synth_ice40 -top chip -blif $@; tribuf -logic' $^

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(TIME_DEVICE) -mtr $@ -c $(CLK_FREQ) $<

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

gtkwave: $(SIMPROJ)_tb.vcd $(GTKWAVE_CFG)
	gtkwave $^

flash: $(PROJ).bin
	iceprog $<

show: chip.blif
	yosys -p "synth_ice40; show" chip.blif


clean:
	# Remove the synthesis files
	$(RM) $(SIMPROJ).blif $(SIMPROJ).asc $(SIMPROJ).rpt $(SIMPROJ).bin
	$(RM) $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).txt
	# Removing the simulation files
	$(RM) $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb

.SECONDARY:
.PHONY: all flash clean sim test gtkwave
