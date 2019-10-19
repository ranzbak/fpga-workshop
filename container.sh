#!/bin/bash

docker run --rm -t -i \
	--privileged \
	--security-opt=seccomp:unconfined \
	--device /dev/ttyUSB0 \
	--cap-add SYS_PTRACE \
	-v /dev/bus:/dev/bus \
	-v /dev/serial:/dev/serial \
	-v $(pwd):/app \
	--workdir /app \
	link0/fpga \
	bash \
;
