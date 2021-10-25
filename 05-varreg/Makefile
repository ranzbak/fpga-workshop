# Name of the simulation project
SIMPROJ = led

# Design Clock in (MHz)
FPGA_CLOCK=50

.PHONY: all
all: chip.bin

# Use Yosys to create an object file
chip.json: chip.v led.v
	yosys -q -p "read_verilog -noautowire $^ ; hierarchy ; proc ; check ; fsm; opt ; clean ; synth_ice40 -json $@"

# Use the object file + the constraint file to create bit field file
%.asc: %.json upduino_v2.pcf
	nextpnr-ice40 --opt-timing --up5k --package sg48 --pcf $(word 2,$^) --json $< --asc $@

# Pack the bit field file in a format that can be programmed into the FPGA
%.bin: %.asc
	icepack $< $@

# Show the logical schema of the contained in the object file
# This is the input for ArachnaPNR
show: chip.json
	yosys -q -p "show -format ps -viewer xdg-open" $^

# Check in the design can reach

# Flash the binary file to the FPGA
flash: chip.bin
	iceprog chip.bin

# Simulate

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

clean:
	$(RM) chip.json chip.asc chip.ex chip.bin
	$(RM) $(SIMPROJ).blif
	$(RM) $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb

.SECONDARY:
.PHONY: gtkwave sim flash clean all show
