# Design Clock in (MHz)
# Half clock speed
FPGA_CLOCK=25

.PHONY: all
all: chip.bin

# Use Yosys to create an object file
chip.blif: chip.v morse.v
	yosys -q -p "read_verilog -noautowire $^ ; hierarchy ; proc ; check ; fsm; opt ; clean ; synth_ice40 -blif $@"

# Use the object file + the constraint file to create bit field file
%.txt: %.blif upduino_v2.pcf
	arachne-pnr -d 5k -P sg48 -p $(word 2,$^) $< -o $@
	if ! icetime -d up5k -p $(word 2,$^) -c $(FPGA_CLOCK) $@ ; then $(RM) $@ ; fi

# Pack the bit field file in a format that can be programmed into the FPGA
%.bin: %.txt
	icepack $< $@

# Show the logical schema of the contained in the object file
# This is the input for ArachnaPNR
show: chip.blif
	yosys -p "synth_ice40; show" chip.blif

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

clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin
	$(RM) -f $(SIMPROJ).blif
	$(RM) -f $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb

.SECONDARY:
.PHONY: gtkwave sim flash clean all show
