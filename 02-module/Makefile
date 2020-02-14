#
# Yosys example Makefile
# Paul Honig 2020
#

.PHONY: all
all: chip.bin

# Use Yosys to create an object file
chip.blif: chip.v led.v
	yosys -q -p "read_verilog -noautowire $^ ; check ; clean ; synth_ice40 -blif $@"

# Use the object file + the constraint file to create bit field file
chip.txt: chip.blif upduino_v2.pcf
	arachne-pnr -d 5k -P sg48 -p $(word 2,$^) $< -o $@

# Pack the bit field file in a format that can be programmed into the FPGA
chip.bin: chip.txt
	icepack $< $@

.PHONY: flash
flash: chip.bin
	iceprog chip.bin

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin

.PHONY: show
show: chip.blif
	yosys -p "synth_ice40; show" chip.blif
