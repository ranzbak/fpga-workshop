.PHONY: all
all: chip.bin

# Use Yosys to create an object file
chip.blif: chip.v morse.v
	yosys -q -p "read_verilog -noautowire $^ ; hierarchy ; proc ; check ; clean ; synth_ice40 -blif $@"

# Use the object file + the constraint file to create bit field file
%.txt: %.blif upduino_v2.pcf
	arachne-pnr -d 5k -P sg48 -p $(word 2,$^) $< -o $@
	if ! icetime -d up5k $@ -p $(word 2,$^) ; then $(RM)$@ ; fi

# Pack the bit field file in a format that can be programmed into the FPGA
%.bin: %.txt
	icepack $< $@

# Show the logical schema of the contained in the object file
# This is the input for ArachnaPNR
show: chip.blif
	#yosys -q -p "hierarchy ; proc ; clean ; opt; synth_ice40; show -format ps -viewer xdg-open" $^
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

clean:
	$(RM) chip.blif chip.txt chip.ex chip.bin
	$(RM) $(SIMPROJ).blif
	$(RM) $(SIMPROJ)_syntb $(SIMPROJ)_syntb.vcd $(SIMPROJ)_tb.vcd $(SIMPROJ)_tb

.SECONDARY:
.PHONY: flash clean all show
