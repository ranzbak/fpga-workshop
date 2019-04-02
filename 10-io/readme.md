# I/O pins in verilog

Use the Morse example, to ghetto test an Input to the FPGA.

Requires two 10k resistors between pin 42 and ground.
Add a (jumper) wire between the two resistors
and connect to gnd or +3.3V for 0 and 1.

## Requirements

* Yosys
* Arachne-pnr
* Project IceStorm

## Usage

* ```make```

    Builds ```chip.bin``` bitstream

* ```make flash```

    Program the bitstream to the device.

Very loosly based on [tomverbeure/upduino](https://github.com/tomverbeure/upduino/tree/master/blink)
