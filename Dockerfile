FROM ubuntu:disco

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
	arachne-pnr \
	arachne-pnr-chipdb \
	build-essential \
	fpga-icestorm \
	fpga-icestorm-chipdb \
;
