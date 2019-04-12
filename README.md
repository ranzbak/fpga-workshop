# FPGA Workshop

Basic FPGA development 
for absolute beginners

## Sections

* [01 Hello](01-hello)
* [02 Module](02-module)
* [03 Blink](03-blink)
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

## Requisites

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

For example [09](/09-sim) you'll need to install Icarus Verilog and GTKWave

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
