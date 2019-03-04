
chip.bin: chip.v blink.v upduino_v2.pcf
	yosys -q -p "synth_ice40 -blif chip.blif" chip.v blink.v
	arachne-pnr -d 5k -P sg48 -p upduino_v2.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

.PHONY: flash
flash: chip.bin
	iceprog chip.bin

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin
