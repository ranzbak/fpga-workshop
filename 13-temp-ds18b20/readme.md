# Description

This example demonstrates a state machine that handles IO with an external device.
The device drives LEDS to indicate a temperature range, blue <20'c, green >20'c <25'C, rood > 25'C.
When something fails the LED will shine white, when the LED stays off, check if pin 42 (reset) is grounded.

# Temp DS18B20

A fully fledged example on how to create a state machine that drives a generic module.
In this case a one-wire module is used to drive a DS18B20 temperature sensor.
Because of the states the transactions go through and the process as a whole goes through,
a state machine is used that works in multiple layers.

* read\_temp - Contains the high level state machine running through the commands
* ds18b20 - Drives the IC, sending the commands and waiting for the responses.
* sockit_owm - Encodes/decodes data over the one-wire protocol.

# Requirements

* Yosys
* Arachne-pnr
* Project IceStorm
* DS18B20
* 4.7kOhm Resistor
* Breadboard
* Some dupont wire

# Schema

```ascii
 VCC +3.3V
+------+----------------+-------------------------------+
       |                |
       |              +-+-+
       |3             | 4 |
+----------------+    | . |    +------------------+
|                |    | 7 |    |                  |
|                |    +-+-+    |                  |
|                |      |      |                  |
|  DS18B20       +------+------+     ICE40        |
|                |2         43 |                  |
|                |             |                  |
|                |             |                  |
+----------------+             +------------------+
       |1
       |
+------+------------------------------------------------+
 GND


  TO92 package
  DS18B20
 +----------+
 |  1  2  3 |
 |          |
 +-+      +-+
   --------
 GND  SIG  VCC
```


# Requirements

* Yosys
* Arachne-pnr
* Project IceStorm

# Usage

* ```make```

    Builds ```chip.bin``` bitstream

* ```make flash```

    Program the bitstream to the device.

* ```make sim```

    Checks the program via a simulation.

* ```make gtkwave```

    Opens a wave form viewer to show the simulated states the machine progresses to over time.

Expected output during flashing:

```
$ make flash
iceprog chip.bin
init..
cdone: high
reset..
cdone: high
flash ID: 0xEF 0x40 0x16 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
file size: 104090
erase 64kB sector at 0x000000..
erase 64kB sector at 0x010000..
programming..
reading..
VERIFY OK
cdone: high
Bye.
```

Expected output during GTKWave run

```
$ make gtkwave
iverilog -o simulate_tb simulate_tb.v simulate.v ds18b20.v read_temp.v sockit_owm.v
vvp -N simulate_tb +vcd=simulate_tb.vcd
VCD info: dumpfile simulate_tb.vcd opened for output.
SUCCESS: Simulation run for 200000 cycles/ 0.00 ns.
SUCCESS: Simulation run for 200000 cycles/ 0.00 ns.
gtkwave simulate_tb.vcd default.gtkw

GTKWave Analyzer v3.3.86 (w)1999-2017 BSI

[0] start time.
[200000000] end time.
```
