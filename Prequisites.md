# FPGA Workshop

* [Back to README](README.md)

## Stupid things on macOS

GTKWave is trying too hard . .

Edit `/usr/local/bin/gtkwave`

Add (at the top):

```
open /Applications/gtkwave.app $@
exit
```

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
sh autoconf.sh
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
