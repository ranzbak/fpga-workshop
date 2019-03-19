
module chip (
	output	LED_R,
	);

  // A wire
	wire  led_r;

  // Continuous assignment to a wire
	assign led_r = 1'b0;

  // Connecting the wire to the output
	assign LED_R = led_r;
endmodule
