# Dim the bright light

As you have noticed before, the high intensity RGB LEDs will almost certainly burn
your eyeballs if you stare at it long enough.
This example fixes that for you :)

## Requirements

* Yosys
* Arachne-pnr
* Project IceStorm

## Usage

* ```make```

    Builds ```chip.bin``` bitstream

* ```make flash```

    Program the bitstream to the device.

Loosly based on [tomverbeure/upduino](https://github.com/tomverbeure/upduino/tree/master/blink)
