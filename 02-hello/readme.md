# Hello

This 'Hello World' equivalent simply lights one of the RGB LEDs internal LEDs.
They're high intensity LEDs that will almost certainly burn your eyeballs
when you stare at it long enough.

## Requirements

* Yosys
* Arachne-pnr
* Project IceStorm

## Usage

* ```make```

    Builds ```chip.bin``` bitstream

* ```make flash```

    Program the bitstream to the device.

Expected output during flashing:

```
iceprog chip.bin
init..
cdone: high
reset..
cdone: high
flash ID: 0xEF 0x40 0x16 0x00
file size: 104090
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
programming..
reading..
VERIFY OK
cdone: high
Bye.
```

Based on [tomverbeure/upduino](https://github.com/tomverbeure/upduino/tree/master/blink)
