
chip.bin: chip.v led.v upduino_v2.pcf
	yosys -q -p "synth_ice40 -blif chip.blif" chip.v led.v
	arachne-pnr -d 5k -P sg48 -p upduino_v2.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

.PHONY: flash
flash: chip.bin
	iceprog chip.bin

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin

.PHONY: show
show: chip.blif
	yosys -p "synth_ice40; show" chip.blif
