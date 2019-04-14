# Detect

This example detects a DS18B20 one wire sensor connected to port 43.
Given that port 43 is pulled high by a pull-up resistor of 4.3kOhm to VCC 3.3V.
When the pull-up is not provided, results will be unpredictable. 
When the DS18B20 is found the LED turn green, when not found red.

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
 +-----------+
 |  1  2  3  |
 |  bottom   |
  \_________/
 GND  SIG  VCC
```

# Usage

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

# Simulate

* ``` make sim ```

Expect the following output:
```
iverilog -o simulate_tb simulate_tb.v simulate.v onewire.v temp.v
simulate.v:17: warning: parameter CRD_O not found in testbench.uut.my_temp.
vvp -N simulate_tb +vcd=simulate_tb.vcd
VCD info: dumpfile simulate_tb.vcd opened for output.
DS18B20 Should not be detected at run 1
DS18B20 detected at run 1: OK
DS18B20 Should not be detected at run 2
DS18B20 detected at run 2: OK
DS18B20 Should not be detected at run 3
DS18B20 not detected at run 3: OK
SUCCESS: Simulation run for 200000 cycles.
```

# View simulated waveforms

* ``` make gtkwave ```

This will open a GTKWave window, showing the One-wire detection wave forms.
