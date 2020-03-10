# FPGA Workshop

[Basic FPGA development](docs/Basic%20FPGA%20development.pdf)
for absolute beginners

## Sections

* [01 Hello](01-hello)
* [02 Module](02-module)
* [03 Blink](03-blink)
* [03a Blink](03a-blink)
* [04 Parameters](04-parameter)
* [05 Variables and Registers](05-varreg)
* [06 Dimming](06-dim)
* [07 Tasks](07-task)
* [08 Functions](08-function)
* [09 Case statement](09-case)
* [10 I/O pins in verilog](10-io)
* [11 Simulation](11-sim)
* [12 Detect](12-detect)
* [13 DS18B20 Sensor](13-temp-ds18b20)
* [13 Smooth fading](14-smooth-fade)

## Pre-requisites

When joining the workshop as a participant make sure to have these things done.

**Compiling the tool chain takes 35 to 55 minutes, during which you cannot take part in the exorcizes in the workshop.**

* Installed Icestorm toolchain, that supports the Lattice ICE40UP5K FPGA.
  * [Install manually](http://www.clifford.at/icestorm/#install)
  * [Install by script](https://github.com/ddm/icetools)
  * Install by packagemanager: `apt-get install arachne-pnr arachne-pnr-chipdb iverilog gtkwave` (on Ubuntu 19.04 or a recent Debian)
  * For those that forget there will be a Virtual machine, that will suffice during the workshop.
* A micro USB cable
* A working laptop that can run the Icestorm toolchain (Linux or OSX should be fine, for Windows I don't know#)
* 3 to 4 hours of your time, an Saturday the 13th (There will be some breaks)
* Some basic knowledge about programming and digital circuits
* A laptop that is capable of running the Icestorm toolchain.

### Checking the tool chain

A simple check to see if the toolchain supports the 'ICE40UP5K', do:

```bash
$ arachne-pnr -h

<...>
    -d <device>, --device <device>
        Target device <device>.  Supported devices:
          384 - Lattice Semiconductor iCE40LP384
           1k - Lattice Semiconductor iCE40LP/HX1K
           5k - Lattice Semiconductor iCE40UP5K
         lm4k - Lattice Semiconductor iCE40LM4K
           8k - Lattice Semiconductor iCE40LP/HX8K
        Default: 1k
<...>
```

When it shows the line **'5k - Lattice Semiconductor iCE40UP5K'** the tool chain supports the UPDuino V2.

## Requisites

###Materials

The hardware for one workshop kit
* 1x [UPDuino V2.0](http://www.gnarlygrey.com)
* 2x 12kΩ resistors
* 1x 4.7kΩ resistor
* 1x [400 pin breadboard](https://www.ebay.com/itm/400-Points-Solderless-Breadboard-Protoboard-PCB-Test-Tafel/303104250905?hash=item46926bd419:g:0ZIAAOSwQKdclOnX)
* 6x [breadboard wire (one lot has enough wires for 6 kits)](https://www.ebay.com/itm/65Pcs-Male-to-Male-Solderless-Flexible-Breadboard-Jumper-Cable-Wires-For-Arduino/132335990497?epid=1066101990&hash=item1ecfd6f6e1:g:jbAAAOSwEi1cdQBv)
* 1x [DS18B20 temperature sensor](https://www.ebay.com/itm/5-10-20-50PCS-DS18B20-TO-92-9-12bit-Temperature-Sensor-Dallas-Thermometer-Sensor/323535934527?epid=2074368262&hash=item4b543e943f:m:mUgBbGl2BpyCl8TGSeZYERA)

###Software
[dimdm IceTools Github](https://github.com/ddm/icetools)


## Requisites for people wanting to do it hardcore

### [IceStorm](http://www.clifford.at/icestorm/)

```
git clone https://github.com/cliffordwolf/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
```

### [Archane-PNR](https://github.com/cseed/arachne-pnr)

```
git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
cd arachne-pnr
make -j$(nproc)
sudo make install
```

### [NextPNR](https://github.com/YosysHQ/nextpnr)

```
git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
```

### [Yosys](http://www.clifford.at/yosys/)

```
git clone https://github.com/cliffordwolf/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
```

## Simulation

For example [11](/11-sim) you'll need to install Icarus Verilog and GTKWave

### [Icarus Verilog](http://iverilog.icarus.com/)

```
git clone git://github.com/steveicarus/iverilog.git iverilog
cd iverilog
aclocal
autoconf
automake
./configure
make -j$(nproc)
sudo make install
```

### [GTKWave](http://gtkwave.sourceforge.net/)

```
svn checkout svn://svn.code.sf.net/p/gtkwave/code/ gtkwave-code
cd gtkwave-code/gtkwave3-gtk3
./configure
make -j$(nproc)
sudo make install
```

## Further reading

* [UPDuino v.2.0 schematic](docs/UPDuino_v2_0_C_121217.pdf)
* [Lattice iCE40 UltraPlus datasheet](docs/ice40ultraplusfamilydatasheet.pdf)
* [SocKit 1-wire master](docs/sockit_onewire.pdf)
