
module chip (
	output	LED_R,
	);

	wire  led_r;

	led my_led (
    		.led_r(led_r),
	);

	assign LED_R = led_r;
endmodule
