#
# Yosys example Makefile
# Paul Honig 2020
#

.PHONY: all
all: chip.bin

# Use Yosys to create an object file
chip.json: chip.v led.v
	yosys -q -p "read_verilog -noautowire $^ ; check ; clean ; synth_ice40 -json $@"

# Use the object file + the constraint file to create bit field file
chip.asc: chip.json upduino_v2.pcf
	nextpnr-ice40 --opt-timing --up5k --package sg48 --pcf $(word 2,$^) --json $< --asc $@

# Pack the bit field file in a format that can be programmed into the FPGA
chip.bin: chip.asc
	icepack $< $@

.PHONY: flash
flash: chip.bin
	iceprog chip.bin

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.asc chip.ex chip.bin chip.json

.PHONY: show
show: chip.blif
	yosys -p "synth_ice40; show" chip.blif
